import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/service_model.dart';
import '../providers/booking_provider.dart';

class BookingConfirmationStep extends StatelessWidget {
  final ServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final VoidCallback onBack;

  const BookingConfirmationStep({
    super.key,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.onBack,
  });

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final textTheme = Theme.of(context).textTheme;

    final day = DateFormat('d').format(selectedDate);
    final weekday = _capitalize(
        DateFormat('E', 'pt_BR').format(selectedDate).replaceAll('.', ''));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Resumo do Agendamento",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🚗", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Text(service.title,
                        style: textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("📅", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Text("Dia $day, $weekday às $selectedTime",
                        style: textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("💵", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Text(
                      "R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}  •  Duração: ~${service.duration}",
                      style: textTheme.titleMedium
                          ?.copyWith(color: Colors.grey[300]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text("Seus Dados",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInputField("Nome completo", provider.nameController),
          const SizedBox(height: 16),
          _buildInputField("WhatsApp (com DDD)", provider.whatsappController,
              isPhone: true),
          const SizedBox(height: 16),
          _buildInputField("Placa (Ex: ABC-1234)", provider.plateController),
          const SizedBox(height: 8),
          Text(
            "Localizaremos o modelo do seu veículo automaticamente",
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.vehicleController,
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Marca e Modelo (Ex: Chevrolet Onix)",
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: provider.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isLoading
                    ? const Color(0xFF1A1A1A)
                    : AppTheme.primaryRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final success = await provider.confirmBooking(
                          service, selectedDate, selectedTime);
                      if (success && context.mounted) {
                        _showSuccessModal(context, selectedDate, selectedTime);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Preencha os campos de Nome, WhatsApp e Placa.')),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: AppTheme.primaryRed)
                  : const Text("Confirmar Agendamento",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller,
      {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  void _showSuccessModal(BuildContext context, DateTime date, String time) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 64),
                ),
                const SizedBox(height: 24),
                const Text("Agendamento Confirmado!",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  "Sua vaga está garantida.\nTe esperamos lá!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      context.pop();
                      context.go(AppRouter.home);
                    },
                    child: const Text("Voltar ao Início",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

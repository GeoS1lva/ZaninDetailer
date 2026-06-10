import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
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

    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryRed.withValues(alpha: 0.20)),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent)),
          ),
        ),
        SingleChildScrollView(
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
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
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
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
                    if (service.description != null &&
                        service.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(
                          color: Colors.white.withValues(alpha: 0.07),
                          height: 1),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("📋", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service.description!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text("Seus Dados",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInputField("Nome completo", provider.nameController),
              const SizedBox(height: 16),
              _buildInputField(
                  "WhatsApp (com DDD)", provider.whatsappController,
                  isPhone: true),
              const SizedBox(height: 16),
              _buildInputField(
                  "Placa (Ex: ABC-1234)", provider.plateController),
              const SizedBox(height: 8),
              Text(
                "Informe a marca e o modelo do seu veículo",
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              _buildInputField("Marca e Modelo (Ex: Chevrolet Onix)",
                  provider.vehicleController),
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
                            _showSuccessModal(
                                context, selectedDate, selectedTime);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(provider.errorMessage ??
                                      'Não foi possível confirmar o agendamento.')),
                            );
                          }
                        },
                  child: provider.isLoading
                      ? const CircularProgressIndicator(
                          color: AppTheme.primaryRed)
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
        ),
      ],
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

  Future<void> _abrirWhatsApp(BuildContext context, String mensagem) async {
    final uri = Uri.parse(
      'https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(mensagem)}',
    );
    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  void _showSuccessModal(BuildContext context, DateTime date, String time) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(date);
    final mensagemContato =
        'Olá! Acabei de agendar o serviço *${service.title}* para o dia '
        '$dataFormatada às $time. Qualquer dúvida, estou à disposição!';
    final mensagemReagendar =
        'Olá! Gostaria de reagendar meu agendamento do serviço '
        '*${service.title}*, marcado para o dia $dataFormatada às $time. '
        'Poderia me ajudar com isso?';
    final mensagemCancelar =
        'Olá! Gostaria de cancelar meu agendamento do serviço '
        '*${service.title}*, marcado para o dia $dataFormatada às $time.';

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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _abrirWhatsApp(context, mensagemContato),
                    icon: const Icon(Icons.chat_bubble_rounded,
                        color: Colors.white, size: 20),
                    label: const Text("Falar no WhatsApp",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () =>
                              _abrirWhatsApp(context, mensagemReagendar),
                          child: const Text("Reagendar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppTheme.primaryRed
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () =>
                              _abrirWhatsApp(context, mensagemCancelar),
                          child: Text("Cancelar",
                              style: TextStyle(
                                  color: AppTheme.primaryRed.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.go(AppRouter.home);
                  },
                  child: Text("Voltar ao Início",
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

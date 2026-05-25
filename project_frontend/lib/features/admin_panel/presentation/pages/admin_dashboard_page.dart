import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/admin_agenda_model.dart';
import '../providers/admin_provider.dart';
import '../../../../core/router/app_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryRed.withValues(alpha: 0.15)),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.exit_to_app,
                            color: AppTheme.primaryRed, size: 28),
                        onPressed: () => context.go(AppRouter.home),
                      ),
                    ],
                  ),
                  Text('Painel de Controle', style: textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Olá, Eduardo',
                      style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricCard(
                              value: provider.totalAgendamentos,
                              label: 'Agendamentos Hoje',
                              textTheme: textTheme)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildMetricCard(
                              value: provider.previsaoFaturamento,
                              label: 'Previsto Hoje',
                              textTheme: textTheme)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text('Agenda do Dia', style: textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryRed))
                        : provider.agendamentosHoje.isEmpty
                            ? Center(
                                child: Text('Nenhum agendamento para hoje.',
                                    style: textTheme.bodyMedium))
                            : ListView.builder(
                                itemCount: provider.agendamentosHoje.length,
                                itemBuilder: (context, index) {
                                  return _buildAgendaCard(
                                      context,
                                      provider.agendamentosHoje[index],
                                      textTheme);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF161616),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.car_repair,
                          color: AppTheme.primaryRed),
                      title: Text('Novo Serviço', style: textTheme.labelLarge),
                      subtitle: Text('Cadastre pacotes como Lavagem Essencial',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      onTap: () {
                        context.pop();
                        context.go(AppRouter.adminNovoServico);
                      },
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    ListTile(
                      leading: const Icon(Icons.branding_watermark,
                          color: AppTheme.primaryRed),
                      title: Text('Nova Marca Parceira',
                          style: textTheme.labelLarge),
                      subtitle: Text(
                          'Faça upload de logos como Vonixx e Meguiar\'s',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      onTap: () {
                        context.pop();
                        context.go(AppRouter.adminNovaMarca);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMetricCard(
      {required String value,
      required String label,
      required TextTheme textTheme}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(value,
              style: textTheme.headlineLarge
                  ?.copyWith(color: AppTheme.primaryRed, fontSize: 32)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(
      BuildContext context, AdminAgendaModel agenda, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(agenda.veiculo, style: textTheme.titleLarge),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(agenda.status,
                    style: textTheme.labelLarge
                        ?.copyWith(color: Colors.black, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Placa: ${agenda.placa} | Cliente: ${agenda.cliente}',
              style: textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(agenda.servico,
                  style: textTheme.titleLarge?.copyWith(fontSize: 17)),
              GestureDetector(
                onTap: () =>
                    context.read<AdminProvider>().concluirServico(agenda.id),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

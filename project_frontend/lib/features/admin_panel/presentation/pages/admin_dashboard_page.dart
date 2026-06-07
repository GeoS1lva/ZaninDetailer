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

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Admin';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final textTheme = Theme.of(context).textTheme;

    final firstName = _getFirstName(
        provider.currentUser?.fullName ?? provider.currentUser?.email);

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
                        icon: const Icon(Icons.people_alt_outlined,
                            color: AppTheme.primaryRed, size: 28),
                        onPressed: () => context.push(AppRouter.adminUsers),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app,
                            color: AppTheme.primaryRed, size: 28),
                        onPressed: () {
                          context.go(AppRouter.home);
                        },
                      ),
                    ],
                  ),
                  Text('Painel de Controle', style: textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    provider.isLoading && provider.currentUser == null
                        ? 'Carregando perfil...'
                        : 'Olá, $firstName',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
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
      floatingActionButton: const CustomSpeedDial(),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: textTheme.headlineLarge
                    ?.copyWith(color: AppTheme.primaryRed, fontSize: 32)),
          ),
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
          Text(agenda.servico,
              style: textTheme.titleLarge?.copyWith(fontSize: 17)),
        ],
      ),
    );
  }
}

class CustomSpeedDial extends StatefulWidget {
  const CustomSpeedDial({super.key});

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAnimatedButton(
          title: "Marcas",
          icon: Icons.branding_watermark,
          onTap: () => context.push('/admin/marcas'),
          index: 2,
        ),
        _buildAnimatedButton(
          title: "Catálogo",
          icon: Icons.list_alt,
          onTap: () => context.push(AppRouter.adminServicosList),
          index: 1,
        ),
        FloatingActionButton(
          backgroundColor: AppTheme.primaryRed,
          onPressed: _toggle,
          child: RotationTransition(
            turns:
                Tween<double>(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required int index}) {
    final animationInterval = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1.0 - (index * 0.2), curve: Curves.easeOutBack),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
            .animate(animationInterval);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: animationInterval,
        child: FadeTransition(
          opacity: animationInterval,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                _toggle();
                onTap();
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    heroTag: title,
                    mini: true,
                    backgroundColor: const Color(0xFF1A1A1A),
                    elevation: 4,
                    onPressed: () {
                      _toggle();
                      onTap();
                    },
                    child: Icon(icon, color: AppTheme.primaryRed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_service_provider.dart';

class AdminServicesListPage extends StatelessWidget {
  const AdminServicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>()..fetchServicos(),
      child: const _AdminServicesListView(),
    );
  }
}

class _AdminServicesListView extends StatelessWidget {
  const _AdminServicesListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Catálogo de Serviços',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: provider.isLoading && provider.servicos.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : RefreshIndicator(
              color: AppTheme.primaryRed,
              onRefresh: provider.fetchServicos,
              child: ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                itemCount: provider.servicos.length,
                itemBuilder: (context, index) {
                  final servico = provider.servicos[index];
                  return Card(
                    color: const Color(0xFF161616),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8)),
                        child: servico.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(servico.imageUrl!,
                                    fit: BoxFit.cover))
                            : const Icon(Icons.car_repair,
                                color: Colors.white54),
                      ),
                      title: Text(servico.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'R\$ ${servico.price.toStringAsFixed(2)} • ${servico.durationDisplay}',
                          style: const TextStyle(color: AppTheme.primaryRed)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white54),
                            onPressed: () async {
                              await context.push('/admin/servicos/editar',
                                  extra: servico);

                              if (context.mounted) {
                                context
                                    .read<AdminServiceProvider>()
                                    .fetchServicos();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.white54),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('Excluir Serviço?',
                                      style: TextStyle(color: Colors.white)),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Excluir',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirmar == true && context.mounted) {
                                await context
                                    .read<AdminServiceProvider>()
                                    .deletarServico(servico.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await context.push(AppRouter.adminNovoServico);

          if (context.mounted) {
            context.read<AdminServiceProvider>().fetchServicos();
          }
        },
      ),
    );
  }
}

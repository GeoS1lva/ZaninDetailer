import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_brand_provider.dart';

class AdminBrandsListPage extends StatelessWidget {
  const AdminBrandsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminBrandProvider>()..fetchMarcas(),
      child: const _AdminBrandsListView(),
    );
  }
}

class _AdminBrandsListView extends StatelessWidget {
  const _AdminBrandsListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBrandProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Marcas de Veículos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: provider.isLoading && provider.marcas.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : RefreshIndicator(
              color: AppTheme.primaryRed,
              onRefresh: provider.fetchMarcas,
              child: ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                itemCount: provider.marcas.length,
                itemBuilder: (context, index) {
                  final marca = provider.marcas[index];
                  return Card(
                    color: const Color(0xFF161616),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                        child: marca.imageUrl != null 
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(marca.imageUrl!, fit: BoxFit.cover))
                            : const Icon(Icons.branding_watermark, color: Colors.white54),
                      ),
                      title: Text(marca.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                            onPressed: () async {
                              await context.push(AppRouter.adminEditarMarca, extra: marca);
                              if (context.mounted) context.read<AdminBrandProvider>().fetchMarcas();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('Excluir Marca?', style: TextStyle(color: Colors.white)),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.white38),
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFC62828),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Excluir',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true && context.mounted) {
                                await context.read<AdminBrandProvider>().deletarMarca(marca.id);
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
          await context.push(AppRouter.adminNovaMarca);
          if (context.mounted) context.read<AdminBrandProvider>().fetchMarcas();
        },
      ),
    );
  }
}
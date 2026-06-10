import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/showcase_model.dart';
import '../providers/admin_showcase_provider.dart';

class AdminShowcasesPage extends StatelessWidget {
  const AdminShowcasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminShowcaseProvider>()..fetchVitrines(),
      child: const _AdminShowcasesView(),
    );
  }
}

class _AdminShowcasesView extends StatelessWidget {
  const _AdminShowcasesView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminShowcaseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vitrine de Trabalhos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotos exibidas na seção "Últimos Trabalhos"',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                _SlotBadge(count: provider.vitrines.length),
              ],
            ),
          ),
          if (provider.isLoading && provider.vitrines.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            )
          else if (provider.vitrines.isEmpty)
            Expanded(child: _EmptyState(onAdd: () => _adicionar(context, provider)))
          else
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryRed,
                onRefresh: provider.fetchVitrines,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: provider.vitrines.length,
                  itemBuilder: (context, index) {
                    return _ShowcaseCard(
                      vitrine: provider.vitrines[index],
                      onReplace: () =>
                          _substituir(context, provider.vitrines[index], provider),
                      onDelete: () =>
                          _confirmarExclusao(context, provider.vitrines[index], provider),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: provider.podeAdicionar
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryRed,
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: Colors.white),
              label: const Text('Adicionar foto',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed:
                  provider.isLoading ? null : () => _adicionar(context, provider),
            )
          : null,
    );
  }

  Future<void> _adicionar(
      BuildContext context, AdminShowcaseProvider provider) async {
    final sucesso = await provider.adicionarVitrine();
    if (!context.mounted) return;
    _resultado(context, provider, sucesso, 'Foto adicionada com sucesso!');
  }

  Future<void> _substituir(BuildContext context, ShowcaseModel vitrine,
      AdminShowcaseProvider provider) async {
    final sucesso = await provider.substituirVitrine(vitrine.id);
    if (!context.mounted) return;
    _resultado(context, provider, sucesso, 'Foto substituída com sucesso!');
  }

  Future<void> _confirmarExclusao(BuildContext context, ShowcaseModel vitrine,
      AdminShowcaseProvider provider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover foto?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'A imagem será removida da vitrine e do servidor.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white38),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    final sucesso = await provider.deletarVitrine(vitrine.id);
    if (!context.mounted) return;
    _resultado(context, provider, sucesso, 'Foto removida com sucesso.');
  }

  void _resultado(BuildContext context, AdminShowcaseProvider provider,
      bool sucesso, String mensagemSucesso) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? mensagemSucesso
          : (provider.errorMessage ?? 'Não foi possível concluir.')),
      backgroundColor: sucesso ? AppTheme.successGreen : AppTheme.primaryRed,
    ));
  }
}

class _SlotBadge extends StatelessWidget {
  const _SlotBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cheio = count >= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: cheio
            ? Colors.white.withValues(alpha: 0.05)
            : AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cheio
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryRed.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '$count / 5 fotos',
        style: TextStyle(
          color: cheio ? Colors.grey[500] : AppTheme.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 72, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 20),
          const Text('Nenhuma foto adicionada ainda.',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Adicione até 5 fotos dos seus trabalhos.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined,
                color: Colors.white),
            label: const Text('Adicionar primeira foto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.vitrine,
    required this.onReplace,
    required this.onDelete,
  });

  final ShowcaseModel vitrine;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            vitrine.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryRed, strokeWidth: 2)),
                  ),
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A1A),
              child: const Icon(Icons.broken_image_outlined,
                  color: Colors.white24, size: 40),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OverlayButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Substituir',
                  onTap: onReplace,
                ),
                _OverlayButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Remover',
                  color: Colors.redAccent,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

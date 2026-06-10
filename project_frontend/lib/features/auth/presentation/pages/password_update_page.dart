import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/auth_provider.dart';

class PasswordUpdatePage extends StatelessWidget {
  final String resetToken;

  const PasswordUpdatePage({super.key, required this.resetToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ChangeNotifierProvider(
        create: (_) => di.sl<AuthProvider>(),
        child: _PasswordUpdateView(resetToken: resetToken),
      ),
    );
  }
}

class _PasswordUpdateView extends StatefulWidget {
  final String resetToken;
  const _PasswordUpdateView({required this.resetToken});

  @override
  State<_PasswordUpdateView> createState() => _PasswordUpdateViewState();
}

class _PasswordUpdateViewState extends State<_PasswordUpdateView> {
  final _newPasswordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate(AuthProvider provider) async {
    FocusScope.of(context).unfocus();
    provider.clearError();

    final success = await provider.updatePassword(
        widget.resetToken, _newPasswordController.text);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Senha alterada com sucesso! Faça login.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ));
      context.go(AppRouter.services);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_reset, color: AppTheme.primaryRed, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Criar Nova Senha',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (provider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(provider.errorMessage!,
                    style: const TextStyle(color: AppTheme.primaryRed)),
              ),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: TextField(
                controller: _newPasswordController,
                obscureText: _isObscured,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nova Senha',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: Icon(Icons.lock_outline,
                      color: Colors.white.withValues(alpha: 0.3)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.primaryRed.withValues(alpha: 0.7)),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    provider.isLoading ? null : () => _handleUpdate(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redefinir Senha',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

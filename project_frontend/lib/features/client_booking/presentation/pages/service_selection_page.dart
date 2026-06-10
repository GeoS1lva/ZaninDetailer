import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanin_detailer/core/utils/string_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/service_selection_provider.dart';
import '../../../../features/client_booking/data/models/service_model.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin_panel/presentation/widgets/admin_custom_input.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<ServiceSelectionProvider>(),
      child: const _ServiceSelectionContent(),
    );
  }
}

class _ServiceSelectionContent extends StatefulWidget {
  const _ServiceSelectionContent();

  @override
  State<_ServiceSelectionContent> createState() =>
      _ServiceSelectionContentState();
}

class _ServiceSelectionContentState extends State<_ServiceSelectionContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceSelectionProvider>().fetchApiData();
    });
  }

  void _showLoginModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
            child: FadeTransition(
              opacity: anim1,
              child: ChangeNotifierProvider(
                create: (_) => di.sl<AuthProvider>(),
                child: const AdminLoginDialog(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceSelectionProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: AppTheme.background)),
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
          SafeArea(
            child: provider.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryRed))
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            top: 32, left: 20, right: 20, bottom: 24),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildSectionTitle(
                                  'Escolha o Serviço', textTheme),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.manage_accounts,
                                        color: AppTheme.textSecondary,
                                        size: 28),
                                    onPressed: () => _showLoginModal(context),
                                    tooltip: 'Acesso Restrito',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: provider.services.length,
                            itemBuilder: (context, index) {
                              return _buildServiceCard(
                                  context, provider.services[index], textTheme);
                            },
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            top: 64, left: 20, right: 20, bottom: 24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                  'Produtos de Alta Performance', textTheme),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: provider.brandLogos
                                    .map((logoUrl) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 32),
                                          child: ColorFiltered(
                                            colorFilter: const ColorFilter.mode(
                                                Colors.grey, BlendMode.srcATop),
                                            child: Image.network(
                                              logoUrl,
                                              height: 60,
                                              fit: BoxFit.contain,
                                              errorBuilder: (c, e, s) =>
                                                  Container(
                                                width: 100,
                                                height: 60,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.white12,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 35),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            const EdgeInsets.only(top: 64, left: 20, right: 20),
                        sliver: SliverToBoxAdapter(
                          child: _buildSectionTitle(
                              'Últimos Trabalhos', textTheme),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 340,
                          margin: const EdgeInsets.only(top: 24, bottom: 40),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: provider.lastWorks.length,
                            itemBuilder: (context, index) {
                              return _buildWorkImage(provider.lastWorks[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, ServiceModel service, TextTheme textTheme) {
    final bool hasValidImage =
        service.imageUrl.isNotEmpty && service.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () => context.go(AppRouter.booking, extra: service),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          image: DecorationImage(
            image: hasValidImage
                ? NetworkImage(service.imageUrl)
                : const AssetImage('assets/images/welcome_car.jpg')
                    as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(19)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(19)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Duração: ~${service.duration} • ${StringUtils.formatCurrency(service.price)}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[300],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkImage(String img) {
    final bool isWeb = img.startsWith('http');
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
              image:
                  isWeb ? NetworkImage(img) : AssetImage(img) as ImageProvider,
              fit: BoxFit.cover)),
    );
  }
}

class AdminLoginDialog extends StatefulWidget {
  const AdminLoginDialog({super.key});
  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  bool _isPasswordObscured = true;

  Future<void> _handleLogin(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();
    authProvider.clearError();

    final success = await authProvider.login();

    if (success) {
      if (mounted) {
        context.go(AppRouter.admin, extra: const {'showLoginSuccess': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 1)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (authProvider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withValues(alpha: 0.1),
                      border: Border.all(
                          color: AppTheme.primaryRed.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.primaryRed, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                AdminCustomInput(
                  controller: authProvider.emailController,
                  hint: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                AdminCustomInput(
                  controller: authProvider.passwordController,
                  hint: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _isPasswordObscured,
                  enabled: !authProvider.isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.primaryRed.withValues(alpha: 0.7)),
                    onPressed: () => setState(
                        () => _isPasswordObscured = !_isPasswordObscured),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleLogin(authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      disabledBackgroundColor:
                          AppTheme.primaryRed.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Acessar Painel',
                            style:
                                textTheme.labelLarge?.copyWith(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          authProvider.clearError();
                          final email =
                              authProvider.emailController.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Preencha o campo de e-mail primeiro!',
                                  style: textTheme.bodyMedium),
                              backgroundColor: AppTheme.primaryRed,
                            ));
                            return;
                          }

                          final success =
                              await authProvider.forgotPassword(email);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Link de recuperação enviado para $email',
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white)),
                              backgroundColor: const Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.only(
                                  bottom: 30, left: 24, right: 24),
                            ));
                            context.pop();
                          }
                        },
                  child: Text(
                    'Esqueci minha senha',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ]),
              child:
                  const Icon(Icons.lock_person, color: Colors.white, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}

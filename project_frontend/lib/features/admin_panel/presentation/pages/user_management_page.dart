import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/user_model.dart';
import '../providers/user_management_provider.dart';
import '../widgets/admin_custom_input.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<UserManagementProvider>(),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();

  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().fetchUsers();
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _showCreateUserModal() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    final provider = context.read<UserManagementProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text('Novo Admin', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminCustomInput(
                hint: 'Nome completo',
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              AdminCustomInput(
                hint: 'E-mail',
                controller: emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AdminCustomInput(
                hint: 'Senha',
                controller: passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setDialogState(() => obscurePassword = !obscurePassword),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style:
                  TextButton.styleFrom(foregroundColor: Colors.white38),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await provider.createUser(emailController.text,
                    passwordController.text, nameController.text);
                if (!mounted) return;
                if (success) {
                  nav.pop();
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Administrador criado com sucesso!'),
                      backgroundColor: AppTheme.successGreen));
                } else {
                  messenger.showSnackBar(SnackBar(
                      content:
                          Text(provider.errorMessage ?? 'Erro desconhecido'),
                      backgroundColor: AppTheme.primaryRed));
                }
              },
              child: const Text('Criar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditUserModal(UserModel user) async {
    final nameController = TextEditingController(text: user.fullName);
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    final provider = context.read<UserManagementProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Admin',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminCustomInput(
                hint: 'Nome completo',
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              AdminCustomInput(
                hint: 'Nova senha (opcional)',
                controller: passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setDialogState(() => obscurePassword = !obscurePassword),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Deixe em branco para não alterar a senha.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white38),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await provider.updateUser(
                  user.id,
                  fullName: nameController.text,
                  password: passwordController.text,
                );
                if (!mounted) return;
                if (success) {
                  nav.pop();
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Dados atualizados com sucesso!'),
                      backgroundColor: AppTheme.successGreen));
                } else {
                  messenger.showSnackBar(SnackBar(
                      content:
                          Text(provider.errorMessage ?? 'Erro desconhecido'),
                      backgroundColor: AppTheme.primaryRed));
                }
              },
              child: const Text('Salvar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Gestão de Acessos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: AppTheme.primaryRed),
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          return RefreshIndicator(
            color: AppTheme.primaryRed,
            onRefresh: provider.fetchUsers,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 100),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryRed.withValues(alpha: 0.2),
                      child: Text(_getInitials(user.fullName ?? user.email),
                          style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user.fullName ?? 'Usuário sem nome',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(user.email,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.white54),
                          onPressed: () => _showEditUserModal(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white54),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                title: const Text('Excluir?',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white38),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC62828),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Remover',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                            if (!context.mounted) return;

                            final messenger = ScaffoldMessenger.of(context);
                            await provider.deleteUser(user.id);
                            if (!mounted) return;

                            final snackBar = provider.errorMessage == null
                                ? const SnackBar(
                                    content: Text('Administrador removido.'),
                                    backgroundColor: AppTheme.successGreen)
                                : SnackBar(
                                    content: Text(provider.errorMessage ??
                                        'Erro ao remover'),
                                    backgroundColor: AppTheme.primaryRed);

                            messenger.showSnackBar(snackBar);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserModal,
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Novo Admin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

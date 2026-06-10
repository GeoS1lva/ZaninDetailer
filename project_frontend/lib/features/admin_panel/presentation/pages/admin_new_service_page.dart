import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../providers/admin_service_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/dashed_rect_painter.dart';

class AdminNewServicePage extends StatelessWidget {
  const AdminNewServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>(),
      child: const _AdminNewServiceView(),
    );
  }
}

class _AdminNewServiceView extends StatefulWidget {
  const _AdminNewServiceView();

  @override
  State<_AdminNewServiceView> createState() => _AdminNewServiceViewState();
}

class _AdminNewServiceViewState extends State<_AdminNewServiceView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _tempoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _tempoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  void _removeImage() => setState(() => _image = null);

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty ||
        _precoController.text.trim().isEmpty ||
        _tempoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha todos os campos!'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final provider = context.read<AdminServiceProvider>();

    final sucesso = await provider.salvarNovoServico(
      nome: _nomeController.text.trim(),
      preco: _precoController.text.trim().replaceAll(',', '.'),
      tempoEstimado: _tempoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      imagem: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Serviço criado com sucesso!'),
              backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.errorMessage ?? 'Erro ao salvar serviço'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminServiceProvider>().isLoading;
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
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.3),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.primaryRed, size: 18),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Novo Serviço', style: textTheme.headlineLarge),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminCustomInput(
                              hint: 'Nome do Serviço',
                              controller: _nomeController),
                          const SizedBox(height: 16),
                          AdminCustomInput(
                            hint: 'Descrição do Serviço (Opcional)',
                            controller: _descricaoController,
                          ),
                          const SizedBox(height: 16),
                          AdminCustomInput(
                              hint: 'Preço (ex: 150.00)',
                              prefixText: 'R\$ ',
                              controller: _precoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                          const SizedBox(height: 16),
                          AdminCustomInput(
                              hint: 'Duração em minutos (ex: 120)',
                              controller: _tempoController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 32),
                          _image == null
                              ? _buildDashedUploadArea(textTheme)
                              : _buildImagePreview(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        disabledBackgroundColor:
                            AppTheme.primaryRed.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : Text('Salvar Serviço', style: textTheme.labelLarge),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedUploadArea(TextTheme textTheme) {
    return GestureDetector(
      onTap: _pickImage,
      child: CustomPaint(
        painter: DashedRectPainter(
            color: Colors.white.withValues(alpha: 0.2), strokeWidth: 2, gap: 6),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(24),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.white.withValues(alpha: 0.4), size: 60),
              const SizedBox(height: 16),
              Text(
                'Faça upload da imagem de destaque do serviço',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primaryRed.withValues(alpha: 0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? Image.network(_image!.path, fit: BoxFit.cover)
                : Image.file(File(_image!.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_brand_provider.dart';
import '../widgets/dashed_rect_painter.dart';

class AdminNewBrandPage extends StatefulWidget {
  const AdminNewBrandPage({super.key});

  @override
  State<AdminNewBrandPage> createState() => _AdminNewBrandPageState();
}

class _AdminNewBrandPageState extends State<AdminNewBrandPage> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  void _removeImage() => setState(() => _image = null);

  Future<void> _handleSave() async {
    final sucesso = await context
        .read<AdminBrandProvider>()
        .salvarNovaMarca(imagem: _image);
    if (sucesso && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminBrandProvider>().isLoading;
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
                  Text('Gerenciar Marcas', style: textTheme.headlineLarge),
                  const SizedBox(height: 32),
                  _image == null
                      ? _buildDashedUploadArea(textTheme)
                      : _buildImagePreview(),
                  const Spacer(),
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
                          : Text('Salvar Marca', style: textTheme.labelLarge),
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
          height: 250,
          padding: const EdgeInsets.all(24),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,
                  color: Colors.white.withValues(alpha: 0.4), size: 60),
              const SizedBox(height: 16),
              Text(
                'Faça upload de logos de marcas parceiras',
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
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.primaryRed.withValues(alpha: 0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: kIsWeb
                ? Image.network(_image!.path, fit: BoxFit.contain)
                : Image.file(File(_image!.path), fit: BoxFit.contain),
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

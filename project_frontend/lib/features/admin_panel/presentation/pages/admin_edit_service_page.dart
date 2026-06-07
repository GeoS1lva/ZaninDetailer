import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../data/models/admin_service_model.dart';
import '../providers/admin_service_provider.dart';
import '../widgets/admin_custom_input.dart';
import '../widgets/dashed_rect_painter.dart';

class AdminEditServicePage extends StatelessWidget {
  final AdminServiceModel servico;
  const AdminEditServicePage({super.key, required this.servico});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<AdminServiceProvider>(),
      child: _AdminEditServiceView(servico: servico),
    );
  }
}

class _AdminEditServiceView extends StatefulWidget {
  final AdminServiceModel servico;
  const _AdminEditServiceView({required this.servico});

  @override
  State<_AdminEditServiceView> createState() => _AdminEditServiceViewState();
}

class _AdminEditServiceViewState extends State<_AdminEditServiceView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _tempoController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.servico.name);
    _precoController =
        TextEditingController(text: widget.servico.price.toStringAsFixed(2));
    _tempoController =
        TextEditingController(text: widget.servico.durationMinutes.toString());
    _descricaoController =
        TextEditingController(text: widget.servico.description ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _tempoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) setState(() => _image = pickedFile);
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (_nomeController.text.trim().isEmpty ||
        _precoController.text.trim().isEmpty ||
        _tempoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Preencha os campos obrigatórios!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final provider = context.read<AdminServiceProvider>();
    final sucesso = await provider.atualizarServico(
      id: widget.servico.id,
      nome: _nomeController.text.trim(),
      preco: _precoController.text.trim().replaceAll(',', '.'),
      tempoEstimado: _tempoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      imagem: _image,
    );

    if (mounted) {
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Serviço atualizado!'),
            backgroundColor: Colors.green));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.errorMessage ?? 'Erro'),
            backgroundColor: Colors.redAccent));
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
                      child: Container(color: Colors.transparent)))),
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
                              color: AppTheme.primaryRed, size: 18))),
                  const SizedBox(height: 32),
                  Text('Editar Serviço', style: textTheme.headlineLarge),
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
                              hint: 'Preço (ex: 150.00)',
                              prefixText: 'R\$ ',
                              controller: _precoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true)),
                          const SizedBox(height: 16),
                          AdminCustomInput(
                              hint: 'Duração em minutos',
                              controller: _tempoController,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          AdminCustomInput(
                              hint: 'Descrição do Serviço',
                              controller: _descricaoController),
                          const SizedBox(height: 32),
                          _image == null && widget.servico.imageUrl == null
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
                              borderRadius: BorderRadius.circular(12))),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : Text('Salvar Alterações',
                              style: textTheme.labelLarge),
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
              color: Colors.white.withValues(alpha: 0.2),
              strokeWidth: 2,
              gap: 6),
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
                    Text('Atualizar imagem de destaque',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium)
                  ]))),
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
                  color: AppTheme.primaryRed.withValues(alpha: 0.5), width: 2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _image == null
                ? Image.network(widget.servico.imageUrl!, fit: BoxFit.cover)
                : (kIsWeb
                    ? Image.network(_image!.path, fit: BoxFit.cover)
                    : Image.file(File(_image!.path), fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 20)),
          ),
        ),
      ],
    );
  }
}

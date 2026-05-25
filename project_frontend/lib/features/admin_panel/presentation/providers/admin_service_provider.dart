import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_service_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminServiceProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminServiceProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> salvarNovoServico({
    required String nome,
    required String preco,
    required String tempoEstimado,
    required XFile? imagem,
  }) async {
    if (nome.isEmpty || preco.isEmpty || tempoEstimado.isEmpty) {
      debugPrint("Erro: Preencha todos os campos.");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final novoServico = AdminServiceModel(
      nome: nome,
      preco: preco,
      tempoEstimado: tempoEstimado,
      imagePath: imagem?.path,
    );

    final result = await _repository.salvarServico(novoServico, imagem);

    _isLoading = false;
    notifyListeners();

    return result.fold(
      (failure) {
        debugPrint("Erro na camada de dados: ${failure.message}");
        return false;
      },
      (success) {
        debugPrint("Serviço salvo com sucesso!");
        return true;
      },
    );
  }
}

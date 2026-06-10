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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminServiceModel> _servicos = [];
  List<AdminServiceModel> get servicos => _servicos;

  Future<void> fetchServicos() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getServicos();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (lista) => _servicos = lista,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deletarServico(int id) async {
    final result = await _repository.deletarServico(id);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _servicos.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> salvarNovoServico({
    required String nome,
    required String preco,
    required String tempoEstimado,
    String? descricao,
    XFile? imagem,
  }) async {
    if (nome.isEmpty || preco.isEmpty || tempoEstimado.isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final double precoConvertido = double.tryParse(preco) ?? 0.0;
    final int tempoConvertido = int.tryParse(tempoEstimado) ?? 0;

    final novoServico = AdminServiceModel(
      name: nome,
      price: precoConvertido,
      durationMinutes: tempoConvertido,
      description: descricao,
    );

    final result = await _repository.salvarServico(novoServico, imagem);

    _isLoading = false;

    return result.fold(
      (failure) {
        debugPrint("Erro na camada de dados: ${failure.message}");
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        debugPrint("Serviço salvo com sucesso!");
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> atualizarServico({
    required int id,
    required String nome,
    required String preco,
    required String tempoEstimado,
    String? descricao,
    XFile? imagem,
  }) async {
    if (nome.isEmpty || preco.isEmpty || tempoEstimado.isEmpty) {
      _errorMessage = 'Preencha todos os campos obrigatórios.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final double precoConvertido = double.tryParse(preco) ?? 0.0;
    final int tempoConvertido = int.tryParse(tempoEstimado) ?? 0;

    final servicoAtualizado = AdminServiceModel(
      id: id,
      name: nome,
      price: precoConvertido,
      durationMinutes: tempoConvertido,
      description: descricao,
    );

    final result =
        await _repository.atualizarServico(id, servicoAtualizado, imagem);

    _isLoading = false;

    return result.fold(
      (failure) {
        debugPrint("Erro ao atualizar: ${failure.message}");
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        debugPrint("Serviço atualizado com sucesso!");
        notifyListeners();
        return true;
      },
    );
  }
}

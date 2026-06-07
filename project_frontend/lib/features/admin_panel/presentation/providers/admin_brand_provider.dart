import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_brand_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminBrandProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminBrandProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminBrandModel> _marcas = [];
  List<AdminBrandModel> get marcas => _marcas;

  Future<void> fetchMarcas() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getMarcas();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (lista) => _marcas = lista,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> salvarNovaMarca({required String nome, XFile? imagem}) async {
    if (nome.isEmpty) {
      _errorMessage = 'O nome da marca é obrigatório.';
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result =
        await _repository.salvarMarca(AdminBrandModel(name: nome), imagem);
    _isLoading = false;
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> atualizarMarca(
      {required int id, required String nome, XFile? imagem}) async {
    if (nome.isEmpty) {
      _errorMessage = 'O nome da marca é obrigatório.';
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.atualizarMarca(
        id, AdminBrandModel(id: id, name: nome), imagem);
    _isLoading = false;
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deletarMarca(int id) async {
    final result = await _repository.deletarMarca(id);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (s) {
        _marcas.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      },
    );
  }
}

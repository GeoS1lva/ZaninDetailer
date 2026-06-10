import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/showcase_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminShowcaseProvider extends ChangeNotifier {
  final IAdminRepository _repository;
  final _picker = ImagePicker();

  AdminShowcaseProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ShowcaseModel> _vitrines = [];
  List<ShowcaseModel> get vitrines => _vitrines;
  bool get podeAdicionar => _vitrines.length < 5;

  Future<void> fetchVitrines() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getVitrines();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (lista) => _vitrines = lista,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> adicionarVitrine() async {
    final imagem =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (imagem == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.criarVitrine(imagem);
    final sucesso = result.fold((f) {
      _errorMessage = f.message;
      return false;
    }, (_) => true);

    if (sucesso) await fetchVitrines();
    _isLoading = false;
    notifyListeners();
    return sucesso;
  }

  Future<bool> substituirVitrine(int id) async {
    final imagem =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (imagem == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.atualizarVitrine(id, imagem);
    final sucesso = result.fold((f) {
      _errorMessage = f.message;
      return false;
    }, (_) => true);

    if (sucesso) await fetchVitrines();
    _isLoading = false;
    notifyListeners();
    return sucesso;
  }

  Future<bool> deletarVitrine(int id) async {
    final result = await _repository.deletarVitrine(id);
    return result.fold(
      (f) {
        _errorMessage = f.message;
        notifyListeners();
        return false;
      },
      (_) {
        _vitrines.removeWhere((v) => v.id == id);
        notifyListeners();
        return true;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_brand_model.dart';

class AdminBrandProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> salvarNovaMarca({required XFile? imagem}) async {
    if (imagem == null) {
      print("Erro: Selecione a logo da marca.");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final novaMarca = AdminBrandModel(imagePath: imagem.path);

    await Future.delayed(const Duration(seconds: 2));

    print("Enviando logo para a API: ${novaMarca.toJson()}");

    _isLoading = false;
    notifyListeners();

    return true;
  }
}

import 'package:flutter/material.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repository;

  AuthProvider({required IAuthRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Preencha todos os campos.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(email, password);

    bool isSuccess = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        isSuccess = false;
      },
      (loginData) {
        isSuccess = true;
      },
    );

    _isLoading = false;
    notifyListeners();

    return isSuccess;
  }

  Future<bool> forgotPassword(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Digite seu e-mail para recuperar a senha.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.passwordReset(email);
    bool isSuccess = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        isSuccess = false;
      },
      (success) => isSuccess = true,
    );

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<bool> updatePassword(String token, String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 6) {
      _errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.passwordUpdate(token, newPassword);
    bool isSuccess = false;

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        isSuccess = false;
      },
      (success) => isSuccess = true,
    );

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

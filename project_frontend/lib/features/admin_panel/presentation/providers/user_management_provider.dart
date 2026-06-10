import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_management_repository_impl.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRepository _repository;

  UserManagementProvider({required UserManagementRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getUsers();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (userList) {
        _users = userList;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser(
      String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createUser(email, password, fullName);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (newUser) {
        _users.add(newUser);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteUser(String userId) async {
    final result = await _repository.deleteUser(userId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _users.removeWhere((user) => user.id == userId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateUser(String userId,
      {String? fullName, String? password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateUser(userId,
        fullName: fullName, password: password);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (updatedUser) {
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../features/admin_panel/data/models/user_model.dart';

class UserManagementRepository {
  final ApiClient _apiClient;

  UserManagementRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;

        if (detail is List && detail.isNotEmpty) {
          return detail[0]['msg'] ?? 'Erro de validação nos dados.';
        }
      }
    }
    return 'Erro inesperado ao conectar com o servidor.';
  }

  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('/admin/users');
      final List<dynamic> usersJson = response.data['users'] ?? [];
      final users = usersJson.map((json) => UserModel.fromJson(json)).toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  Future<Either<Failure, UserModel>> createUser(
      String email, String password, String fullName) async {
    try {
      final response = await _apiClient.dio.post(
        '/admin/users',
        data: {'email': email, 'password': password, 'full_name': fullName},
      );
      return Right(UserModel.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      await _apiClient.dio.delete('/admin/users/$userId');
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  Future<Either<Failure, UserModel>> updateUser(String userId,
      {String? fullName, String? password}) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) data['full_name'] = fullName;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await _apiClient.dio.patch(
        '/admin/users/$userId',
        data: data,
      );
      return Right(UserModel.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }
}

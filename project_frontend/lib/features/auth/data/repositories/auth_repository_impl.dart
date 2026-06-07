import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required FlutterSecureStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<Either<Failure, LoginResponseModel>> login(
      String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      if (accessToken != null) {
        await _storage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }

      return Right(LoginResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        return Left(ServerFailure('E-mail ou senha incorretos.'));
      }
      return Left(ServerFailure('Erro ao conectar ao servidor.'));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado.'));
    }
  }

  @override
  Future<Either<Failure, bool>> passwordReset(String email) async {
    try {
      await _apiClient.dio.post(
        '/auth/password-reset',
        data: {"email": email},
      );
      return const Right(true);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 422) {
        return Left(ServerFailure('E-mail não encontrado ou inválido.'));
      }
      return Left(ServerFailure('Erro ao solicitar redefinição.'));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado.'));
    }
  }

  @override
  Future<Either<Failure, bool>> passwordUpdate(
      String token, String newPassword) async {
    try {
      await _apiClient.dio.post(
        '/auth/password-update',
        data: {"access_token": token, "new_password": newPassword},
      );
      return const Right(true);
    } on DioException catch (_) {
      return Left(ServerFailure('Link expirado ou inválido. Tente novamente.'));
    } catch (e) {
      return Left(ServerFailure('Ocorreu um erro inesperado.'));
    }
  }
}

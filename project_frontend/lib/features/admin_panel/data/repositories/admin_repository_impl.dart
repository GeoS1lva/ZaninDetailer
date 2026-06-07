import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../models/admin_service_model.dart';
import '../models/admin_brand_model.dart';
import '../models/admin_agenda_model.dart';
import '../models/user_model.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final ApiClient _apiClient;

  AdminRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail[0]['msg'] ?? 'Erro de validação.';
        }
      }
    }
    return 'Erro inesperado ao conectar com o servidor.';
  }

  @override
  Future<Either<Failure, UserModel>> getMeuPerfil() async {
    try {
      final response = await _apiClient.dio.get('/admin/users/me');
      return Right(UserModel.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> salvarServico(
      AdminServiceModel servico, XFile? imagem) async {
    try {
      final formData = FormData.fromMap({
        'name': servico.name,
        'price': servico.price,
        'duration_minutes': servico.durationMinutes,
        'description': servico.description ?? '',
      });

      if (imagem != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            imagem.path,
            filename: imagem.name,
          ),
        ));
      }

      await _apiClient.dio.post('/services/', data: formData);

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> atualizarServico(
      int id, AdminServiceModel servico, XFile? imagem) async {
    try {
      final formData = FormData.fromMap({
        'name': servico.name,
        'price': servico.price,
        'duration_minutes': servico.durationMinutes,
        'description': servico.description ?? '',
      });

      if (imagem != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imagem.path, filename: imagem.name),
        ));
      }

      await _apiClient.dio.patch('/services/$id', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<AdminAgendaModel>>> getAgendamentosHoje() async {
    try {
      const dataFormatada = '2026-06-06';

      final response = await _apiClient.dio.get(
        '/appointments/',
        queryParameters: {'date': dataFormatada},
      );

      final List<dynamic> jsonList = response.data;
      final agendamentos =
          jsonList.map((json) => AdminAgendaModel.fromJson(json)).toList();

      return Right(agendamentos);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<AdminServiceModel>>> getServicos() async {
    try {
      final response = await _apiClient.dio.get('/services/');

      final List<dynamic> items = response.data['items'] ?? [];
      final servicos =
          items.map((json) => AdminServiceModel.fromJson(json)).toList();
      return Right(servicos);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> deletarServico(int id) async {
    try {
      await _apiClient.dio.delete('/services/$id');
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<AdminBrandModel>>> getMarcas() async {
    try {
      final response = await _apiClient.dio.get('/brands/');
      final List<dynamic> items = response.data['items'] ?? [];
      return Right(
          items.map((json) => AdminBrandModel.fromJson(json)).toList());
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> salvarMarca(
      AdminBrandModel marca, XFile? imagem) async {
    try {
      final formData = FormData.fromMap({'name': marca.name});
      if (imagem != null) {
        formData.files.add(MapEntry('image',
            await MultipartFile.fromFile(imagem.path, filename: imagem.name)));
      }
      await _apiClient.dio.post('/brands/', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> atualizarMarca(
      int id, AdminBrandModel marca, XFile? imagem) async {
    try {
      final formData = FormData.fromMap({'name': marca.name});
      if (imagem != null) {
        formData.files.add(MapEntry('image',
            await MultipartFile.fromFile(imagem.path, filename: imagem.name)));
      }
      await _apiClient.dio.patch('/brands/$id', data: formData);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> deletarMarca(int id) async {
    try {
      await _apiClient.dio.delete('/brands/$id');
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }
}

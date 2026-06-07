import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../data/models/service_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices() async {
    try {
      final response = await _apiClient.dio.get('/services/');
      final dynamic responseData = response.data;
      final List<dynamic> servicesJson = responseData is List
          ? responseData
          : (responseData['services'] ?? []);

      final services = servicesJson
          .map<ServiceModel>(
              (json) => ServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar serviços.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLastWorks() async {
    try {
      final response = await _apiClient.dio.get('/services/');
      final dynamic responseData = response.data;
      final List<dynamic> worksJson = responseData is List
          ? responseData
          : (responseData['services'] ?? []);

      final lastWorks = worksJson.map<String>((json) {
        final workMap = json as Map<String, dynamic>;
        return workMap['name'] as String? ??
            workMap['title'] as String? ??
            workMap.toString();
      }).toList();

      return Right(lastWorks);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar últimos trabalhos.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableSlots(
      int serviceId, String date) async {
    try {
      final response = await _apiClient.dio
          .get('/appointments/available-slots', queryParameters: {
        'service_id': serviceId,
        'date': date,
      });

      final List<dynamic> slotsJson = response.data['slots'] ?? [];
      final List<String> availableTimes = slotsJson.map<String>((slot) {
        DateTime start = DateTime.parse(slot['start']).toLocal();
        return "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
      }).toList();

      return Right(availableTimes);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar horários disponíveis.'));
    }
  }

  @override
  Future<Either<Failure, String>> submitBooking({
    required int serviceId,
    required String scheduledStartIso,
    required String clientName,
    required String whatsapp,
    required String licensePlate,
    required String vehicleModel,
  }) async {
    try {
      final requestData = {
        "service_id": serviceId,
        "scheduled_start": scheduledStartIso,
        "client": {
          "full_name": clientName,
          "phone": whatsapp,
          "license_plate": licensePlate,
          "vehicle_brand_model": vehicleModel
        }
      };

      final response =
          await _apiClient.dio.post('/appointments/', data: requestData);

      final token = response.data['cancellation_token'] ?? '';
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Erro ao confirmar o agendamento.'));
    }
  }
}

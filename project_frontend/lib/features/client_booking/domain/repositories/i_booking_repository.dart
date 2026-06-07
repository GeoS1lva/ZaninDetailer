import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/service_model.dart';

abstract class IBookingRepository {
  Future<Either<Failure, List<ServiceModel>>> getServices();
  Future<Either<Failure, List<String>>> getLastWorks();

  Future<Either<Failure, List<String>>> getAvailableSlots(
      int serviceId, String date);

  Future<Either<Failure, String>> submitBooking({
    required int serviceId,
    required String scheduledStartIso,
    required String clientName,
    required String whatsapp,
    required String licensePlate,
    required String vehicleModel,
  });
}

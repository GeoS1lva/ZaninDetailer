import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/service_model.dart';
import '../../data/models/appointment_model.dart';


abstract class IBookingRepository {
  Future<Either<Failure, List<ServiceModel>>> getServices();
  Future<Either<Failure, List<String>>> getLastWorks();

  Future<Either<Failure, List<String>>> getAvailableSlots(
      int serviceId, String date);

  Future<Either<Failure, AppointmentModel>> getAppointmentDetails(int appointmentId);

  
Future<Either<Failure, AppointmentModel>> submitBooking({
    required int serviceId,
    required String scheduledStartIso,
    required String clientName,
    required String whatsapp,
    required String licensePlate,
    required String vehicleModel,
  });
  Future<Either<Failure, List<String>>> getBrands();

  Future<Either<Failure, Unit>> cancelBooking({
    required int appointmentId,
    required String cancellationToken,
    required String reason,
  });
}

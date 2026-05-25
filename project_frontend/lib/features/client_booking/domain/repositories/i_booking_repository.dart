import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/service_model.dart';

abstract class IBookingRepository {
  Future<Either<Failure, List<ServiceModel>>> getServices();

  Future<Either<Failure, List<String>>> getLastWorks();

  Future<Either<Failure, bool>> submitBooking({
    required ServiceModel service,
    required DateTime date,
    required String time,
  });
}

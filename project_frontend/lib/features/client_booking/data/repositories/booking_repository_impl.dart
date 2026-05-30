import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../data/models/service_model.dart';
import '../../../../core/error/failures.dart';

class BookingRepositoryImpl implements IBookingRepository {
  @override
  Future<Either<Failure, List<ServiceModel>>> getServices() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final mockServices = [
        ServiceModel(
            title: 'Lavagem Essencial',
            duration: '1h 30m',
            price: 8000,
            imageUrl: 'assets/images/welcome_car.jpg'),
        ServiceModel(
            title: 'Polimento Comercial',
            duration: '4h',
            price: 35000,
            imageUrl: 'assets/images/welcome_car.jpg'),
        ServiceModel(
            title: 'Vitrificação de Pintura',
            duration: '12h',
            price: 120000,
            imageUrl: 'assets/images/welcome_car.jpg'),
      ];

      return Right(mockServices);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar o catálogo de serviços: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLastWorks() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockWorks = [
        'assets/images/welcome_car.jpg',
        'assets/images/welcome_car.jpg',
        'assets/images/welcome_car.jpg',
      ];

      return Right(mockWorks);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar o portefólio.'));
    }
  }

  @override
  Future<Either<Failure, bool>> submitBooking({
    required ServiceModel service,
    required DateTime date,
    required String time,
    required String clientName,
    required String whatsapp,
    required String licensePlate,
    required String vehicleModel,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Erro ao confirmar o agendamento.'));
    }
  }
}

import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../data/models/service_model.dart';
import '../../../../core/error/failures.dart'; // Import central de erros

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
          imageUrl: 'assets/images/welcome_car.jpg' 
        ),
        ServiceModel(
          title: 'Polimento Comercial', 
          duration: '4h', 
          price: 35000, 
          imageUrl: 'assets/images/welcome_car.jpg'
        ),
        ServiceModel(
          title: 'Vitrificação de Pintura', 
          duration: '12h', 
          price: 120000, 
          imageUrl: 'assets/images/welcome_car.jpg'
        ),
      ];

      return Right(mockServices);
    } catch (e) {
      // Usando ServerFailure em vez de Failure
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
      // Usando ServerFailure
      return Left(ServerFailure('Erro ao carregar o portefólio.'));
    }
  }

  @override
  Future<Either<Failure, bool>> submitBooking({
    required ServiceModel service,
    required DateTime date,
    required String time,
  }) async {
    try {
      print("📦 [Booking Repository] A enviar dados de agendamento para a API...");
      await Future.delayed(const Duration(seconds: 2));
      print("✅ [Booking Repository] Agendamento registado com sucesso na API!");
      
      return const Right(true);
    } catch (e) {
      // Usando ServerFailure
      return Left(ServerFailure('Erro ao confirmar o agendamento. Tente novamente.'));
    }
  }
}
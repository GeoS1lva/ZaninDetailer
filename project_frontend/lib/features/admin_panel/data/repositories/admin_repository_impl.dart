import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../models/admin_service_model.dart';
import '../models/admin_agenda_model.dart';
import '../../../../core/error/failures.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final String baseUrl = 'URL_DA_API_AQUI';

  @override
  Future<Either<Failure, bool>> salvarServico(AdminServiceModel servico, XFile? imagem) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure("Erro ao conectar com o servidor"));
    }
  }

  @override
  Future<Either<Failure, List<AdminAgendaModel>>> getAgendamentosHoje() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock de loading
      final mockData = [
        AdminAgendaModel(
          id: '1',
          veiculo: 'VW Nivus',
          placa: 'ABC-1234',
          cliente: 'Vitor',
          servico: 'Lavagem Essencial',
          status: 'PENDENTE',
        ),
      ];
      return Right(mockData);
    } catch (e) {
      return Left(ServerFailure("Erro ao buscar a agenda do dia."));
    }
  }

  @override
  Future<Either<Failure, bool>> concluirServico(String id) async {
    try {
      print("📦 [API] Marcando serviço $id como concluído...");
      await Future.delayed(const Duration(seconds: 1));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure("Erro ao concluir o serviço."));
    }
  }
}
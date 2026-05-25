import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../models/admin_service_model.dart';
import '../../../../core/error/failures.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final String baseUrl = 'URL_DA_API_AQUI';

  @override
  Future<Either<Failure, bool>> salvarServico(
      AdminServiceModel servico, XFile? imagem) async {
    try {
      print("📦 [Repository] Preparando conexão com a API...");

      await Future.delayed(const Duration(seconds: 2));

      print("✅ [Repository] Sucesso!");
      return const Right(true);
    } catch (e) {
      print("❌ [Repository] Erro: $e");

      return Left(ServerFailure("Erro ao conectar com o servidor"));
    }
  }
}

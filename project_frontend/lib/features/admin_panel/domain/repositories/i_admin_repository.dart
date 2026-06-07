import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_service_model.dart';
import '../../data/models/admin_agenda_model.dart';
import '../../data/models/admin_brand_model.dart';
import '../../data/models/user_model.dart';

abstract class IAdminRepository {
  Future<Either<Failure, UserModel>> getMeuPerfil();
  Future<Either<Failure, List<AdminAgendaModel>>> getAgendamentosHoje();

  Future<Either<Failure, List<AdminServiceModel>>> getServicos();
  Future<Either<Failure, bool>> salvarServico(
      AdminServiceModel servico, XFile? imagem);
  Future<Either<Failure, bool>> deletarServico(int id);
  Future<Either<Failure, bool>> atualizarServico(
      int id, AdminServiceModel servico, XFile? imagem);

  Future<Either<Failure, List<AdminBrandModel>>> getMarcas();
  Future<Either<Failure, bool>> salvarMarca(
      AdminBrandModel marca, XFile? imagem);
  Future<Either<Failure, bool>> atualizarMarca(
      int id, AdminBrandModel marca, XFile? imagem);
  Future<Either<Failure, bool>> deletarMarca(int id);
}

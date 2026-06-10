import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_service_model.dart';
import '../../data/models/admin_agenda_model.dart';
import '../../data/models/admin_brand_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/showcase_model.dart';

abstract class IAdminRepository {
  Future<Either<Failure, UserModel>> getMeuPerfil();
  Future<Either<Failure, List<AdminAgendaModel>>> getAgendamentosHoje(
      DateTime data);

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

  Future<Either<Failure, bool>> reagendarAgendamento(
      int appointmentId, String novoHorarioIso);
  Future<Either<Failure, bool>> cancelarAgendamento(
      int appointmentId, String motivo);
  Future<Either<Failure, bool>> concluirAgendamento(int appointmentId);
  Future<Either<Failure, bool>> atualizarDadosCliente({
    required int appointmentId,
    required String fullName,
    required String phone,
    required String licensePlate,
    required String vehicleBrandModel,
  });

  Future<Either<Failure, List<ShowcaseModel>>> getVitrines();
  Future<Either<Failure, bool>> criarVitrine(XFile imagem);
  Future<Either<Failure, bool>> atualizarVitrine(int id, XFile imagem);
  Future<Either<Failure, bool>> deletarVitrine(int id);
}

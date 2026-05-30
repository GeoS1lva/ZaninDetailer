import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/admin_service_model.dart';
import '../../data/models/admin_agenda_model.dart';

abstract class IAdminRepository {
  Future<Either<Failure, bool>> salvarServico(
      AdminServiceModel servico, XFile? imagem);

  Future<Either<Failure, List<AdminAgendaModel>>> getAgendamentosHoje();
  Future<Either<Failure, bool>> concluirServico(String id);
}

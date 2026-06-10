import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/login_response_model.dart';

abstract class IAuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(
      String email, String password);
  Future<Either<Failure, bool>> passwordReset(String email);
  Future<Either<Failure, bool>> passwordUpdate(
      String token, String newPassword);
}

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class IUserManagementRepository {
  Future<Either<Failure, List<UserModel>>> getUsers();

  Future<Either<Failure, UserModel>> createUser(Map<String, dynamic> userData);

  Future<Either<Failure, UserModel>> updateUser(
      String id, Map<String, dynamic> userData);

  Future<Either<Failure, bool>> deleteUser(String id);
}

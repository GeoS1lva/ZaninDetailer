abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = "Erro interno no servidor."]);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = "Sem conexão com a internet."]);
}

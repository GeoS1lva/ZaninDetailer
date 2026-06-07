class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String email;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      userId: json['user_id'],
      email: json['email'],
    );
  }
}

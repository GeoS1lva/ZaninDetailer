class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? createdAt;
  final String? lastSignInAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.createdAt,
    this.lastSignInAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      createdAt: json['created_at'],
      lastSignInAt: json['last_sign_in_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt,
      'last_sign_in_at': lastSignInAt,
    };
  }
}

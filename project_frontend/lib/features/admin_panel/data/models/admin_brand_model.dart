class AdminBrandModel {
  final int id;
  final String name;
  final String? imageUrl;

  AdminBrandModel({
    this.id = 0,
    required this.name,
    this.imageUrl,
  });

  factory AdminBrandModel.fromJson(Map<String, dynamic> json) {
    return AdminBrandModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class ShowcaseModel {
  final int id;
  final String imageUrl;
  final String? createdAt;
  final String? updatedAt;

  ShowcaseModel({
    required this.id,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ShowcaseModel.fromJson(Map<String, dynamic> json) {
    return ShowcaseModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AdminServiceModel {
  final int id;
  final String name;
  final double price;
  final int durationMinutes;
  final String? description;
  final String? imageUrl;
  final String? durationDisplay;

  AdminServiceModel({
    this.id = 0,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description,
    this.imageUrl,
    this.durationDisplay,
  });

  factory AdminServiceModel.fromJson(Map<String, dynamic> json) {
    return AdminServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 0,
      description: json['description'],
      imageUrl: json['image_url'],
      durationDisplay: json['duration_display'],
    );
  }
}

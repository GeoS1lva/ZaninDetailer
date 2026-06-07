class ServiceModel {
  final int id;
  final String title;
  final String duration;
  final double price;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    required this.imageUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      duration: json['duration_display'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class WorkModel {
  final String imageUrl;
  WorkModel({required this.imageUrl});
}

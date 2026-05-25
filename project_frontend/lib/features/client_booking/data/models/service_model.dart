class ServiceModel {
  final String title;
  final String duration;
  final int price;
  final String imageUrl;

  ServiceModel({
    required this.title,
    required this.duration,
    required this.price,
    required this.imageUrl,
  });
}

class WorkModel {
  final String imageUrl;

  WorkModel({required this.imageUrl});
}

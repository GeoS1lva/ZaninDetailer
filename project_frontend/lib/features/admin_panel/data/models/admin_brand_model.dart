class AdminBrandModel {
  final String? imagePath;

  AdminBrandModel({required this.imagePath});

  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
    };
  }
}
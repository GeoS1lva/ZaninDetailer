class AdminServiceModel {
  final String nome;
  final String preco;
  final String tempoEstimado;

  final String? imagePath;

  AdminServiceModel({
    required this.nome,
    required this.preco,
    required this.tempoEstimado,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'preco': preco,
      'tempo_estimado': tempoEstimado,
      'image_path': imagePath,
    };
  }
}

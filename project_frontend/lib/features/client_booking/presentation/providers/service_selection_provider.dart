import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String duration;
  final String price;
  final String imageUrl;

  ServiceModel({required this.id, required this.title, required this.duration, required this.price, required this.imageUrl});
}

class WorkModel {
  final String id;
  final String imageUrl;
  WorkModel({required this.id, required this.imageUrl});
}

class ServiceSelectionProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ServiceModel> services = [];
  List<String> brandLogos = []; 
  List<WorkModel> lastWorks = [];

  Future<void> fetchApiData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    services = [
      ServiceModel(id: '1', title: 'Lavagem Essencial', duration: '2h', price: '80,00', imageUrl: 'assets/images/essencial2.jpg'),
      ServiceModel(id: '2', title: 'Lavagem Técnica', duration: '3h', price: '100 - R\$ 110', imageUrl: 'assets/images/welcome_car.jpg'),
    ];

    brandLogos = [
      'assets/images/logo_vonixx.jpg', 
    ];

    lastWorks = [
      WorkModel(id: 'w1', imageUrl: 'assets/images/gol.jpg'),
      WorkModel(id: 'w2', imageUrl: 'assets/images/fit.jpg'),
      WorkModel(id: 'w3', imageUrl: 'assets/images/palio.jpg'),
      WorkModel(id: 'w4', imageUrl: 'assets/images/argo.jpg'),
    ];

    isLoading = false;
    notifyListeners();
  }
}
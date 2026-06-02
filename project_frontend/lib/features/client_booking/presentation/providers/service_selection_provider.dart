import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import '../../data/models/service_model.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../../../core/error/failures.dart';

class ServiceSelectionProvider extends ChangeNotifier {
  final IBookingRepository _repository;

  ServiceSelectionProvider({required IBookingRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  List<String> _lastWorks = [];
  List<String> get lastWorks => _lastWorks;

  final List<String> brandLogos = [
    'assets/images/logo_vonixx.jpg',
  ];

  Future<void> fetchApiData() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repository.getServices(),
      _repository.getLastWorks(),
    ]);

    final servicesResult = results[0] as Either<Failure, List<ServiceModel>>;
    final worksResult = results[1] as Either<Failure, List<String>>;

    servicesResult.fold(
      (failure) => debugPrint("Erro ao carregar serviços: ${failure.message}"),
      (servicesData) => _services = servicesData,
    );

    worksResult.fold(
      (failure) => debugPrint("Erro ao carregar trabalhos: ${failure.message}"),
      (worksData) => _lastWorks = worksData,
    );

    _isLoading = false;
    notifyListeners();
  }
}

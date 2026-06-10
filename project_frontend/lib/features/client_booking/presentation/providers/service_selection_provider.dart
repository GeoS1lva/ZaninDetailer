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

  List<String> _brandLogos = [];
  List<String> get brandLogos => _brandLogos;

  Future<void> fetchApiData() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _repository.getServices(),
      _repository.getLastWorks(),
      _repository.getBrands(),
    ]);

    final servicesResult = results[0] as Either<Failure, List<ServiceModel>>;
    final worksResult = results[1] as Either<Failure, List<String>>;
    final brandsResult = results[2] as Either<Failure, List<String>>;

    servicesResult.fold(
      (failure) => debugPrint("Erro ao carregar serviços: ${failure.message}"),
      (servicesData) => _services = servicesData,
    );

    worksResult.fold(
      (failure) => debugPrint("Erro ao carregar trabalhos: ${failure.message}"),
      (worksData) => _lastWorks = worksData,
    );

    brandsResult.fold(
      (failure) => debugPrint("Erro ao carregar marcas: ${failure.message}"),
      (brandsData) => _brandLogos = brandsData,
    );

    _isLoading = false;
    notifyListeners();
  }
}

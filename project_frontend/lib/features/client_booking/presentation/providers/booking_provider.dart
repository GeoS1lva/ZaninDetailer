import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/service_model.dart';
import '../../domain/repositories/i_booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final IBookingRepository _repository;

  BookingProvider({required IBookingRepository repository})
      : _repository = repository;

  ServiceModel? _selectedService;
  ServiceModel? get selectedService => _selectedService;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String? _selectedTime;
  String? get selectedTime => _selectedTime;

  bool _isLoadingHours = false;
  bool get isLoadingHours => _isLoadingHours;

  List<String> _availableHours = [];
  List<String> get availableHours => _availableHours;

  void setService(ServiceModel service) {
    _selectedService = service;
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTime = null;
    _fetchAvailableHours();
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  Future<void> _fetchAvailableHours() async {
    _isLoadingHours = true;
    _availableHours = [];
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_selectedDate.weekday == DateTime.saturday) {
      _availableHours = ['08:00', '09:00', '10:00', '11:00'];
    } else if (_selectedDate.weekday != DateTime.sunday) {
      _availableHours = ['08:00', '10:00', '13:00', '15:00', '17:00'];
    }

    _isLoadingHours = false;
    notifyListeners();
  }

  final nameController = TextEditingController();
  final vehicleController = TextEditingController();
  final plateController = TextEditingController();
  final whatsappController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> confirmBooking(
      ServiceModel service, DateTime date, String time) async {
    if (nameController.text.isEmpty ||
        whatsappController.text.isEmpty ||
        plateController.text.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _repository.submitBooking(
      service: service,
      date: date,
      time: time,
      clientName: nameController.text,
      whatsapp: whatsappController.text,
      licensePlate: plateController.text,
      vehicleModel: vehicleController.text.isEmpty
          ? "Não identificado"
          : vehicleController.text,
    );
    _isLoading = false;
    notifyListeners();

    return result.fold((failure) => false, (success) => true);
  }

  @override
  void dispose() {
    nameController.dispose();
    vehicleController.dispose();
    plateController.dispose();
    super.dispose();
  }
}

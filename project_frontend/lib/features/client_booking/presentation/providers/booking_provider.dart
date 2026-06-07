import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/service_model.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../../../../di/injection_container.dart' as di;

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

  final nameController = TextEditingController();
  final vehicleController = TextEditingController();
  final plateController = TextEditingController();
  final whatsappController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    if (_selectedService == null) return;

    _isLoadingHours = true;
    _availableHours = [];
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final result =
        await _repository.getAvailableSlots(_selectedService!.id, dateStr);

    result.fold(
      (failure) => _availableHours = [],
      (times) => _availableHours = times,
    );

    _isLoadingHours = false;
    notifyListeners();
  }

  Future<bool> confirmBooking(
      ServiceModel service, DateTime date, String time) async {
    if (nameController.text.isEmpty ||
        whatsappController.text.isEmpty ||
        plateController.text.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final timeParts = time.split(':');
    final combinedDate = DateTime(date.year, date.month, date.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]));

    final isoDateStr =
        "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(combinedDate)}-03:00";

    final result = await _repository.submitBooking(
      serviceId: service.id,
      scheduledStartIso: isoDateStr,
      clientName: nameController.text.trim(),
      whatsapp: whatsappController.text.trim(),
      licensePlate: plateController.text.trim(),
      vehicleModel: vehicleController.text.isEmpty
          ? "Não identificado"
          : vehicleController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    return result.fold((failure) {
      debugPrint("Erro no agendamento: ${failure.message}");
      return false;
    }, (cancellationToken) async {
      final storage = di.sl<FlutterSecureStorage>();

      await storage.write(key: 'last_booking_token', value: cancellationToken);
      return true;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    vehicleController.dispose();
    plateController.dispose();
    whatsappController.dispose();
    super.dispose();
  }
}

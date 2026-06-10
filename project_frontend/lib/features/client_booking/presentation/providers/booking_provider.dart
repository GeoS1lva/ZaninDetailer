import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/service_model.dart';
import '../../data/models/appointment_model.dart';
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setService(ServiceModel service) {
    _selectedService = service;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableHours();
    });
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

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final result =
          await _repository.getAvailableSlots(_selectedService!.id, dateStr);

      result.fold(
        (failure) => _availableHours = [],
        (times) => _availableHours = times,
      );
    } catch (e) {
      debugPrint("Erro interno ao formatar data ou buscar slots: $e");
      _availableHours = [];
    }

    _isLoadingHours = false;
    notifyListeners();
  }

  Future<bool> confirmBooking(
      ServiceModel service, DateTime date, String time) async {
    if (nameController.text.isEmpty ||
        whatsappController.text.isEmpty ||
        plateController.text.isEmpty) {
      _errorMessage = 'Preencha os campos de Nome, WhatsApp e Placa.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
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

      return await result.fold((failure) {
        debugPrint("Erro no agendamento: ${failure.message}");
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      }, (appointmentResponse) async {
        final storage = di.sl<FlutterSecureStorage>();

        String? savedData = await storage.read(key: 'my_local_appointments');
        List<dynamic> localAppointments =
            savedData != null ? jsonDecode(savedData) : [];

        localAppointments.add({
          'id': appointmentResponse.id,
          'token': appointmentResponse.cancellationToken,
        });

        await storage.write(
            key: 'my_local_appointments', value: jsonEncode(localAppointments));

        return true;
      });
    } catch (e) {
      debugPrint("Erro fatal no confirmBooking: $e");
      _errorMessage = 'Erro inesperado ao confirmar o agendamento.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    vehicleController.dispose();
    plateController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _myAppointments = [];
  List<AppointmentModel> get myAppointments => _myAppointments;

  Future<void> fetchMyAppointments() async {
    _isLoading = true;
    notifyListeners();

    final storage = di.sl<FlutterSecureStorage>();
    String? savedData = await storage.read(key: 'my_local_appointments');

    if (savedData == null) {
      _myAppointments = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    List<dynamic> localAppointments = jsonDecode(savedData);
    List<AppointmentModel> fetchedAppointments = [];

    for (var item in localAppointments) {
      final int id = item['id'];
      final result = await _repository.getAppointmentDetails(id);

      result.fold(
        (failure) => debugPrint("Erro ao buscar ID $id: ${failure.message}"),
        (appointment) {
          final appWithToken = AppointmentModel(
            id: appointment.id,
            serviceId: appointment.serviceId,
            scheduledStart: appointment.scheduledStart,
            scheduledEnd: appointment.scheduledEnd,
            status: appointment.status,
            totalPrice: appointment.totalPrice,
            cancellationToken: item['token'],
          );
          fetchedAppointments.add(appWithToken);
        },
      );
    }

    _myAppointments = fetchedAppointments.reversed.toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> executeCancellation(int appointmentId, String reason) async {
    final appointmentIndex =
        _myAppointments.indexWhere((app) => app.id == appointmentId);

    if (appointmentIndex == -1 ||
        _myAppointments[appointmentIndex].cancellationToken == null) {
      debugPrint("Token não encontrado para o ID $appointmentId");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final token = _myAppointments[appointmentIndex].cancellationToken!;

    final result = await _repository.cancelBooking(
      appointmentId: appointmentId,
      cancellationToken: token,
      reason: reason,
    );

    return result.fold(
      (failure) {
        debugPrint("Erro ao cancelar: ${failure.message}");
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) async {
        debugPrint("Agendamento cancelado com sucesso!");

        await fetchMyAppointments();
        return true;
      },
    );
  }
}

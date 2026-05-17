import 'package:flutter/material.dart';
import 'service_selection_provider.dart';

class BookingProvider extends ChangeNotifier {
  ServiceModel? selectedService;

  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  bool isLoadingHours = false;
  List<String> availableHours = [];

  void setService(ServiceModel service) {
    selectedService = service;
    selectedTime = null;
    fetchAvailableHours(selectedDate);
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    selectedTime = null;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  Future<void> fetchAvailableHours(DateTime date) async {
    isLoadingHours = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (date.weekday == DateTime.monday) {
      availableHours = [];
    } else if (date.weekday == DateTime.sunday) {
      availableHours = ['08:00', '09:00', '10:00', '11:00'];
    } else {
      availableHours = [
        '08:00',
        '09:30',
        '11:00',
        '13:00',
        '14:30',
        '16:00',
        '17:30'
      ];
    }

    isLoadingHours = false;
    notifyListeners();
  }
}

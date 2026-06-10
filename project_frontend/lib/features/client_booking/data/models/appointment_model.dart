class AppointmentModel {
  final int id;
  final int serviceId;
  final String scheduledStart;
  final String scheduledEnd;
  final String status;
  final String totalPrice;
  final String? cancellationToken;

  AppointmentModel({
    required this.id,
    required this.serviceId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    required this.totalPrice,
    this.cancellationToken,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      scheduledStart: json['scheduled_start'] ?? '',
      scheduledEnd: json['scheduled_end'] ?? '',
      status: json['status'] ?? 'pendente',
      totalPrice: json['total_price']?.toString() ?? '0.00',
      cancellationToken: json['cancellation_token'],
    );
  }
}
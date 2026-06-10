class AdminAgendaModel {
  final String id;
  final String veiculo;
  final String placa;
  final String cliente;
  final String telefone;
  final int serviceId;
  final String servico;
  final String status;

  final DateTime? scheduledStart;
  final double? totalPrice;

  AdminAgendaModel({
    required this.id,
    required this.veiculo,
    required this.placa,
    required this.cliente,
    required this.telefone,
    required this.serviceId,
    required this.servico,
    required this.status,
    this.scheduledStart,
    this.totalPrice,
  });

  factory AdminAgendaModel.fromJson(Map<String, dynamic> json) {
    final clientMap = json['client'] ?? {};

    return AdminAgendaModel(
      id: json['id']?.toString() ?? '',
      veiculo: clientMap['vehicle_brand_model'] ?? 'Veículo não informado',
      placa: clientMap['license_plate'] ?? 'Sem placa',
      cliente: clientMap['full_name'] ?? 'Cliente não informado',
      telefone: clientMap['phone'] ?? '',
      serviceId: json['service_id'] ?? 0,
      servico: 'Serviço #${json['service_id'] ?? '?'}',
      status: json['status'] ?? 'pendente',
      scheduledStart: json['scheduled_start'] != null
          ? DateTime.tryParse(json['scheduled_start'])
          : null,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : 0.0,
    );
  }
}

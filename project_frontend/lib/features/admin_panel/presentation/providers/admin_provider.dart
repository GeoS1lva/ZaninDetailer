import 'package:flutter/material.dart';
import '../../data/models/admin_agenda_model.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AdminAgendaModel> _agendamentosHoje = [];
  List<AdminAgendaModel> get agendamentosHoje => _agendamentosHoje;

  String get totalAgendamentos =>
      _agendamentosHoje.length.toString().padLeft(2, '0');
  String get previsaoFaturamento => 'R\$ 450';

  Future<void> fetchAgendamentos() async {
    _isLoading = true;

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _agendamentosHoje = [
      AdminAgendaModel(
        id: '1',
        veiculo: 'VW Nivus',
        placa: 'ABC-1234',
        cliente: 'Vitor',
        servico: 'Lavagem Essencial',
        status: 'PENDENTE',
      ),
    ];

    _isLoading = false;

    notifyListeners();
  }

  Future<void> concluirServico(String id) async {
    print("Serviço $id marcado como concluído no banco de dados!");
  }
}

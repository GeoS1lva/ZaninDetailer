import 'package:flutter/material.dart';
import '../../data/models/admin_agenda_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AdminAgendaModel> _agendamentosHoje = [];
  List<AdminAgendaModel> get agendamentosHoje => _agendamentosHoje;

  String get totalAgendamentos =>
      _agendamentosHoje.length.toString().padLeft(2, '0');
  String get previsaoFaturamento => 'R\$ 450,00';

  Future<void> fetchAgendamentos() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getAgendamentosHoje();

    result.fold(
      (failure) => print("Erro: ${failure.message}"),
      (agenda) => _agendamentosHoje = agenda,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> concluirServico(String id) async {
    final result = await _repository.concluirServico(id);

    result.fold(
      (failure) => print("Erro ao concluir: ${failure.message}"),
      (success) {
        _agendamentosHoje.removeWhere((item) => item.id == id);
        notifyListeners();
      },
    );
  }
}

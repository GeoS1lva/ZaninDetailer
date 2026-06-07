import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/admin_agenda_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final IAdminRepository _repository;

  AdminProvider({required IAdminRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<AdminAgendaModel> _agendamentosHoje = [];
  List<AdminAgendaModel> get agendamentosHoje => _agendamentosHoje;

  String get totalAgendamentos =>
      _agendamentosHoje.length.toString().padLeft(2, '0');

  String get previsaoFaturamento {
    double total = 0.0;
    for (var agenda in _agendamentosHoje) {
      total += agenda.totalPrice ?? 0.0;
    }

    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(total);
  }

  Future<void> fetchMeuPerfil() async {
    final result = await _repository.getMeuPerfil();
    result.fold(
      (failure) => debugPrint("Erro ao carregar perfil: ${failure.message}"),
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );
  }

  Future<void> fetchAgendamentos() async {
    _isLoading = true;
    notifyListeners();

    await fetchMeuPerfil();

    final result = await _repository.getAgendamentosHoje();

    result.fold(
      (failure) {
        debugPrint("Erro: ${failure.message}");
        _agendamentosHoje = [];
      },
      (agenda) => _agendamentosHoje = agenda,
    );

    _isLoading = false;
    notifyListeners();
  }
}

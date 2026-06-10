import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/admin_agenda_model.dart';
import '../../data/models/admin_service_model.dart';
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

  List<AdminServiceModel> _servicos = [];

  DateTime _dataSelecionada = DateTime.now();
  DateTime get dataSelecionada => _dataSelecionada;

  Future<void> selecionarData(DateTime data) async {
    _dataSelecionada = data;
    await fetchAgendamentos();
  }

  List<AdminAgendaModel> get agendamentosAtivos => _agendamentosHoje
      .where((a) => !a.status.toLowerCase().contains('cancel'))
      .toList();

  String get totalAgendamentos =>
      agendamentosAtivos.length.toString().padLeft(2, '0');

  String get previsaoFaturamento {
    double total = 0.0;
    for (var agenda in agendamentosAtivos) {
      total += agenda.totalPrice ?? 0.0;
    }

    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(total);
  }

  String nomeServico(int serviceId) {
    for (final servico in _servicos) {
      if (servico.id == serviceId) return servico.name;
    }
    return 'Serviço #$serviceId';
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

    if (_servicos.isEmpty) {
      final servicosResult = await _repository.getServicos();
      servicosResult.fold((_) {}, (servicos) => _servicos = servicos);
    }

    final result = await _repository.getAgendamentosHoje(_dataSelecionada);

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

  String? _agendamentoErrorMessage;
  String? get agendamentoErrorMessage => _agendamentoErrorMessage;

  Future<bool> reagendarAgendamento(
      int appointmentId, DateTime novoHorario) async {
    _agendamentoErrorMessage = null;

    final isoDateStr =
        "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(novoHorario)}-03:00";

    final result =
        await _repository.reagendarAgendamento(appointmentId, isoDateStr);

    return result.fold((failure) {
      debugPrint("Erro ao reagendar agendamento: ${failure.message}");
      _agendamentoErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAgendamentos();
      return true;
    });
  }

  Future<bool> cancelarAgendamento(int appointmentId, String motivo) async {
    _agendamentoErrorMessage = null;

    final result = await _repository.cancelarAgendamento(appointmentId, motivo);

    return result.fold((failure) {
      debugPrint("Erro ao cancelar agendamento: ${failure.message}");
      _agendamentoErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAgendamentos();
      return true;
    });
  }

  Future<bool> concluirAgendamento(int appointmentId) async {
    _agendamentoErrorMessage = null;

    final result = await _repository.concluirAgendamento(appointmentId);

    return result.fold((failure) {
      debugPrint("Erro ao concluir agendamento: ${failure.message}");
      _agendamentoErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAgendamentos();
      return true;
    });
  }

  Future<bool> atualizarDadosCliente({
    required int appointmentId,
    required String fullName,
    required String phone,
    required String licensePlate,
    required String vehicleBrandModel,
  }) async {
    _agendamentoErrorMessage = null;

    final result = await _repository.atualizarDadosCliente(
      appointmentId: appointmentId,
      fullName: fullName,
      phone: phone,
      licensePlate: licensePlate,
      vehicleBrandModel: vehicleBrandModel,
    );

    return result.fold((failure) {
      debugPrint("Erro ao atualizar dados do cliente: ${failure.message}");
      _agendamentoErrorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) async {
      await fetchAgendamentos();
      return true;
    });
  }
}

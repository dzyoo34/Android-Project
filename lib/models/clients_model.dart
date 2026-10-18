import 'package:flutter/foundation.dart';
import '../data/client.dart';
import '../data/client_repository.dart';
import '../data/result.dart';

class ClientsModel extends ChangeNotifier {
  ClientsModel(this._repository); // хранилище приходит снаружи

  final ClientRepository _repository; // тип - интерфейс

  bool _loading = false;
  String? _error;
  List<Client> _clients = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Client> get clients => List.unmodifiable(_clients);

  // ищет клиента в загруженном списке, null - если нет
  Client? byId(int id) {
    for (final c in _clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _clients = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }

  // null - норм, текст - ошибка
  Future<String?> update(Client client) async {
    switch (await _repository.update(client)) {
      case Ok(:final value):
        _clients = _clients.map((c) => c.id == value.id ? value : c).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _clients = _clients.where((c) => c.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
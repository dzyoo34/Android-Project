import 'package:flutter/foundation.dart';
import '../data/client.dart';
import '../data/client_repository.dart';
import '../data/result.dart';

class ClientsModel extends ChangeNotifier {
  ClientsModel(this._repository); // хранилище приходит снаружи

  final ClientRepository _repository; // тип - интерфейс, а не конкретный класс

  static const _limit = 20;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  String _search = '';
  int _page = 1;
  List<Client> _clients = const [];

  bool get isLoading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  List<Client> get clients => List.unmodifiable(_clients);

  // ищет клиента в загруженном списке, null - если нет
  Client? byId(int id) {
    for (final c in _clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  // load() остаётся валидным; поиск запоминается и retry сохраняет фильтр
  Future<void> load({String? search}) async {
    _search = search ?? _search;
    _page = 1;
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll(
        page: 1, limit: _limit, search: _search)) {
      case Ok(:final value):
        _clients = value;
        _hasMore = value.length == _limit; // полная страница -> есть ещё
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return; // guard от дублей
    _loadingMore = true;

    switch (await _repository.fetchAll(
        page: _page + 1, limit: _limit, search: _search)) {
      case Ok(:final value):
        _page += 1;
        _clients = [..._clients, ...value];
        _hasMore = value.length == _limit;
      case Err():
        _hasMore = false;
    }

    _loadingMore = false;
    notifyListeners();
  }

  Future<String?> add(Client client) async {
    switch (await _repository.create(client)) {
      case Ok(:final value):
        _clients = [value, ..._clients];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  // null - успех, текст - ошибка
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
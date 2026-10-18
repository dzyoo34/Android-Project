import 'client.dart';
import 'client_repository.dart';
import 'mock_data.dart';
import 'result.dart';

class MockClientRepository implements ClientRepository {
  final List<Client> _clients = List.of(mockClients);
  int _nextId = 1000;
  bool simulateError = false; // включена авария - любой вызов падает

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер не отвечает — повторите попытку';
  static const _errNotFound = 'Клиент не существует';

  @override
  Future<Result<List<Client>>> fetchAll() async {
    await Future.delayed(_latency);
    if (simulateError) return Err(_errNetwork);
    return Ok(List.of(_clients));
  }

  @override
  Future<Result<Client>> fetchById(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return Err(_errNetwork);
    final index = _clients.indexWhere((c) => c.id == id);
    if (index == -1) return Err(_errNotFound);
    return Ok(_clients[index]);
  }

  @override
  Future<Result<Client>> create(Client client) async {
    await Future.delayed(_latency);
    if (simulateError) return Err(_errNetwork);
    final created = client.copyWith(id: _nextId++); // id даёт хранилище
    _clients.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Client>> update(Client client) async {
    await Future.delayed(_latency);
    if (simulateError) return Err(_errNetwork);
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index == -1) return Err(_errNotFound);
    _clients[index] = client;
    return Ok(client);
  }

  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return Err(_errNetwork);
    final index = _clients.indexWhere((c) => c.id == id);
    if (index == -1) return Err(_errNotFound);
    _clients.removeAt(index);
    return Ok(null);
  }
}
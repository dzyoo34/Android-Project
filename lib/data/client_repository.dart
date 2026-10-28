import 'client.dart';
import 'result.dart';

abstract class ClientRepository {
  Future<Result<List<Client>>> fetchAll(
      {int page = 1, int limit = 20, String? search});
  Future<Result<Client>> fetchById(int id);
  Future<Result<Client>> create(Client client);
  Future<Result<Client>> update(Client client);
  Future<Result<void>> delete(int id);
}
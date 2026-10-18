import 'client.dart';
import 'result.dart';

// что можно просить у хранилища, а не как оно это делает
abstract class ClientRepository {
  Future<Result<List<Client>>> fetchAll();
  Future<Result<Client>> fetchById(int id);
  Future<Result<Client>> create(Client client);
  Future<Result<Client>> update(Client client);
  Future<Result<void>> delete(int id);
}
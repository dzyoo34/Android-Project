import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../data/client.dart';
import '../models/clients_model.dart';
import '../models/notes_model.dart';
import '../widgets/status_badge.dart';

class ClientDetailScreen extends StatelessWidget {
  final int id;

  const ClientDetailScreen({super.key, required this.id});

  Future<void> _delete(BuildContext context, Client client) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить клиента?'),
        content: Text(client.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, удалить'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final error = await context.read<ClientsModel>().remove(client.id);
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    context.pop(); // клиента больше нет, экран уходит
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ClientsModel>();
    final notes = context.watch<NotesModel>().forClient(id);
    final client = model.byId(id);

    if (client == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: model.isLoading
              ? const CircularProgressIndicator()
              : const Text('Клиент не существует'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            client.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(stage: client.stage),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Контактное лицо'),
                  subtitle: Text(client.contactPerson),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Телефон'),
                  subtitle: Text(client.phone),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Последний визит'),
                  subtitle: Text(client.lastVisit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text('Позвонить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text('Маршрут'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/clients/${client.id}/note'),
            icon: const Icon(Icons.note_add),
            label: const Text('Добавить отчёт о визите'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _delete(context, client),
            icon: const Icon(Icons.delete),
            label: const Text('Удалить клиента'),
          ),
          const SizedBox(height: 24),
          Text(
            'История визитов',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (notes.isEmpty) const Text('Пока нет отчётов'),
          for (final note in notes)
            Card(
              child: ListTile(
                leading: note.imageUrl == null
                    ? null
                    : Image.network('$apiBase${note.imageUrl}',
                    width: 48, height: 48, fit: BoxFit.cover),
                title: Text(note.text),
                subtitle: Text('${note.date} · ${note.stage}'),
              ),
            ),
        ],
      ),
    );
  }
}
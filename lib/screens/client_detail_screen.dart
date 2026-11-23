import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../data/client.dart';
import '../models/clients_model.dart';
import '../models/notes_model.dart';
import '../theme.dart';

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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ClientsModel>();
    final notes = context.watch<NotesModel>().forClient(id);
    final client = model.byId(id);
    final scheme = Theme.of(context).colorScheme;

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

    final initial =
    client.name.isEmpty ? '?' : client.name.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Клиент')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // фиолетовая шапка с названием
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          client.stage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline, color: scheme.primary),
                  title: const Text('Контактное лицо'),
                  subtitle: Text(client.contactPerson),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined, color: scheme.primary),
                  title: const Text('Телефон'),
                  subtitle: Text(client.phone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                  Icon(Icons.calendar_today_outlined, color: scheme.primary),
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
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push('/clients/${client.id}/note'),
            icon: const Icon(Icons.note_add),
            label: const Text('Добавить отчёт о визите'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _delete(context, client),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Удалить клиента'),
          ),
          const SizedBox(height: 24),
          Text(
            'История визитов',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (notes.isEmpty) const Text('Пока нет отчётов'),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: note.imageUrl == null
                      ? Icon(Icons.description_outlined,
                      color: scheme.primary)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      '$apiBase${note.imageUrl}',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(note.text),
                  subtitle: Text('${note.date} · ${note.stage}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
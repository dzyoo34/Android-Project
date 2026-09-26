import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'create_note_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(client.stage),
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
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
                  );
                },
                icon: const Icon(Icons.note_add),
                label: const Text('Добавить отчёт о визите'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
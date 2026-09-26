import 'package:flutter/material.dart';

class CreateNoteScreen extends StatelessWidget {
  const CreateNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый отчёт о визите')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Итоги встречи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Новый этап сделки',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'lead', child: Text('Новый лид')),
                DropdownMenuItem(value: 'meeting', child: Text('Встреча назначена')),
                DropdownMenuItem(value: 'negotiation', child: Text('Переговоры')),
                DropdownMenuItem(value: 'closed', child: Text('Закрыт')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('GPS-координаты'),
                subtitle: const Text('47.0245° N, 28.8322° E'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Прикрепить фото'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Сохранить отчёт'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
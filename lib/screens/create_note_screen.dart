import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  String? _stage;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отчёт сохранён')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый отчёт о визите')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _noteCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Итоги встречи',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Опишите итоги встречи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _stage,
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
                onChanged: (value) {
                  setState(() {
                    _stage = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Выберите этап сделки';
                  }
                  return null;
                },
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
                  onPressed: _save,
                  child: const Text('Сохранить отчёт'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
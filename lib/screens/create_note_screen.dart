import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../data/file_api.dart';
import '../data/result.dart';
import '../models/clients_model.dart';
import '../models/notes_model.dart';

class CreateNoteScreen extends StatefulWidget {
  final int clientId;

  const CreateNoteScreen({super.key, required this.clientId});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  String? _stage;
  String? _photoUrl;
  bool _uploading = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final api = context.read<FileApi>();
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);
    final result = await api.upload(picked.path);
    if (!mounted) return;
    setState(() => _uploading = false);

    switch (result) {
      case Ok(:final value):
        setState(() => _photoUrl = value);
      case Err(:final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final clients = context.read<ClientsModel>();
    final notes = context.read<NotesModel>();
    final client = clients.byId(widget.clientId);
    if (client == null) return;

    final now = DateTime.now();
    final today =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';

    final error = await clients.update(
      client.copyWith(stage: _stage, lastVisit: today),
    );
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return; // данные остаются в полях
    }

    notes.add(VisitNote(
      clientId: client.id,
      text: _noteCtrl.text.trim(),
      stage: _stage!,
      date: today,
      imageUrl: _photoUrl,
    ));

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
                  DropdownMenuItem(value: 'Новый лид', child: Text('Новый лид')),
                  DropdownMenuItem(
                      value: 'Встреча назначена',
                      child: Text('Встреча назначена')),
                  DropdownMenuItem(
                      value: 'Переговоры', child: Text('Переговоры')),
                  DropdownMenuItem(value: 'Закрыт', child: Text('Закрыт')),
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
                onPressed: _uploading ? null : _pickPhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(_photoUrl == null
                    ? 'Прикрепить фото'
                    : 'Заменить фото'),
              ),
              if (_photoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.network('$apiBase$_photoUrl', height: 120),
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
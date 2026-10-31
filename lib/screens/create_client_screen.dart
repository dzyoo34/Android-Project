import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/client.dart';
import '../models/clients_model.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _stage = 'Новый лид';
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    // id = 0: настоящий id даст сервер
    final error = await context.read<ClientsModel>().add(Client(
      id: 0,
      name: _nameCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      stage: _stage,
      lastVisit: '',
    ));
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return; // данные остаются в полях
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Клиент добавлен')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый клиент')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название компании',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Контактное лицо',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _stage,
                decoration: const InputDecoration(
                  labelText: 'Этап сделки',
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
                  setState(() => _stage = value ?? _stage);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: const Text('Сохранить клиента'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
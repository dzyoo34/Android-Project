import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/mock_client_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _simulateError = false; // эфемерное состояние - обычный setState

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, выйти'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Text('ИА', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            Text(
              'Никитос',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('Агент по продажам'),
            const SizedBox(height: 16),
            const Text('Статус: В сети'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Симулировать сбой сети'),
              value: _simulateError,
              onChanged: (value) {
                setState(() {
                  _simulateError = value;
                });
                context.read<MockClientRepository>().simulateError = value;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
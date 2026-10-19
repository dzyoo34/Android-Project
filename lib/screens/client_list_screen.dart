import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/clients_model.dart';
import '../models/notes_model.dart';
import '../widgets/client-card.dart';
import '../widgets/error_view.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch в build: экран следит за моделью
    final model = context.watch<ClientsModel>();

    final Widget list;
    if (model.isLoading) {
      list = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      list = ErrorView(
        message: model.error!,
        // read в callback: просто действие
        onRetry: () => context.read<ClientsModel>().load(),
      );
    } else {
      list = ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: model.clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final client = model.clients[index];
          return ClientCard(
            client: client,
            onTap: () => context.push('/clients/${client.id}'),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты и сделки'),
        actions: [
          // Consumer: badge с количеством отчётов
          Consumer<NotesModel>(
            builder: (context, notes, child) =>
                Badge(label: Text('${notes.count}'), child: child!),
            child: const Icon(Icons.description_outlined),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск по компании...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(label: Text('Новый лид')),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(label: Text('Переговоры')),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(label: Text('Закрыт')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: list),
        ],
      ),
    );
  }
}
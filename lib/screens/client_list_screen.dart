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
    final model = context.watch<ClientsModel>();
    final scheme = Theme.of(context).colorScheme;

    final Widget list;
    if (model.isLoading) {
      list = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      list = ErrorView(
        message: model.error!,
        onRetry: () => context.read<ClientsModel>().load(),
      );
    } else if (model.clients.isEmpty) {
      list = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 56, color: scheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('Ничего не найдено', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    } else {
      final count = model.clients.length + (model.hasMore ? 1 : 0);
      list = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == model.clients.length) {
            context.read<ClientsModel>().loadMore();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
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
        title: const Text('Клиенты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ClientsModel>().load(),
          ),
          Consumer<NotesModel>(
            builder: (context, notes, child) =>
                Badge(label: Text('${notes.count}'), child: child!),
            child: const Icon(Icons.description_outlined),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.add),
        label: const Text('Клиент'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              textInputAction: TextInputAction.search,
              onSubmitted: (q) =>
                  context.read<ClientsModel>().load(search: q.trim()),
              decoration: const InputDecoration(
                hintText: 'Поиск по компании...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
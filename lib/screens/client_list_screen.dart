import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/client-card.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Клиенты и сделки')),
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: mockClients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final client = mockClients[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)),
                    );
                  },
                  child: ClientCard(client: client),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
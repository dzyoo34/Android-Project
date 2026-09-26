import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'status_badge.dart';

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(client.name),
        subtitle: Text('${client.contactPerson} · ${client.phone}'),
        trailing: StatusBadge(stage: client.stage),
      ),
    );
  }
}
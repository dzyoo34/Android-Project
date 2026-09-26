import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String stage;

  const StatusBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        stage,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
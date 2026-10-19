import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/mock_client_repository.dart';
import 'models/clients_model.dart';
import 'models/notes_model.dart';
import 'router.dart';

void main() {
  // здесь выбирается источник данных
  final repository = MockClientRepository();

  runApp(
    MultiProvider(
      providers: [
        // нужен только для переключателя аварии в профиле
        Provider<MockClientRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => ClientsModel(repository)..load(),
        ),
        ChangeNotifierProvider(create: (_) => NotesModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Beta CRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
        ),
      ),
      routerConfig: router,
    );
  }
}
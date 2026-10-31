import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'data/auth_api.dart';
import 'data/file_api.dart';
import 'data/http_client_repository.dart';
import 'data/token_store.dart';
import 'models/clients_model.dart';
import 'models/notes_model.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prefs до runApp
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null; // запуск решает token

  initRouter(loggedIn: loggedIn);

  final repository = HttpClientRepository(
    apiBase,
    tokens,
    onUnauthorized: () => router.go('/login'), // 401 -> login, в одном месте
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>(create: (_) => AuthApi(apiBase, tokens)),
        Provider<FileApi>(create: (_) => FileApi(apiBase, tokens)),
        ChangeNotifierProvider(
          create: (_) {
            final model = ClientsModel(repository);
            if (loggedIn) model.load(); // без token грузить нечего
            return model;
          },
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
      title: 'Mobile CRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
        ),
      ),
      routerConfig: router,
    );
  }
}
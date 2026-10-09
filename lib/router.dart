import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/mock_data.dart';
import 'screens/login_screen.dart';
import 'screens/client_list_screen.dart';
import 'screens/client_detail_screen.dart';
import 'screens/create_note_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/clients',
              builder: (context, state) => const ClientListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final client = mockClients.firstWhere((c) => c.id == id);
                    return ClientDetailScreen(client: client);
                  },
                  routes: [
                    GoRoute(
                      path: 'note',
                      builder: (context, state) => const CreateNoteScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
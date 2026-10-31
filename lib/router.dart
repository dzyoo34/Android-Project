import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/client_list_screen.dart';
import 'screens/client_detail_screen.dart';
import 'screens/create_client_screen.dart';
import 'screens/create_note_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

late final GoRouter router;

void initRouter({required bool loggedIn}) {
  router = GoRouter(
    initialLocation: loggedIn ? '/clients' : '/login',
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
                    path: 'new',
                    builder: (context, state) => const CreateClientScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ClientDetailScreen(id: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'note',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return CreateNoteScreen(clientId: id);
                        },
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
}
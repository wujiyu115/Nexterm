import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/shared/widgets/app_scaffold.dart';
import 'package:nexterm/features/hosts/ui/hosts_screen.dart';
import 'package:nexterm/features/hosts/ui/host_form_screen.dart';
import 'package:nexterm/features/keys/ui/keys_screen.dart';
import 'package:nexterm/features/keys/ui/key_generate_screen.dart';
import 'package:nexterm/features/snippets/ui/snippets_screen.dart';
import 'package:nexterm/features/snippets/ui/snippet_form_screen.dart';
import 'package:nexterm/features/terminal/ui/terminal_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/hosts',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/hosts',
            builder: (context, state) => const HostsScreen(),
            routes: [
              GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const HostFormScreen()),
              GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => HostFormScreen(hostId: state.pathParameters['id'])),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/terminal', builder: (context, state) => const TerminalScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/keys',
            builder: (context, state) => const KeysScreen(),
            routes: [
              GoRoute(path: 'generate', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const KeyGenerateScreen()),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/snippets',
            builder: (context, state) => const SnippetsScreen(),
            routes: [
              GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SnippetFormScreen()),
              GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => SnippetFormScreen(snippetId: state.pathParameters['id'])),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (context, state) => const Scaffold(body: Center(child: Text('设置 — Phase 5')))),
        ]),
      ],
    ),
    GoRoute(
      path: '/terminal/connect/:hostId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TerminalScreen(hostId: state.pathParameters['hostId']),
    ),
  ],
);

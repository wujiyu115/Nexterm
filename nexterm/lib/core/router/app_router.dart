import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/shared/widgets/app_scaffold.dart';
import 'package:nexterm/features/vaults/ui/vaults_screen.dart';
import 'package:nexterm/features/hosts/ui/hosts_screen.dart';
import 'package:nexterm/features/hosts/ui/host_form_screen.dart';
import 'package:nexterm/features/keys/ui/keys_screen.dart';
import 'package:nexterm/features/keys/ui/key_generate_screen.dart';
import 'package:nexterm/features/keys/ui/key_import_screen.dart';
import 'package:nexterm/features/snippets/ui/snippets_screen.dart';
import 'package:nexterm/features/snippets/ui/snippet_form_screen.dart';
import 'package:nexterm/features/forwarding/ui/forwarding_screen.dart';
import 'package:nexterm/features/forwarding/ui/forward_form_screen.dart';
import 'package:nexterm/features/terminal/ui/terminal_screen.dart';
import 'package:nexterm/features/terminal/ui/sessions_screen.dart';
import 'package:nexterm/features/sftp/ui/sftp_screen.dart';
import 'package:nexterm/features/sftp/ui/file_editor_screen.dart';
import 'package:nexterm/features/sftp/ui/image_viewer_screen.dart';
import 'package:nexterm/features/sftp/services/remote_file_service.dart';
import 'package:nexterm/features/settings/ui/settings_screen.dart';
import 'package:nexterm/features/terminal/ui/toolbar_customize_screen.dart';
import 'package:nexterm/features/git/ui/git_screen.dart';
import 'package:nexterm/features/git/ui/git_repos_screen.dart';
import 'package:nexterm/features/git/ui/git_repo_form_screen.dart';
import 'package:nexterm/features/webdav/ui/webdav_connections_screen.dart';
import 'package:nexterm/features/webdav/ui/webdav_form_screen.dart';
import 'package:nexterm/features/webdav/ui/webdav_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/vaults',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Vaults branch
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/vaults',
            builder: (context, state) => const VaultsScreen(),
            routes: [
              GoRoute(
                path: 'hosts',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HostsScreen(),
                routes: [
                  GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const HostFormScreen()),
                  GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => HostFormScreen(hostId: state.pathParameters['id'])),
                ],
              ),
              GoRoute(
                path: 'keys',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const KeysScreen(),
                routes: [
                  GoRoute(path: 'generate', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const KeyGenerateScreen()),
                  GoRoute(path: 'import', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const KeyImportScreen()),
                ],
              ),
              GoRoute(
                path: 'snippets',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SnippetsScreen(),
                routes: [
                  GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SnippetFormScreen()),
                  GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => SnippetFormScreen(snippetId: state.pathParameters['id'])),
                ],
              ),
              GoRoute(
                path: 'forwarding',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ForwardingScreen(),
                routes: [
                  GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => ForwardFormScreen(initialData: state.extra as Map<String, dynamic>?)),
                  GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => ForwardFormScreen(forwardId: state.pathParameters['id'])),
                ],
              ),
              GoRoute(
                path: 'git',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const GitReposScreen(),
                routes: [
                  GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const GitRepoFormScreen()),
                  GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => GitRepoFormScreen(repoId: state.pathParameters['id'])),
                ],
              ),
              GoRoute(
                path: 'webdav',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const WebDavConnectionsScreen(),
                routes: [
                  GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const WebDavFormScreen()),
                  GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => WebDavFormScreen(connectionId: state.pathParameters['id'])),
                ],
              ),
            ],
          ),
        ]),
        // Sessions branch
        StatefulShellBranch(routes: [
          GoRoute(path: '/sessions', builder: (context, state) => const SessionsScreen()),
        ]),
        // Settings branch
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/terminal/connect/:hostId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TerminalScreen(hostId: state.pathParameters['hostId']),
    ),
    GoRoute(
      path: '/terminal/session/:tabId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TerminalScreen(tabId: state.pathParameters['tabId']),
    ),
    GoRoute(
      path: '/terminal/customize-keyboard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ToolbarCustomizeScreen(),
    ),
    GoRoute(
      path: '/sftp/:sessionId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SftpScreen(sessionId: state.pathParameters['sessionId']!),
    ),
    GoRoute(
      path: '/sftp/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return FileEditorScreen(
          sessionId: extra['sessionId'] as String?,
          filePath: extra['path'] as String,
          viewOnly: extra['viewOnly'] == 'true',
          service: extra['service'] as RemoteFileService?,
        );
      },
    ),
    GoRoute(
      path: '/sftp/image',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ImageViewerScreen(
          sessionId: extra['sessionId'] as String?,
          filePath: extra['path'] as String,
          service: extra['service'] as RemoteFileService?,
        );
      },
    ),
    GoRoute(
      path: '/git/:sessionId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => GitScreen(
        sessionId: state.pathParameters['sessionId']!,
        remotePath: state.uri.queryParameters['path'] ?? '.',
      ),
    ),
    GoRoute(
      path: '/webdav/browse',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return WebDavBrowserScreen(
          service: extra['service'] as RemoteFileService,
          title: extra['name'] as String? ?? 'WebDAV',
        );
      },
    ),
  ],
);

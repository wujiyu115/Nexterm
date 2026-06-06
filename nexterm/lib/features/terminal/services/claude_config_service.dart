import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

// ---------------------------------------------------------------------------
// Remote push notification provider abstraction
// ---------------------------------------------------------------------------

class NotifyConfigField {
  final String key;
  final String label;
  final String hint;
  final bool isSecret;

  const NotifyConfigField({
    required this.key,
    required this.label,
    this.hint = '',
    this.isSecret = false,
  });
}

abstract class RemoteNotifyProvider {
  String get id;
  String get displayName;
  List<NotifyConfigField> get configFields;

  /// Generate bash snippet for the remote notification script.
  /// [config] maps config field keys to their values.
  String generateBashSnippet(Map<String, String> config);

  /// Send a test notification to verify configuration.
  /// Returns null on success, or an error message on failure.
  Future<String?> testPush(Map<String, String> config);
}

class BarkNotifyProvider extends RemoteNotifyProvider {
  @override
  String get id => 'bark';

  @override
  String get displayName => 'Bark';

  @override
  List<NotifyConfigField> get configFields => const [
        NotifyConfigField(
          key: 'url',
          label: 'Bark URL',
          hint: 'https://api.day.app/YOUR_KEY',
        ),
      ];

  @override
  String generateBashSnippet(Map<String, String> config) {
    final url = config['url'] ?? '';
    return '''
  # Bark push notification
  BARK_URL="$url"
  if [ -n "\$BARK_URL" ]; then
    ENCODED_TITLE=\$(printf '%s' "\$TITLE" | sed 's/ /%20/g;s/\\//%2F/g')
    ENCODED_BODY=\$(printf '%s' "\$BODY" | sed 's/ /%20/g;s/\\//%2F/g')
    curl -sf "\${BARK_URL}/\${ENCODED_TITLE}/\${ENCODED_BODY}" &>/dev/null &
  fi''';
  }

  @override
  Future<String?> testPush(Map<String, String> config) async {
    final url = config['url'] ?? '';
    if (url.isEmpty) return 'Bark URL is empty';
    try {
      final uri = Uri.parse('$url/Nexterm%20Test/Push%20notification%20is%20working');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(uri);
      final response = await request.close();
      client.close();
      if (response.statusCode == 200) return null;
      return 'HTTP ${response.statusCode}';
    } catch (e) {
      return e.toString();
    }
  }
}

// ---------------------------------------------------------------------------
// Provider registry
// ---------------------------------------------------------------------------

class RemoteNotifyRegistry {
  static final providers = <RemoteNotifyProvider>[BarkNotifyProvider()];

  static RemoteNotifyProvider? byId(String id) {
    for (final p in providers) {
      if (p.id == id) return p;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Config result
// ---------------------------------------------------------------------------

enum ConfigResult { configured, alreadyConfigured, cliNotInstalled, error }

// ---------------------------------------------------------------------------
// Claude remote configuration service
// ---------------------------------------------------------------------------

class ClaudeConfigService {
  static const _scriptPath = r'~/.claude/nexterm-notify.sh';
  static const _settingsPath = r'~/.claude/settings.json';
  static const _marker = 'nexterm-notify.sh';

  static String generateScript({
    RemoteNotifyProvider? provider,
    Map<String, String> providerConfig = const {},
  }) {
    final hasRemote = provider != null;
    final remoteBranch = hasRemote
        ? provider.generateBashSnippet(providerConfig)
        : '';

    return '''#!/bin/bash
# Nexterm notification script - auto-deployed by Nexterm app
# DO NOT EDIT - will be overwritten on next configure
EVENT="\${1:-unknown}"
CWD="\${PWD}"

# --- Event mapping ---
case "\$EVENT" in
  stop)               TITLE="Claude 任务完成" ;;
  permission_request) TITLE="Claude 需要授权" ;;
  stop_failure)       TITLE="Claude 任务失败" ;;
  *)                  TITLE="Claude: \$EVENT" ;;
esac
BODY="\$CWD"

# --- Dispatch ---
${hasRemote ? '''REMOTE_PROVIDER="${provider.id}"
if [ "\$REMOTE_PROVIDER" = "${provider.id}" ]; then
$remoteBranch
else
  printf '\\033]7770;{"event":"%s","cwd":"%s"}\\007' "\$EVENT" "\$CWD"
fi''' : '''# OSC 7770 terminal notification
printf '\\033]7770;{"event":"%s","cwd":"%s"}\\007' "\$EVENT" "\$CWD"'''}
''';
  }

  static Future<ConfigResult> configureRemote(
    SSHClient client, {
    RemoteNotifyProvider? provider,
    Map<String, String> providerConfig = const {},
  }) async {
    try {
      final checkResult = await _exec(client, 'command -v claude >/dev/null 2>&1 && echo "ok" || echo "missing"');
      if (checkResult.trim() == 'missing') {
        return ConfigResult.cliNotInstalled;
      }

      final script = generateScript(
        provider: provider,
        providerConfig: providerConfig,
      );
      final escapedScript = script.replaceAll("'", "'\\''");
      await _exec(client, "mkdir -p ~/.claude && printf '%s' '$escapedScript' > $_scriptPath && chmod +x $_scriptPath");

      final existingJson = await _exec(client, 'cat $_settingsPath 2>/dev/null || echo "{}"');
      Map<String, dynamic> settings;
      try {
        settings = json.decode(existingJson.trim()) as Map<String, dynamic>;
      } catch (_) {
        settings = {};
      }

      final hooks = settings['hooks'] as Map<String, dynamic>? ?? {};
      bool alreadyConfigured = true;
      for (final event in ['Stop', 'PermissionRequest', 'StopFailure']) {
        final eventHooks = hooks[event] as List<dynamic>? ?? [];
        final hasOurHook = eventHooks.any((h) =>
            h is Map<String, dynamic> &&
            (h['command'] as String? ?? '').contains(_marker));
        if (!hasOurHook) {
          alreadyConfigured = false;
          break;
        }
      }

      if (alreadyConfigured) {
        return ConfigResult.alreadyConfigured;
      }

      final hookCommands = {
        'Stop': 'bash $_scriptPath stop',
        'PermissionRequest': 'bash $_scriptPath permission_request',
        'StopFailure': 'bash $_scriptPath stop_failure',
      };

      for (final entry in hookCommands.entries) {
        final eventHooks = (hooks[entry.key] as List<dynamic>?)?.toList() ?? [];
        eventHooks.removeWhere((h) =>
            h is Map<String, dynamic> &&
            (h['command'] as String? ?? '').contains(_marker));
        eventHooks.add({'type': 'command', 'command': entry.value});
        hooks[entry.key] = eventHooks;
      }

      settings['hooks'] = hooks;

      final encoder = const JsonEncoder.withIndent('  ');
      final newJson = encoder.convert(settings);
      final escapedJson = newJson.replaceAll("'", "'\\''");
      await _exec(client, "printf '%s' '$escapedJson' > $_settingsPath");

      return ConfigResult.configured;
    } catch (_) {
      return ConfigResult.error;
    }
  }

  static Future<String> _exec(SSHClient client, String command) async {
    final session = await client.execute(command);
    final stdoutBytes = await session.stdout.toList();
    final result = String.fromCharCodes(stdoutBytes.expand((b) => b)).trim();
    await session.done;
    return result;
  }
}

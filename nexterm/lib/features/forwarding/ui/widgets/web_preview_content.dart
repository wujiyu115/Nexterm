import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPreviewContent extends StatefulWidget {
  final int localPort;
  final String title;

  const WebPreviewContent({
    super.key,
    required this.localPort,
    required this.title,
  });

  @override
  State<WebPreviewContent> createState() => _WebPreviewContentState();
}

const _desktopUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/120.0.0.0 Safari/537.36';

class _WebPreviewContentState extends State<WebPreviewContent> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _desktopMode = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = 'http://localhost:${widget.localPort}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (url) {
          _injectViewport();
          if (mounted) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          }
        },
        onWebResourceError: (error) {
          if (mounted) setState(() => _isLoading = false);
        },
      ))
      ..loadRequest(Uri.parse(_currentUrl));
  }

  // Force a zoomable viewport. Desktop mode uses a wide fixed width so pages
  // render their desktop layout; both modes allow pinch-zoom.
  void _injectViewport() {
    final content = _desktopMode
        ? 'width=1280, initial-scale=0.3, minimum-scale=0.1, '
            'maximum-scale=10.0, user-scalable=yes'
        : 'width=device-width, initial-scale=1.0, minimum-scale=0.1, '
            'maximum-scale=10.0, user-scalable=yes';
    _controller.runJavaScript('''
      (function() {
        var m = document.querySelector('meta[name="viewport"]');
        if (!m) {
          m = document.createElement('meta');
          m.name = 'viewport';
          document.getElementsByTagName('head')[0].appendChild(m);
        }
        m.setAttribute('content', '$content');
      })();
    ''');
  }

  Future<void> _toggleDesktop() async {
    setState(() => _desktopMode = !_desktopMode);
    await _controller.setUserAgent(_desktopMode ? _desktopUserAgent : null);
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;

    return Column(
      children: [
        Container(
          height: 40,
          color: p.bgElevated,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 16, color: p.fgSecondary),
                onPressed: () => _controller.goBack(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16, color: p.fgSecondary),
                onPressed: () => _controller.goForward(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: p.fgSecondary),
                onPressed: () => _controller.reload(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              IconButton(
                icon: Icon(
                  _desktopMode ? Icons.desktop_windows : Icons.phone_android,
                  size: 16,
                  color: _desktopMode ? p.accent : p.fgSecondary,
                ),
                onPressed: _toggleDesktop,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: p.inputBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentUrl,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: p.fg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}

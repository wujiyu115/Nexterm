import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

const _desktopUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) '
    'Version/18.4 Safari/605.1.15';

const _mobileUserAgent =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) '
    'CriOS/136.0.7103.56 Mobile/15E148 Safari/604.1';

const _desktopViewportWidth = 1280;

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

class _WebPreviewContentState extends State<WebPreviewContent> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _desktopMode = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = 'http://localhost:${widget.localPort}';
  }

  InAppWebViewSettings _settings() => InAppWebViewSettings(
        userAgent: _desktopMode ? _desktopUserAgent : _mobileUserAgent,
        preferredContentMode: _desktopMode
            ? UserPreferredContentMode.DESKTOP
            : UserPreferredContentMode.MOBILE,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        allowsBackForwardNavigationGestures: true,
      );

  Future<void> _toggleDesktop() async {
    setState(() => _desktopMode = !_desktopMode);
    final controller = _controller;
    if (controller == null) return;
    await controller.setSettings(settings: _settings());
    await controller.reload();
  }

  // Force a zoomable viewport; desktop mode uses a wide fixed width so pages
  // render their desktop layout, scaled down to fit the screen.
  Future<void> _injectViewport() async {
    final controller = _controller;
    if (controller == null) return;
    final content = _desktopMode
        ? 'width=$_desktopViewportWidth, initial-scale=0.25, '
            'minimum-scale=0.1, maximum-scale=10.0, user-scalable=yes'
        : 'width=device-width, initial-scale=1.0, '
            'minimum-scale=0.1, maximum-scale=10.0, user-scalable=yes';
    await controller.evaluateJavascript(source: '''
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
                onPressed: () => _controller?.goBack(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16, color: p.fgSecondary),
                onPressed: () => _controller?.goForward(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: p.fgSecondary),
                onPressed: () => _controller?.reload(),
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
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri(_currentUrl)),
                initialSettings: _settings(),
                onWebViewCreated: (controller) => _controller = controller,
                onLoadStart: (controller, url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                      if (url != null) _currentUrl = url.toString();
                    });
                  }
                },
                onLoadStop: (controller, url) async {
                  await _injectViewport();
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      if (url != null) _currentUrl = url.toString();
                    });
                  }
                },
                onReceivedError: (controller, request, error) {
                  if (mounted) setState(() => _isLoading = false);
                },
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}

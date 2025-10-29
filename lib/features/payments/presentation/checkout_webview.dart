import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CheckoutWebViewResult {
  final bool success;
  final Uri? finalUrl;
  const CheckoutWebViewResult({required this.success, this.finalUrl});
}

class CheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final List<Pattern> successUrlPatterns;
  final List<Pattern> cancelUrlPatterns;
  const CheckoutWebView({super.key, required this.checkoutUrl, this.successUrlPatterns = const [
    'success', 'session_id=', 'checkout_session_id', 'status=success', '/success', '/thank-you', '/thankyou'
  ], this.cancelUrlPatterns = const [
    'cancel', 'status=cancel', '/cancel'
  ]});

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true);
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final c = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (request) {
          final url = request.url;
          if (_matches(url, widget.successUrlPatterns)) {
            Navigator.of(context).pop(CheckoutWebViewResult(success: true, finalUrl: Uri.tryParse(url)));
            return NavigationDecision.prevent;
          }
          if (_matches(url, widget.cancelUrlPatterns)) {
            Navigator.of(context).pop(CheckoutWebViewResult(success: false, finalUrl: Uri.tryParse(url)));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    if (c.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (c.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = c;
  }

  bool _matches(String url, List<Pattern> patterns) {
    for (final p in patterns) {
      if (p is RegExp) {
        if (p.hasMatch(url)) return true;
      } else {
        if (url.toLowerCase().contains(p.toString().toLowerCase())) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Checkout')),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
      ]),
    );
  }
}

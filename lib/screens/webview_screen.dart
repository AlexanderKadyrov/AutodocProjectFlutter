import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key, 
    required this.url, 
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final WebViewController _controller = WebViewController();
  bool _isPageLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isPageLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isPageLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Ошибка WebView [${error.errorCode}]: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isPageLoading)
            const Center(
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
        ],
      ),
    );
  }
}

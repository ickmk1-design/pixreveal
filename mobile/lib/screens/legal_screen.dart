import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';

class LegalScreen extends StatefulWidget {
  final String title;
  final String url;

  const LegalScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 11,
            color: AppColors.neonPink,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.neonBlue),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.neonPink),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(String code, String message) onPaymentComplete;

  const PaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasCompletedPayment = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('📍 Page started: $url');
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _checkDeepLink(url);
          },
          onPageFinished: (url) {
            debugPrint('✅ Page finished: $url');
            setState(() => _isLoading = false);
            _checkDeepLink(url);
          },
          onNavigationRequest: (request) {
            debugPrint('🔄 Navigation request: ${request.url}');
            if (_checkDeepLink(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            if (change.url != null) {
              _checkDeepLink(change.url!);
            }
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Lỗi tải trang: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkDeepLink(String url) {
    if (_hasCompletedPayment || _isClosing) return true;

    try {
      if (url.contains('etcapp://payment/result')) {
        _hasCompletedPayment = true;
        _isClosing = true;

        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'] ?? '99';
        final message = Uri.decodeComponent(uri.queryParameters['message'] ?? '');

        try {
          widget.onPaymentComplete(code, message);
        } catch (_) {}

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          Navigator.of(context).pop({
            'success': code == '00',
            'code': code,
            'message': message,
          });
        });

        return true;
      }
    } catch (e) {
      debugPrint("❌ Deep link parse error: $e");
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasCompletedPayment || _isClosing) return false;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy thanh toán?'),
            content: const Text('Bạn có chắc muốn hủy giao dịch này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tiếp tục'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hủy'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VNPAY'),
          leading: _hasCompletedPayment || _isClosing
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    final shouldPop = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hủy thanh toán?'),
                        content:
                            const Text('Bạn có chắc muốn hủy giao dịch này không?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Tiếp tục'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hủy'),
                          ),
                        ],
                      ),
                    );

                    if (shouldPop == true && mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
          actions: [
            if (!_hasCompletedPayment && !_isClosing)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _controller.reload(),
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tải trang thanh toán...'),
                    ],
                  ),
                ),
              ),

            if (_hasCompletedPayment)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'Thanh toán thành công!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Đang chuyển về ứng dụng...'),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: Colors.green),
                  ],
                ),
              ),

            if (_errorMessage != null)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _errorMessage = null);
                            _controller.reload();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

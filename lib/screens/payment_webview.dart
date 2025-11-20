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

            // Kiểm tra deep link
            if (_checkDeepLink(request.url)) {
              // Ngăn WebView load deep link
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
            debugPrint('❌ Web resource error: ${error.description}');
            setState(() {
              _isLoading = false;
              _errorMessage = 'Lỗi tải trang: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Kiểm tra và xử lý deep link
  /// Kiểm tra và xử lý deep link – PHIÊN BẢN HOÀN HẢO 2025
  bool _checkDeepLink(String url) {
    if (_hasCompletedPayment || _isClosing) return true;

    if (url.contains('etcapp://payment/result')) {
      _hasCompletedPayment = true;
      _isClosing = true;

      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'] ?? '99';
      final message = Uri.decodeComponent(uri.queryParameters['message'] ?? '');

      // GỌI CALLBACK TRƯỚC
      widget.onPaymentComplete(code, message);

      // TỰ ĐỘNG ĐÓNG SAU 1.2 GIÂY → TRẢ KẾT QUẢ VỀ TOPUPSCREEN
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pop(<String, dynamic>{
          'success': code == '00',
          'code': code,
          'message': message,
        });
      });

      return true;
    }
    return false;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Nếu đang xử lý payment, không cho back
        if (_hasCompletedPayment || _isClosing) {
          return false;
        }

        // Xác nhận khi user bấm back
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy thanh toán?'),
            content: const Text(
                'Bạn có chắc muốn hủy giao dịch này không?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tiếp tục thanh toán'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
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
              ? null // Ẩn nút back khi đang xử lý
              : IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hủy thanh toán?'),
                  content: const Text(
                      'Bạn có chắc muốn hủy giao dịch này không?'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Tiếp tục'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Hủy'),
                    ),
                  ],
                ),
              );
              if (shouldPop == true && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (!_hasCompletedPayment && !_isClosing)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  debugPrint('🔄 Reloading WebView');
                  _controller.reload();
                },
                tooltip: 'Tải lại',
              ),
          ],
        ),
        body: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _controller),

            // Loading indicator
            if (_isLoading && !_hasCompletedPayment)
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

            // Payment success overlay
            // Payment success overlay – tự động tắt sau 1.2s
            if (_hasCompletedPayment)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'Thanh toán thành công!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text('Đang chuyển về ứng dụng...'),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: Colors.green),
                  ],
                ),
              ),

            // Error message
            if (_errorMessage != null)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _errorMessage = null);
                                _controller.reload();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Đóng'),
                            ),
                          ],
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

  @override
  void dispose() {
    debugPrint('🗑️ PaymentWebView disposed');
    super.dispose();
  }
}
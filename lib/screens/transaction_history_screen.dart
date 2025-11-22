// transaction_history_screen.dart – PHÂN TRANG HOÀN CHỈNH + MƯỢT
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smarttoll_app/api/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true; // ← Quan trọng: còn trang tiếp không
  int currentPage = 0;
  final int pageSize = 15;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      _loadTransactions(loadMore: true);
    }
  }

  Future<void> _loadTransactions({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => isLoadingMore = true);
    } else {
      setState(() => isLoading = true);
    }

    final newData = await ApiService.getRechargeHistory(
      page: currentPage,
      size: pageSize,
    );

    setState(() {
      if (loadMore) {
        transactions.addAll(newData);
      } else {
        transactions = newData;
      }

      // Cập nhật trạng thái phân trang
      hasMore = newData.length == pageSize; // nếu trả về ít hơn → hết rồi
      if (hasMore) currentPage++;

      isLoading = false;
      isLoadingMore = false;
    });
  }

  final numberFormat = NumberFormat('#,###', 'vi_VN');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  String _formatMethod(String? method) {
    if (method == null) return "Không xác định";
    return switch (method.toUpperCase()) {
      'VNPAY' => 'Ngân hàng (VNPay)',
      'MOMO' => 'Ví MoMo',
      'ZALOPAY' => 'Ví ZaloPay',
      _ => 'Ngân hàng ($method)',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 65,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Lịch sử nạp tiền",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          currentPage = 0;
          hasMore = true;
          return _loadTransactions();
        },
        child: isLoading && transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          controller: _scrollController, // ← QUAN TRỌNG: gắn controller
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length + (hasMore || isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator khi đang load more
            if (index == transactions.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final tx = transactions[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(tx['dateTime']),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "NẠP TIỀN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatMethod(tx['method'] as String?),
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Số tiền:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${numberFormat.format(tx['amount'])} VND",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Số dư:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${numberFormat.format(tx['balanceAfter'])} VND",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text("Chưa có giao dịch nạp tiền", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text("Khi bạn nạp tiền, lịch sử sẽ hiện ở đây", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}
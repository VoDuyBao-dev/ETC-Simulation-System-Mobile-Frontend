import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 0;
  final int pageSize = 20;

  String searchText = '';
  final NumberFormat numberFormat = NumberFormat('#,###', 'vi_VN');

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && hasMore) {
          _loadTransactions();
        }
      }
    });
  }

  Future<void> _loadTransactions() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final newTransactions = await ApiService.getTransactionHistory(
      page: currentPage,
      size: pageSize,
    );

    setState(() {
      if (newTransactions.isEmpty || newTransactions.length < pageSize) {
        hasMore = false;
      }
      transactions.addAll(newTransactions);
      currentPage++;
      isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      transactions.clear();
      currentPage = 0;
      hasMore = true;
    });
    await _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions.where((tx) {
      final station = (tx['stationName'] ?? '').toString().toLowerCase();
      final search = searchText.toLowerCase();
      return station.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 65,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          "Lịch sử thu phí",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm theo trạm thu phí...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0099FF)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchText = val;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: filteredTransactions.isEmpty && !isLoading
                  ? Center(
                child: Text(
                  transactions.isEmpty
                      ? "Đang tải dữ liệu..."
                      : "Không tìm thấy giao dịch nào",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTransactions.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredTransactions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final tx = filteredTransactions[index];
                  return _transactionCard(tx);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    // Xử lý null cho dateTime
    final DateTime dateTime = tx['dateTime'] is DateTime
        ? tx['dateTime']
        : DateTime.tryParse(tx['dateTime']?.toString() ?? '') ?? DateTime.now();

    final formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    final fee = (tx['amount'] is num)
        ? (tx['amount'] as num).abs().toDouble()
        : 0.0;

    final balance = (tx['balanceAfter'] is num)
        ? (tx['balanceAfter'] as num).toDouble()
        : 0.0;

    final station = tx['stationName']?.toString() ?? 'Không rõ trạm';
    final description = tx['description']?.toString() ?? 'Trừ phí qua trạm';
    final plate = tx['plateNumber']?.toString() ?? '';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: primaryColor.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              station,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            if (plate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Biển số: $plate",
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Phí trừ:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.redAccent)),
                Text("-${numberFormat.format(fee)} VND", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Số dư còn lại:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
                Text("${numberFormat.format(balance)} VND", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  // Dữ liệu mẫu (thêm trường "content")
  final List<Map<String, dynamic>> transactions = [
    {
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'station': 'Trạm An Sương',
      'fee': 35000,
      'balance': 120000,
      'content': 'Phí qua trạm An Sương (xe hơi 4 chỗ)',
    },
    {
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'station': 'Trạm Củ Chi',
      'fee': 45000,
      'balance': 155000,
      'content': 'Qua trạm Củ Chi - Xe tải 2 trục',
    },
    {
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      'station': 'Trạm Phú Mỹ',
      'fee': 25000,
      'balance': 200000,
      'content': 'Phí cầu Phú Mỹ - Hướng Quận 7 → Nhơn Trạch',
    },
  ];

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions.where((tx) {
      final station = tx['station'].toString().toLowerCase();
      final search = searchText.toLowerCase();
      return station.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Lịch sử thu phí",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ----- Thanh tìm kiếm -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm theo trạm thu phí...",
                prefixIcon: const Icon(Icons.search),
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

          // ----- Danh sách giao dịch -----
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text("Không có giao dịch nào"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return _transactionCard(tx);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(tx['time']);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thời gian
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),

            // Tên trạm
            Text(
              tx['station'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Nội dung giao dịch
            Text(
              tx['content'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),

            // Phí trừ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Phí trừ:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                Text(
                  "${tx['fee']} đ",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Số dư còn lại
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Số dư còn lại:",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                Text(
                  "${tx['balance']} đ",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

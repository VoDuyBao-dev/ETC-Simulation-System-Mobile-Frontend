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

  // Dữ liệu mẫu
  final List<Map<String, dynamic>> transactions = [
    {
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'station': 'Trạm An Sương',
      'fee': 35000,
      'balance': 120000,
    },
    {
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'station': 'Trạm Củ Chi',
      'fee': 45000,
      'balance': 155000,
    },
    {
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      'station': 'Trạm Phú Mỹ',
      'fee': 25000,
      'balance': 200000,
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

          // Tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm theo trạm",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                setState(() {
                  searchText = val;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // List giao dịch
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedTime,
                style: const TextStyle(
                    fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(tx['station'],
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Phí trừ:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryColor)),
                Text("${tx['fee'].toString()} đ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Số dư:",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                Text("${tx['balance'].toString()} đ",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

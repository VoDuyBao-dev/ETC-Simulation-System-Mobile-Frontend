import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0099FF);
    final Color secondaryColor = const Color(0xFF00CC99);

    // Dữ liệu mẫu (gồm nạp tiền và trừ tiền)
    final List<Map<String, dynamic>> transactions = [
      {
        'type': 'NẠP TIỀN',
        'amount': 200000,
        'balance': 725000,
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'method': 'Ví điện tử Momo',
      },
      {
        'type': 'TRỪ PHÍ QUA TRẠM',
        'amount': -350000,
        'balance': 525000,
        'time': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        'method': 'Trạm An Sương',
      },
      {
        'type': 'NẠP TIỀN',
        'amount': 50000,
        'balance': 875000,
        'time': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        'method': 'Ngân hàng Vietcombank',
      },
      {
        'type': 'TRỪ PHÍ QUA TRẠM',
        'amount': -25000,
        'balance': 825000,
        'time': DateTime.now().subtract(const Duration(days: 3, hours: 6)),
        'method': 'Trạm Phú Mỹ',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Tra cứu giao dịch",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final formattedTime =
          DateFormat('dd/MM/yyyy HH:mm').format(tx['time']);
          final isRecharge = tx['amount'] > 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🕒 Thời gian
                  Text(
                    formattedTime,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Loại giao dịch
                  Text(
                    tx['type'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isRecharge ? secondaryColor : primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 🔹 Phương thức / Trạm
                  Text(
                    tx['method'],
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Số tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số tiền:",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                      Text(
                        "${tx['amount'] > 0 ? '+' : ''}${tx['amount']}đ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isRecharge ? secondaryColor : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 🔹 Số dư sau giao dịch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số dư:",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                      Text(
                        "${tx['balance']}đ",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

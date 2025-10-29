import 'package:flutter/material.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? selectedMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {"icon": Icons.account_balance, "name": "Ngân hàng liên kết"},
    {"icon": Icons.credit_card, "name": "Thẻ tín dụng / Ghi nợ"},
    {"icon": Icons.wallet, "name": "Ví điện tử Momo"},
    {"icon": Icons.qr_code, "name": "Quét mã QR"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền vào tài khoản"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Số dư hiện tại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Số dư hiện tại",
                          style: TextStyle(
                              color: Colors.black54, fontSize: 14)),
                      SizedBox(height: 4),
                      Text("350,000 VNĐ",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nhập số tiền
            const Text("Nhập số tiền cần nạp",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "VD: 100000",
                prefixIcon:
                const Icon(Icons.attach_money, color: Colors.green),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Chọn phương thức thanh toán
            const Text("Chọn phương thức thanh toán",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedMethod = method["name"]);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedMethod == method["name"]
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: selectedMethod == method["name"]
                            ? Colors.green.shade50
                            : Colors.white,
                      ),
                      child: ListTile(
                        leading:
                        Icon(method["icon"], color: Colors.green, size: 30),
                        title: Text(method["name"]),
                        trailing: selectedMethod == method["name"]
                            ? const Icon(Icons.check_circle,
                            color: Colors.green)
                            : const Icon(Icons.circle_outlined,
                            color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_amountController.text.isEmpty || selectedMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text("Vui lòng nhập số tiền và chọn phương thức"),
                      ),
                    );
                    return;
                  }
                  _showConfirmDialog(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text("Xác nhận nạp tiền"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận giao dịch"),
        content: Text(
            "Bạn có chắc muốn nạp ${_amountController.text} VNĐ qua phương thức '$selectedMethod'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Nạp tiền thành công!"),
                  backgroundColor: Colors.green,
                ),
              );
              _amountController.clear();
              setState(() => selectedMethod = null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}

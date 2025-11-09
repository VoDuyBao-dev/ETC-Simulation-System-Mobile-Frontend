import 'package:flutter/material.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);
  final TextEditingController _amountController = TextEditingController();

  String _selectedMethod = 'Ví điện tử';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Nạp tiền",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------- SỐ DƯ HIỆN TẠI ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Số dư hiện tại", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text("350,000đ",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ---------- NHẬP SỐ TIỀN ----------
            const Text("Nhập số tiền muốn nạp",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số tiền (VNĐ)",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.attach_money_rounded, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---------- CHỌN NHANH ----------
            Wrap(
              spacing: 10,
              children: [
                _quickAmountButton("50,000"),
                _quickAmountButton("100,000"),
                _quickAmountButton("200,000"),
                _quickAmountButton("500,000"),
              ],
            ),

            const SizedBox(height: 25),

            // ---------- CHỌN PHƯƠNG THỨC ----------
            const Text("Phương thức thanh toán",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            _paymentMethod("Ví điện tử", Icons.account_balance_wallet_rounded),
            _paymentMethod("Ngân hàng", Icons.account_balance_rounded),

            const SizedBox(height: 30),

            // ---------- NÚT NẠP TIỀN ----------
            GestureDetector(
              onTap: () {
                final enteredAmount = _amountController.text;
                if (enteredAmount.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập số tiền cần nạp")),
                  );
                  return;
                }
                // ✅ Xử lý logic nạp tiền ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đang xử lý nạp $enteredAmountđ qua $_selectedMethod...")),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Xác nhận nạp tiền",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- BUTTON CHỌN NHANH ----------
  Widget _quickAmountButton(String amount) {
    return ChoiceChip(
      label: Text("$amountđ"),
      selectedColor: primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: _amountController.text == amount ? Colors.white : Colors.black87,
      ),
      selected: _amountController.text == amount,
      onSelected: (selected) {
        setState(() {
          _amountController.text = amount;
        });
      },
    );
  }

  // ---------- PHƯƠNG THỨC THANH TOÁN ----------
  Widget _paymentMethod(String title, IconData icon) {
    final bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}

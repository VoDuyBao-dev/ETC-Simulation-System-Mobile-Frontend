import 'package:flutter/material.dart';
import '../api/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final api = ApiService();

  final plateController = TextEditingController();
  String selectedType = "CAR";
  bool loading = false;

  String? plateError; // <-- lỗi nhập biển số

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  // ========================= VALIDATE BIỂN SỐ =========================
  bool validatePlate(String plate) {
    final regex = RegExp(r'^\d{2}[A-Z]-\d{3,5}$');
    return regex.hasMatch(plate);
  }

  // ========================= POPUP FULL WIDTH =========================
  Future<void> _showTypeMenu(BuildContext context, RenderBox box) async {
    final offset = box.localToGlobal(Offset.zero);
    final width = box.size.width;

    final result = await showMenu<String>(
      context: context,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height + 5,
        offset.dx + width,
        0,
      ),
      items: const [
        PopupMenuItem(
          value: "CAR",
          child: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue),
              SizedBox(width: 10),
              Text("CAR", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "TRUCK",
          child: Row(
            children: [
              Icon(Icons.fire_truck, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("TRUCK", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );

    if (result != null) {
      setState(() => selectedType = result);
    }
  }

  // ========================= SUBMIT =========================
  Future<void> submit() async {
    final plate = plateController.text.trim();

    if (plate.isEmpty) {
      setState(() => plateError = "Vui lòng nhập biển số xe");
      return;
    }

    if (!validatePlate(plate)) {
      setState(() => plateError =
      "Biển số không hợp lệ. Định dạng đúng: 23A-12345");
      return;
    }

    setState(() => plateError = null); // xoá lỗi khi hợp lệ
    setState(() => loading = true);

    try {
      final success = await api.addVehicle(
        plateNumber: plate,
        vehicleType: selectedType,
      );
      if (success) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text(
          "Thêm phương tiện",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- INPUT BIỂN SỐ ----------------
              const Text(
                "Biển số xe",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: plateError == null
                        ? Colors.grey.shade300
                        : Colors.red,
                  ),
                ),
                child: TextField(
                  controller: plateController,
                  onChanged: (_) {
                    if (plateError != null) {
                      setState(() => plateError = null);
                    }
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "VD: 51H-12345",
                  ),
                ),
              ),

              if (plateError != null) ...[
                const SizedBox(height: 6),
                Text(
                  plateError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 25),

              // ---------------- CHỌN LOẠI XE ----------------
              const Text(
                "Loại phương tiện",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    final box = context.findRenderObject() as RenderBox;
                    _showTypeMenu(context, box);
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBFF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedType,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.black54),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 35),

              // ---------------- NÚT THÊM XE ----------------
              GestureDetector(
                onTap: loading ? null : submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                      : const Text(
                    "Thêm xe",
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
      ),
    );
  }
}





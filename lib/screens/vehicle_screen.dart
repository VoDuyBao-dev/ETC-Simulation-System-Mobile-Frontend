import 'package:flutter/material.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  List<Map<String, dynamic>> vehicles = [
    {
      'plate': '51H-123.45',
      'etag': 'ETG001',
      'status': true,
      'etagStatus': 'Hoạt động',
      'type': 'Xe hơi',
    },
    {
      'plate': '60A-678.90',
      'etag': 'ETG002',
      'status': false,
      'etagStatus': 'Không hoạt động',
      'type': 'Xe tải',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Quản lý phương tiện",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _vehicleCard(vehicle);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () async {
          final newVehicle = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
          if (newVehicle != null) {
            setState(() {
              vehicles.add(newVehicle);
            });
          }
        },
      ),
    );
  }

  Widget _vehicleCard(Map<String, dynamic> vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehicle: vehicle),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(
                  vehicle['type'] == 'Xe tải'
                      ? Icons.local_shipping_rounded
                      : Icons.directions_car_rounded,
                  color: primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle['plate'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text("E-Tag: ${vehicle['etag']}",
                        style: const TextStyle(color: Colors.grey)),
                    Text(
                        "Trạng thái: ${vehicle['status'] ? "Hoạt động" : "Không hoạt động"}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ======================== CHI TIẾT XE ========================
//
class VehicleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late bool isActive;

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  @override
  void initState() {
    super.initState();
    isActive = widget.vehicle['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Chi tiết phương tiện"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------- Biển số xe + loại xe -----------
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.vehicle['plate'],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0099FF), Color(0xFF00CC99)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.vehicle['type'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Divider(),

              const SizedBox(height: 14),

              // ----------- Số E-Tag -----------
              _infoRow(Icons.nfc_rounded, "Số E-Tag", widget.vehicle['etag']),

              const SizedBox(height: 16),

              // ----------- Trạng thái phương tiện (Switch) -----------
              Row(
                children: [
                  Icon(Icons.power_settings_new_rounded,
                      color: primaryColor, size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Trạng thái phương tiện",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeColor: Colors.white,
                    activeTrackColor: secondaryColor,
                    inactiveThumbColor: Colors.grey.shade200,
                    inactiveTrackColor: Colors.grey.shade400,
                    onChanged: (v) {
                      setState(() => isActive = v);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ----------- Trạng thái E-Tag (chỉ hiển thị) -----------
              Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: Color(0xFF0099FF), size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Trạng thái E-Tag",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  Text(
                    widget.vehicle['etagStatus'],
                    style: TextStyle(
                      color: widget.vehicle['etagStatus'] == 'Hoạt động'
                          ? secondaryColor
                          : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Divider(),

              // ----------- Nút lưu -----------
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.vehicle['status'] = isActive;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Đã lưu trạng thái: ${isActive ? "Hoạt động" : "Không hoạt động"}",
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Lưu thay đổi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}

//
// ======================== THÊM PHƯƠNG TIỆN ========================
//
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _etagController = TextEditingController();

  String? _selectedType; // để mặc định là null -> hiển thị “Chọn loại phương tiện”
  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Thêm phương tiện"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _plateController,
                decoration:
                _inputDecoration("Biển số xe", Icons.directions_car_rounded),
                validator: (v) => v!.isEmpty ? "Nhập biển số xe" : null,
              ),

              const SizedBox(height: 16),
              const Text("Loại phương tiện",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),

              // Dropdown đẹp + xổ xuống dưới
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text("Chọn loại phương tiện"),
                    value: _selectedType,
                    borderRadius: BorderRadius.circular(14),
                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 30),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    menuMaxHeight: 200, // ép dropdown xổ xuống
                    items: ['Xe hơi', 'Xe tải']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(type,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedType != null) {
                    Navigator.pop(context, {
                      'plate': _plateController.text,
                      'etag': _etagController.text,
                      'status': true,
                      'etagStatus': 'Hoạt động',
                      'type': _selectedType!,
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient:
                    LinearGradient(colors: [primaryColor, secondaryColor]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Thêm phương tiện",
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

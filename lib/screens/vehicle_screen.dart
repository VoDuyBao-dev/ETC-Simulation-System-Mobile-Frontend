import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final List<Vehicle> _vehicles = [
    Vehicle(plate: "30A-12345", type: "Ô tô con"),
    Vehicle(plate: "29B-67890", type: "Xe tải"),
  ];

  void _addVehicle() async {
    final newVehicle = await showDialog<Vehicle>(
      context: context,
      builder: (_) => const AddOrEditVehicleDialog(),
    );
    if (newVehicle != null) {
      setState(() => _vehicles.add(newVehicle));
    }
  }

  void _editVehicle(Vehicle vehicle) async {
    final editedVehicle = await showDialog<Vehicle>(
      context: context,
      builder: (_) => AddOrEditVehicleDialog(vehicle: vehicle),
    );
    if (editedVehicle != null) {
      setState(() {
        final index = _vehicles.indexOf(vehicle);
        if (index != -1) _vehicles[index] = editedVehicle;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã cập nhật xe ${editedVehicle.plate}")),
      );
    }
  }

  void _deleteVehicle(Vehicle v) {
    setState(() => _vehicles.remove(v));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã xóa xe ${v.plate}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý phương tiện"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _addVehicle,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.directions_car, color: Colors.green.shade700),
              ),
              title: Text(
                vehicle.plate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(vehicle.type),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editVehicle(vehicle);
                  if (value == 'delete') _deleteVehicle(vehicle);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('✏️ Chỉnh sửa')),
                  const PopupMenuItem(
                      value: 'delete', child: Text('🗑️ Xóa phương tiện')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddOrEditVehicleDialog extends StatefulWidget {
  final Vehicle? vehicle;
  const AddOrEditVehicleDialog({super.key, this.vehicle});

  @override
  State<AddOrEditVehicleDialog> createState() => _AddOrEditVehicleDialogState();
}

class _AddOrEditVehicleDialogState extends State<AddOrEditVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController plateCtrl;
  String? vehicleType;

  @override
  void initState() {
    super.initState();
    plateCtrl = TextEditingController(text: widget.vehicle?.plate ?? '');
    vehicleType = widget.vehicle?.type;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? "Chỉnh sửa phương tiện" : "Thêm phương tiện mới"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: plateCtrl,
              decoration: const InputDecoration(
                labelText: "Biển số xe",
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? "Nhập biển số xe" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Loại phương tiện",
                prefixIcon: Icon(Icons.local_taxi),
              ),
              value: vehicleType,
              items: const [
                DropdownMenuItem(value: "Ô tô con", child: Text("Ô tô con")),
                DropdownMenuItem(value: "Xe tải", child: Text("Xe tải")),
                DropdownMenuItem(value: "Xe khách", child: Text("Xe khách")),
                DropdownMenuItem(
                    value: "Xe container", child: Text("Xe container")),
              ],
              onChanged: (val) => setState(() => vehicleType = val),
              validator: (value) =>
              value == null ? "Chọn loại phương tiện" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final v = Vehicle(
                plate: plateCtrl.text.trim(),
                type: vehicleType!,
              );
              Navigator.pop(context, v);
            }
          },
          child: Text(isEditing ? "Lưu thay đổi" : "Thêm"),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:smarttoll_app/screens/add_vehicle_screen.dart';
// import 'package:smarttoll_app/screens/vehicle_detail_screen.dart';
// import '../api/api_service.dart';
//
// class VehicleScreen extends StatefulWidget {
//   const VehicleScreen({super.key});
//
//   @override
//   State<VehicleScreen> createState() => _VehicleScreenState();
// }
//
// class _VehicleScreenState extends State<VehicleScreen> {
//   final api = ApiService();
//   List<dynamic> vehicles = [];
//   bool loading = true;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     loadVehicles();
//   }
//
//   Future<void> loadVehicles() async {
//     try {
//       final data = await api.getVehicles();
//       setState(() {
//         vehicles = data;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Danh sách phương tiện")),
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
//           );
//
//           if (result == true) {
//             loadVehicles();
//           }
//         },
//         child: const Icon(Icons.add),
//       ),
//
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//           ? Center(child: Text("Lỗi: $errorMessage"))
//           : ListView.builder(
//         itemCount: vehicles.length,
//         itemBuilder: (context, index) {
//           final v = vehicles[index];
//           return ListTile(
//             title: Text(v["plateNumber"] ?? "Không có biển số"),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Loại phương tiện: ${v["vehicleType"] ?? '-'}"),
//                 Text("Trạng thái xe: ${v["vehicleStatus"] ?? '-'}"),
//               ],
//             ),
//             isThreeLine: true,
//             onTap: () async {
//               final updatedVehicle = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => VehicleDetailScreen(vehicle: v),
//                 ),
//               );
//
//               if (updatedVehicle != null) {
//                 setState(() {
//                   vehicles[index] = updatedVehicle;
//                 });
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// Flutter UI for VehicleScreen styled similar to provided mockup
// NOTE: Replace inside your VehicleScreen build method.

import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_detail_screen.dart';
import '../api/api_service.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final api = ApiService();
  List<dynamic> vehicles = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final data = await api.getVehicles();
      setState(() {
        vehicles = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  Widget buildVehicleCard(Map v) {
    final bool isActive = (v["vehicleStatus"] ?? "INACTIVE") == "ACTIVE";

    // ---- Lấy loại xe ----
    final String type = (v["vehicleType"] ?? "CAR").toUpperCase();

    // ---- Icon theo loại xe (cùng màu xanh) ----
    IconData icon = Icons.directions_car;
    if (type == "TRUCK") {
      icon = Icons.fire_truck;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0099FF),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v["plateNumber"] ?? "Không có biển số",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "E-Tag: ${v["tagUid"] ?? "-"}",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  "Trạng thái: ${isActive ? "Hoạt động" : "Không hoạt động"}",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios,
              size: 18, color: Colors.black45),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0099FF),
                Color(0xFF00CC99),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Quản lý phương tiện",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0099FF),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );

          if (result == true) {
            loadVehicles();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text("Lỗi: $errorMessage"))
          : ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final v = vehicles[index];

          return GestureDetector(
            onTap: () async {
              final updatedVehicle = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(vehicle: v),
                ),
              );

              if (updatedVehicle != null) {
                setState(() {
                  vehicles[index] = updatedVehicle;
                });
              }
            },
            child: buildVehicleCard(v),
          );
        },
      ),
    );
  }
}


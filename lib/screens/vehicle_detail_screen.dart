import 'package:flutter/material.dart';
import '../api/api_service.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final api = ApiService();

  late Map<String, dynamic> vehicle;
  bool loading = false;

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  @override
  void initState() {
    super.initState();
    vehicle = Map<String, dynamic>.from(widget.vehicle);
  }

  bool isVehicleActive() =>
      (vehicle["vehicleStatus"] ?? "INACTIVE") == "ACTIVE";

  bool isTagActive() =>
      (vehicle["tagStatus"] ?? "INACTIVE") == "ACTIVE";

  // ============================ API: Toggle TAG ============================
  Future<void> toggleTagStatus() async {
    if (loading) return;

    if (!isVehicleActive()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể bật E-Tag khi phương tiện đang INACTIVE.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final updated = await api.updateRfidTagStatus(vehicle["id"].toString());

      if (updated != null && updated is Map<String, dynamic>) {
        setState(() {
          vehicle["tagStatus"] = updated["tagStatus"] ?? vehicle["tagStatus"];
          if (updated.containsKey("tagUid")) {
            vehicle["tagUid"] = updated["tagUid"];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đổi trạng thái E-Tag: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ======================= API: Toggle Vehicle Status ======================
  Future<void> toggleVehicleStatus() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final bool newStatus = !isVehicleActive();

      final updated = await api.updateVehicleStatus(
        vehicle["id"].toString(),
        newStatus,
      );

      if (updated != null && updated is Map<String, dynamic>) {
        setState(() => vehicle = Map<String, dynamic>.from(updated));
      } else {
        setState(() {
          vehicle["vehicleStatus"] = newStatus ? "ACTIVE" : "INACTIVE";
          if (!newStatus) {
            vehicle["tagStatus"] = "INACTIVE";
            vehicle["tagUid"] = null;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đổi trạng thái phương tiện: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(vehicle);
    return false;
  }

  // ============================ UI BẮT ĐẦU =============================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),

        // ======================= APPBAR GRADIENT =======================
        appBar: AppBar(
          title: const Text(
            "Chi tiết phương tiện",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
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

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(22),
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

                // =================== BIỂN SỐ + LOẠI XE ===================
                Center(
                  child: Column(
                    children: [
                      Text(
                        vehicle["plateNumber"] ?? "-",
                        style: const TextStyle(
                          fontSize: 32,
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
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vehicle["vehicleType"] ?? "-",
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
                const SizedBox(height: 18),

                // ========================= E-TAG UID =========================
                _infoRow(Icons.nfc_rounded, "E-Tag UID",
                    vehicle["tagUid"] ?? "-"),

                const SizedBox(height: 16),

                // ==================== TRẠNG THÁI PHƯƠNG TIỆN ====================
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
                      value: isVehicleActive(),
                      activeColor: Colors.white,
                      activeTrackColor: secondaryColor,
                      inactiveThumbColor: Colors.grey.shade200,
                      inactiveTrackColor: Colors.grey.shade400,
                      onChanged: loading ? null : (_) => toggleVehicleStatus(),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ======================== TRẠNG THÁI E-TAG =========================
                Row(
                  children: [
                    Icon(Icons.credit_card_rounded,
                        color: primaryColor, size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Trạng thái E-Tag",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: isTagActive(),
                      activeColor: Colors.white,
                      activeTrackColor: primaryColor,
                      inactiveThumbColor: Colors.grey.shade200,
                      inactiveTrackColor: Colors.grey.shade400,
                      onChanged: (loading || !isVehicleActive())
                          ? null
                          : (_) => toggleTagStatus(),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // =========================== NÚT LƯU ===========================
                GestureDetector(
                  onTap: () => Navigator.pop(context, vehicle),
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


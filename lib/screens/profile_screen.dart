import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String editingField = "";
  File? _avatarImage;

  final Color primaryColor = const Color(0xFF0099FF);
  final Color secondaryColor = const Color(0xFF00CC99);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // ===================== LẤY DỮ LIỆU HỒ SƠ =====================
  Future<void> _fetchProfileData() async {
    final res = await ApiService.fetchProfileData();

    if (res['success'] == true) {
      final data = res['data'];
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Không thể tải thông tin người dùng'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ===================== CẬP NHẬT HỒ SƠ =====================
  Future<void> _updateProfile(String field, String value) async {
    final res = await ApiService.updateProfileData(field, value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] ? secondaryColor : Colors.redAccent,
      ),
    );
  }

  // ===================== CHỌN ẢNH ĐẠI DIỆN =====================
  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Chọn từ thư viện"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _avatarImage = File(picked.path));
                  // await ApiService.uploadAvatar(_avatarImage!);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text("Chụp ảnh mới"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => _avatarImage = File(picked.path));
                  // await ApiService.uploadAvatar(_avatarImage!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== LƯU TRƯỜNG ĐANG CHỈNH =====================
  Future<void> _saveField(String fieldName) async {
    String value = "";
    switch (fieldName) {
      case "Họ và tên":
        value = _nameController.text;
        break;
      case "Số điện thoại":
        value = _phoneController.text;
        break;
      case "Địa chỉ":
        value = _addressController.text;
        break;
    }

    if (value.isNotEmpty) {
      await _updateProfile(fieldName, value);
    }
    setState(() => editingField = "");
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 4,
        ),
      );
    }

    // Bọc toàn bộ body trong Scaffold để có Material context
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // ---------- ẢNH ĐẠI DIỆN ----------
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : const AssetImage('assets/images/avatar.png')
                    as ImageProvider,
                    child: _avatarImage == null
                        ? const Icon(Icons.person,
                        size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 6,
                    right: 8,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ---------- THÔNG TIN NGƯỜI DÙNG ----------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _buildFancyField(
                    label: "Họ và tên",
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 18),
                  _buildFancyField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 18),
                  _buildFancyField(
                    label: "Số điện thoại",
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 18),
                  _buildFancyField(
                    label: "Địa chỉ",
                    icon: Icons.location_on_outlined,
                    controller: _addressController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Mở danh sách lịch sử giao dịch..."),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text("Xem lịch sử giao dịch"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Ô NHẬP CÓ CÂY VIẾT TRONG KHUNG ----------
  Widget _buildFancyField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    bool isEditingThis = editingField == label;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isEditingThis
            ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly ? true : !isEditingThis,
        cursorColor: primaryColor,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isEditingThis ? primaryColor : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: readOnly
              ? null
              : IconButton(
            icon: Icon(
              isEditingThis
                  ? Icons.check_circle_rounded
                  : Icons.edit_rounded,
              color: isEditingThis ? secondaryColor : primaryColor,
            ),
            tooltip: isEditingThis ? "Lưu thay đổi" : "Chỉnh sửa",
            onPressed: () {
              if (isEditingThis) {
                _saveField(label);
              } else {
                setState(() => editingField = label);
              }
            },
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: secondaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }
}

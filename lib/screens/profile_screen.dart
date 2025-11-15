import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smarttoll_app/api/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  File? _avatarImage;

  final Color primary1 = const Color(0xFF0099FF);
  final Color primary2 = const Color(0xFF00CC99);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // ======================= LOAD PROFILE =======================
  Future<void> _loadUserInfo() async {
    final res = await ApiService.getMyInfo();

    if (res["code"] == 200) {
      final data = res["result"];

      setState(() {
        _nameController.text = data["fullname"] ?? "";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["phone"] ?? "";
        _addressController.text = data["address"] ?? "";
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Lỗi tải thông tin")),
      );
    }
  }

  // ======================= UPDATE PROFILE =======================
  Future<void> _updateProfile() async {
    final body = {
      "username": _emailController.text,
      "fullname": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
    };

    final res = await ApiService.updateUserInfo(body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Cập nhật thất bại")),
    );

    if (res["code"] == 200) {
      _loadUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar tròn
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: primary1.withOpacity(0.15),
                    backgroundImage:
                        _avatarImage != null ? FileImage(_avatarImage!) : null,
                    child: _avatarImage == null
                        ? Icon(Icons.person, size: 60, color: primary1)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            _avatarImage = File(picked.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: primary1,
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildInput("Họ và tên", _nameController),
            const SizedBox(height: 15),

            _buildInput("Email", _emailController, readOnly: true),
            const SizedBox(height: 15),

            _buildInput("Số điện thoại", _phoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 15),

            _buildInput("Địa chỉ", _addressController),
            const SizedBox(height: 30),

            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  // ======================= UI Helpers =======================

  Widget _buildInput(String label, TextEditingController controller,
      {bool readOnly = false, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary1, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => null,
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                primary1,
                primary2,
              ],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              "Cập nhật",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

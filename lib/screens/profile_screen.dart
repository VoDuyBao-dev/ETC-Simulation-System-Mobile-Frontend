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
  bool _isUpdating = false;

  bool editName = false;
  bool editPhone = false;
  bool editAddress = false;

  bool get isEditingSomething => editName || editPhone || editAddress;

  File? _avatarImage;

  final Color primaryBlue = const Color(0xFF0099FF);
  final Color primaryGreen = const Color(0xFF00CC99);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _blankFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final res = await ApiService.getMyInfo();

    if (res["code"] == 200) {
      final user = res["result"];
      _nameController.text = user["fullname"] ?? "";
      _emailController.text = user["email"] ?? "";
      _phoneController.text = user["phone"] ?? "";
      _addressController.text = user["address"] ?? "";
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);

    final body = {
      "username": _emailController.text,
      "fullname": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
    };

    final res = await ApiService.updateUserInfo(body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );

    if (res["code"] == 200) {
      FocusScope.of(context).requestFocus(_blankFocus);

      setState(() {
        editName = false;
        editPhone = false;
        editAddress = false;
      });
    }

    setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(_blankFocus),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildAvatar(),
                    _buildForm(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 45,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 50,
            left: 60,
            child: const Text(
              "Thông tin cá nhân",
              style: TextStyle(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Transform.translate(
      offset: const Offset(0, -55),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: Colors.white,
            backgroundImage:
                _avatarImage != null ? FileImage(_avatarImage!) : null,
            child: _avatarImage == null
                ? Icon(Icons.person,
                    size: 65, color: primaryBlue.withOpacity(0.9))
                : null,
          ),

          // Nhỏ lại
          Positioned(
            bottom: 2,
            right: MediaQuery.of(context).size.width * 0.32,
            child: InkWell(
              onTap: () async {
                final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => _avatarImage = File(img.path));
              },
              child: CircleAvatar(
                radius: 18, // nhỏ hơn
                backgroundColor: primaryBlue,
                child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFloatingField(
            "Họ và tên",
            _nameController,
            editable: editName,
            onEdit: () => setState(() => editName = true),
          ),
          const SizedBox(height: 15),

          _buildFloatingField(
            "Email",
            _emailController,
            editable: false,
            readOnly: true,
          ),
          const SizedBox(height: 15),

          _buildFloatingField(
            "Số điện thoại",
            _phoneController,
            editable: editPhone,
            onEdit: () => setState(() => editPhone = true),
          ),
          const SizedBox(height: 15),

          _buildFloatingField(
            "Địa chỉ",
            _addressController,
            editable: editAddress,
            onEdit: () => setState(() => editAddress = true),
          ),
          const SizedBox(height: 25),

          if (isEditingSomething) _buildUpdateButton(),
        ],
      ),
    );
  }

  // Label nằm trên field
  Widget _buildFloatingField(
    String label,
    TextEditingController controller, {
    bool editable = true,
    bool readOnly = false,
    VoidCallback? onEdit,
  }) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          readOnly: readOnly ? true : !editable,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primaryBlue, width: 1.8),
            ),
          ),
        ),

        if (onEdit != null)
          Positioned(
            right: 12,
            top: 12,
            child: InkWell(
              onTap: onEdit,
              child: Icon(
                Icons.edit,
                size: 20,
                color: editable ? primaryBlue : Colors.grey,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, primaryGreen]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Cập nhật",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

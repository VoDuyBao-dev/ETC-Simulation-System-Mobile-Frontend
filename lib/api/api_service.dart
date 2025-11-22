import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttoll_app/models/user.dart';
import 'package:smarttoll_app/models/auth_service.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080/etc";

  // Token trong RAM
  static String? accessToken;

  // =============== TOKEN HANDLING (NEW - FIXED) =============

  /// Lưu token vào SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
    accessToken = token;
  }

  /// Load token từ SharedPreferences
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");
  }

  /// Xóa token khi logout
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    accessToken = null;
  }

  static Future<void> logout() async {
    await clearToken();
    AuthService.clearUser(); // 🔑 Xóa user đồng bộ
  }

  // ======================== VERIFY OTP ======================

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final url = Uri.parse("$baseUrl/auth/otp/verify");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otpCode": otpCode,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"code": 500, "message": "Không thể kết nối tới server"};
    }
  }

  // =========================== LOGIN =========================

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (data["code"] == 200 && data["result"] != null) {
        String token = data["result"]["token"];
        await saveToken(token);

        final userJson = data["result"];
        final User loggedInUser = User(
          id: userJson["id"]?.toString() ?? "0",
          username: userJson["username"] ?? username,
          fullName: userJson["fullname"] ?? "",
          email: userJson["email"] ?? "",
          balance: double.tryParse(userJson["balance"]?.toString() ?? "0") ?? 0.0,
        );

        AuthService.setUser(loggedInUser); // 🔑 Cập nhật user
      }

      return data;
    } catch (e) {
      return {"code": 500, "message": "Không thể kết nối tới server"};
    }
  }

  // ========================== REGISTER ======================

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String fullname,
    required String email,
    required String phone,
    required String address,
    required String role,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "confirmPassword": confirmPassword,
          "fullname": fullname,
          "email": email,
          "phone": phone,
          "address": address,
          "role": role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"code": 500, "message": "Không thể kết nối tới server"};
    }
  }

  // ======================== GET PROFILE =====================

  static Future<Map<String, dynamic>> getMyInfo() async {
    await loadToken(); // Load token mỗi lần gọi API

    if (accessToken == null) {
      return {"code": 401, "message": "Chưa đăng nhập (token null)"};
    }

    final url = Uri.parse("$baseUrl/auth/myInfo");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"code": 500, "message": "Không thể kết nối tới server"};
    }
  }

  // ====================== UPDATE PROFILE ====================

  static Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> body) async {
    await loadToken();

    if (accessToken == null) {
      return {"code": 401, "message": "Chưa đăng nhập (token null)"};
    }

    final url = Uri.parse("$baseUrl/auth/updateInfo");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"code": 500, "message": "Không thể kết nối tới server"};
    }
  }

  // ==================== FAKE HOME SERVICES ==================

  static Future<List<Map<String, String>>> fetchHomeServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'icon': '🚗',
        'title': 'Nạp tiền tài khoản',
        'description': 'Nạp tiền để sử dụng SmartToll'
      },
      {
        'icon': '🧾',
        'title': 'Lịch sử giao dịch',
        'description': 'Xem lại giao dịch qua trạm'
      },
      {
        'icon': '💳',
        'title': 'Liên kết ngân hàng',
        'description': 'Kết nối thẻ ngân hàng'
      },
      {
        'icon': '⚙️',
        'title': 'Cài đặt tài khoản',
        'description': 'Quản lý thông tin cá nhân'
      },
    ];
  }

  static Future<Map<String, dynamic>> createVNPAYPayment({
    required String amount,
    String? bankCode,
  }) async {
    await loadToken();

    if (accessToken == null) {
      return {"code": 401, "message": "Chưa đăng nhập (token null)"};
    }

    try {
      // Tạo query params
      final queryParams = {
        "amount": amount,
        if (bankCode != null && bankCode.isNotEmpty) "bankCode": bankCode,
      };

      // Tạo URI với query params
      final uri = Uri.parse("$baseUrl/payment/vn-pay")
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      return data; // Trả về đúng format backend trả
    } catch (e) {
      return {
        "code": 500,
        "message": "Không thể kết nối tới server: ${e.toString()}"
      };
    }
  }

  // ==================== GET WALLET BALANCE ====================
  static Future<double> getWalletBalance() async {
    await loadToken();

    if (accessToken == null) {
      return 0.0;
    }

    final url = Uri.parse("$baseUrl/customer/wallet");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data['code'] == 200 && data['result'] != null) {
        return double.tryParse(data['result'].toString()) ?? 0.0;
      }

      return 0.0;
    } catch (e) {
      print("Lỗi lấy số dư ví: $e");
      return 0.0;
    }
  }

  /// Lấy lịch sử nạp tiền
  static Future<List<Map<String, dynamic>>> getRechargeHistory({
    int page = 0,
    int size = 10,
  }) async {
    await loadToken();

    if (accessToken == null) {
      return [];
    }

    final uri = Uri.parse("$baseUrl/customer/topup/history")
        .replace(queryParameters: {
      "page": page.toString(),
      "size": size.toString(),
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["code"] == 200 && data["result"]?["content"] != null) {
        final List<dynamic> content = data["result"]["content"];
        return content.map((item) {
          final double amount = (item["amount"] is num)
              ? item["amount"].toDouble()
              : double.tryParse(item["amount"].toString()) ?? 0.0;

          final double balanceAfter = item["balanceAfter"] != null
              ? (item["balanceAfter"] is num
              ? item["balanceAfter"].toDouble()
              : double.tryParse(item["balanceAfter"].toString()) ?? 0.0)
              : amount; // fallback nếu không có balanceAfter

          final String createdAt = item["createdAt"] ?? "";
          final DateTime dateTime = DateTime.tryParse(createdAt) ?? DateTime.now();

          return {
            "amount": amount,
            "balanceAfter": balanceAfter,
            "method": item["method"] ?? "VNPAY",
            "dateTime": dateTime,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      print("Lỗi lấy lịch sử nạp tiền: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactionHistory({
    int page = 0,
    int size = 20,
  }) async {
    await loadToken();

    if (accessToken == null) {
      return [];
    }

    final uri = Uri.parse("$baseUrl/customer/wallet/history").replace(
      queryParameters: {
        "page": page.toString(),
        "size": size.toString(),
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data["code"] == 200 && data["result"]?["content"] != null) {
        final List<dynamic> content = data["result"]["content"];

        return content.map((item) {
          final double amount = (item["amount"] is num)
              ? item["amount"].toDouble()
              : double.tryParse(item["amount"].toString()) ?? 0.0;

          final double balanceAfter = item["balanceAfter"] != null
              ? (item["balanceAfter"] is num
              ? item["balanceAfter"].toDouble()
              : double.tryParse(item["balanceAfter"].toString()) ?? 0.0)
              : 0.0;

          final String dateTimeStr = item["dateTime"] ?? "";
          final DateTime dateTime = DateTime.tryParse(dateTimeStr.replaceAll(" ", "T")) ?? DateTime.now();

          return {
            "amount": amount.abs(),
            "balanceAfter": balanceAfter,
            "stationName": item["stationName"]?.toString() ?? "Không rõ trạm",
            "description": item["description"]?.toString() ?? "Trừ phí qua trạm",
            "plateNumber": item["plateNumber"]?.toString() ?? "",
            "dateTime": dateTime,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      print("Lỗi lấy lịch sử giao dịch qua trạm: $e");
      return [];
    }
  }
}

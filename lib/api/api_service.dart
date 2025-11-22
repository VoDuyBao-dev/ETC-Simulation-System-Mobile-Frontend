import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';


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
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data["code"] == 200 && data["result"] != null) {
        String token = data["result"]["token"];
        await saveToken(token); // Lưu token đúng cách
        print("TOKEN LƯU THÀNH CÔNG: $token");
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

  // HEADER (thêm Bearer token)
  Future<Map<String, String>> _getHeaders() async {
    if (accessToken == null) {
      await ApiService.loadToken();
    }

    if (accessToken == null) {
      throw Exception("Không có token. Người dùng chưa đăng nhập.");
    }

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken"
    };
  }

  // HANDLE ERROR
  Exception _handleError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final msg = body["message"] ?? body["error"] ?? "Lỗi không xác định";

      return Exception("Lỗi ${response.statusCode}: $msg");
    } catch (_) {
      return Exception("Lỗi ${response.statusCode}: ${response.reasonPhrase}");
    }
  }

  // GET - Lấy danh sách xe
  Future<List<dynamic>> getVehicles() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/user/vehicles"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List) {
          return body;
        } else {
          throw Exception("Dữ liệu trả về không phải dạng danh sách.");
        }
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ Lỗi gọi API getVehicles: $e");
      throw Exception("Không thể tải danh sách xe. Lỗi: $e");
    }
  }

  Future<bool> addVehicle({
    required String plateNumber,
    required String vehicleType,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = {
        "plateNumber": plateNumber,
        "vehicleType": vehicleType,
        "tagUid": "",
        "tagStatus": "ACTIVE",
        "vehicleStatus": "ACTIVE",
      };

      final response = await http.post(
        Uri.parse("$baseUrl/user/vehicles/register"),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ addVehicle error: $e");
      throw Exception("Không thể thêm xe. Lỗi: $e");
    }
  }


  Future<Map<String, dynamic>> updateVehicleStatus(
      String vehicleId, bool active) async {
    try {
      final headers = await _getHeaders();
      final body = {
        "status": active ? "ACTIVE" : "INACTIVE",
      };

      final response = await http.put(
        Uri.parse("$baseUrl/user/vehicles/$vehicleId/status"),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ updateVehicleStatus error: $e");
      throw Exception("Không thể cập nhật trạng thái xe: $e");
    }
  }

// UPDATE RFID TAG STATUS — chỉ đổi tagStatus
  Future<Map<String, dynamic>> updateRfidTagStatus(String vehicleId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse("$baseUrl/user/vehicles/$vehicleId/status-rfidTtag"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print("❌ updateRfidTagStatus error: $e");
      throw Exception("Không thể cập nhật trạng thái E-Tag: $e");
    }
  }
}
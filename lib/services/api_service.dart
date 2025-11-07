import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL backend (đổi thành domain thật)
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  // ===================== ĐĂNG KÝ =====================
  static Future<Map<String, dynamic>> register(
      String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return {
        'success': true,
        'message': 'Đăng ký thành công (mô phỏng)',
        'data': {
          'email': email,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi đăng ký: $e',
      };
    }
  }

  // ===================== XÁC MINH OTP =====================
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (otp == '123456') {
        return {
          'success': true,
          'message': 'Xác minh OTP thành công (mô phỏng)',
        };
      } else {
        return {
          'success': false,
          'message': 'OTP sai, vui lòng thử lại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi xác minh OTP: $e',
      };
    }
  }

  // ===================== ĐĂNG NHẬP =====================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (email == 'test@gmail.com' && password == '123456') {
        return {
          'success': true,
          'message': 'Đăng nhập thành công',
        };
      } else {
        return {
          'success': false,
          'message': 'Tài khoản hoặc mật khẩu không đúng',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi đăng nhập: $e',
      };
    }
  }

  // ===================== LẤY DỮ LIỆU TRANG CHỦ =====================
  static Future<List<Map<String, String>>> fetchHomeServices() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'icon': '🚗',
          'title': 'Nạp tiền tài khoản',
          'description': 'Nạp tiền để sử dụng dịch vụ SmartToll dễ dàng',
        },
        {
          'icon': '🧾',
          'title': 'Tra cứu giao dịch',
          'description': 'Xem lại lịch sử qua trạm thu phí',
        },
        {
          'icon': '💳',
          'title': 'Liên kết ngân hàng',
          'description': 'Kết nối thẻ ngân hàng với tài khoản SmartToll',
        },
        {
          'icon': '⚙️',
          'title': 'Cài đặt tài khoản',
          'description': 'Thay đổi thông tin và mật khẩu cá nhân',
        },
      ];
    } catch (e) {
      print('Lỗi khi lấy dữ liệu trang chủ: $e');
      return [];
    }
  }

  // ===================== LẤY THÔNG TIN HỒ SƠ NGƯỜI DÙNG =====================
  static Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      //  Khi chưa có server thật, bạn có thể giữ đoạn fake dưới đây:
      await Future.delayed(const Duration(seconds: 1));
      return {
        "success": true,
        "data": {
          "name": "Nguyễn Văn A",
          "email": "test@gmail.com",
          "phone": "0901234567",
          "address": "123 Nguyễn Trãi, TP.HCM",
        }
      };

      //  Khi có API thật, thay bằng đoạn này:
      /*
      final url = Uri.parse('$baseUrl/profile');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": "Lỗi: ${res.statusCode}"};
      }
      */
    } catch (e) {
      return {"success": false, "message": "Lỗi khi tải hồ sơ: $e"};
    }
  }

  // ===================== CẬP NHẬT HỒ SƠ NGƯỜI DÙNG =====================
  static Future<Map<String, dynamic>> updateProfileData(
      String field, String value) async {
    try {
      //  Khi chưa có server thật, chỉ giả lập phản hồi:
      await Future.delayed(const Duration(seconds: 1));
      return {
        "success": true,
        "message": "Đã cập nhật $field thành công (mô phỏng)"
      };

      //  Khi có server thật:
      /*
      final url = Uri.parse('$baseUrl/profile/update');
      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"field": field, "value": value}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {"success": true, "message": data['message'] ?? "Cập nhật thành công"};
      } else {
        return {"success": false, "message": "Lỗi: ${res.statusCode}"};
      }
      */
    } catch (e) {
      return {"success": false, "message": "Lỗi khi cập nhật: $e"};
    }
  }
}

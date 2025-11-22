import 'package:smarttoll_app/models/user.dart';
import 'dart:async';

class AuthService {
  static User? _currentUser;
  static final _userController = StreamController<User?>.broadcast();

  // Stream theo dõi user
  static Stream<User?> get userStream => _userController.stream;

  // Getter
  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // Cập nhật user
  static void setUser(User? user) {
    _currentUser = user;
    _userController.add(user); // phát sự kiện mới
  }

  // Xóa user
  static void clearUser() {
    _currentUser = null;
    _userController.add(null);
  }

  // Khi app đóng, giải phóng stream
  static void dispose() {
    _userController.close();
  }
}

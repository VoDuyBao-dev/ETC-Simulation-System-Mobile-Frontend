class User {
  final String id;          // luôn là String để backend kiểu số cũng không lỗi
  final String? username;   // từ bản 2
  final String? name;       // từ bản 1
  final String email;
  final String? fullName;   // từ bản 2
  final double balance;     // từ bản 1

  User({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.fullName,
    this.balance = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '0',

      // Có backend dùng "name", có backend dùng "username"
      username: json['username'] as String?,
      name: json['name'] as String?,

      email: json['email'] ?? '',

      // full name có thể null
      fullName: json['fullName'] as String?,

      // balance từ API có thể int hoặc double hoặc null
      balance: (json['balance'] != null)
          ? double.tryParse(json['balance'].toString()) ?? 0
          : 0,
    );
  }
}

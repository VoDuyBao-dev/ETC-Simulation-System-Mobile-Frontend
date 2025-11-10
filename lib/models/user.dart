class User {
  final int id;
  final String name;
  final String email;
  final double balance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

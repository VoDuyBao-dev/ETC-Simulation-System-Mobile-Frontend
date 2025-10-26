class Vehicle {
  final String plate;
  final String type;

  Vehicle({required this.plate, required this.type});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plate: json['plate'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
    );
  }
}

class Vehicle {
  final int id;
  final String plateNumber;
  final String tagUid;
  final String tagStatus;
  final String vehicleType;
  final String? vehicleStatus;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.tagUid,
    required this.tagStatus,
    required this.vehicleType,
    this.vehicleStatus,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"],
      plateNumber: json["plateNumber"],
      tagUid: json["tagUid"],
      tagStatus: json["tagStatus"],
      vehicleType: json["vehicleType"],
      vehicleStatus: json["vehicleStatus"],
    );
  }
}

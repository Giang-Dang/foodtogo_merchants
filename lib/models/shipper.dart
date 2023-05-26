class Shipper {
  final int userId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String vehicleType;
  final String vehicleNumberPlate;
  final double rating;
  final int successOrderCount;
  final int cancelledOrderCount;

  const Shipper({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.vehicleType,
    required this.vehicleNumberPlate,
    required this.rating,
    this.successOrderCount = 0,
    this.cancelledOrderCount = 0,
  });

  factory Shipper.fromJson(Map<String, dynamic> json) {
    return Shipper(
        userId: json['userId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        middleName: json['middleName'],
        vehicleType: json['vehicleType'],
        vehicleNumberPlate: json['vehicleNumberPlate'],
        rating: json['rating'],
        successOrderCount: json['successOrderCount'],
        cancelledOrderCount: json['cancelledOrderCount']);
  }
}

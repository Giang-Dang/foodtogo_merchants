import 'dart:io';

class Merchant {
  const Merchant({
    required this.merchantId,
    required this.userId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.geoLatitude,
    required this.geoLongitude,
    required this.isDeleted,
    required this.imagePath,
    required this.rating,
  });
  final int merchantId;
  final int userId;
  final String name;
  final String address;
  final String phoneNumber;
  final double geoLatitude;
  final double geoLongitude;
  final bool isDeleted;
  final String imagePath;
  final double rating;
}

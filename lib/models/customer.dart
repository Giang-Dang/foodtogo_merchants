class Customer {
  final int customerId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String address;
  final double rating;
  final int successOrderCount;
  final int cancelledOrderCount;

  const Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.address,
    required this.rating,
    this.successOrderCount = 0,
    this.cancelledOrderCount = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        customerId: json['customerId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        middleName: json['middleName'],
        address: json['address'],
        rating: json['rating'],
        successOrderCount: json['successOrderCount'],
        cancelledOrderCount: json['cancelledOrderCount']);
  }
}

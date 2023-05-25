class MenuItem {
  const MenuItem({
    required this.id,
    required this.merchantId,
    required this.itemType,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.imagePath,
  });
  final int id;
  final int merchantId;
  final String itemType;
  final String name;
  final String description;
  final double unitPrice;
  final String imagePath;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      merchantId: json['merchantId'],
      itemType: json['itemType'],
      name: json['name'],
      description: json['description'],
      unitPrice: json['unitPrice'],
      imagePath: json['imagePath'],
    );
  }
}

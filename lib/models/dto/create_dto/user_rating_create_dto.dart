class UserRatingCreateDTO {
  final int id;
  final int fromUserId;
  final String fromUserType;
  final int toUserId;
  final String toUserType;
  final double rating;

  UserRatingCreateDTO({
    required this.id,
    required this.fromUserId,
    required this.fromUserType,
    required this.toUserId,
    required this.toUserType,
    required this.rating,
  });

  factory UserRatingCreateDTO.fromJson(Map<String, dynamic> json) {
    return UserRatingCreateDTO(
      id: json['Id'],
      fromUserId: json['FromUserId'],
      fromUserType: json['FromUserType'],
      toUserId: json['ToUserId'],
      toUserType: json['ToUserType'],
      rating: json['Rating'],
    );
  }
}
class MUAModel {
  final int id;
  final String name;
  final String location;
  final String price;
  final String image;

  MUAModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.image,
  });

  factory MUAModel.fromJson(Map<String, dynamic> json) {
    return MUAModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      price: json['price'],
      image: json['image'],
    );
  }
}

// models/mua_profile_model.dart
class MUAProfile {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? photoUrl;
  final List<String> services;
  final String? experience;
  final String? portfolioUrl;
  final double? rating;
  final int? totalReviews;

  MUAProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.photoUrl,
    required this.services,
    this.experience,
    this.portfolioUrl,
    this.rating,
    this.totalReviews,
  });

  factory MUAProfile.fromJson(Map<String, dynamic> json) {
    return MUAProfile(
      userId: json['user_id'] ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      location: json['location'],
      photoUrl: json['photo_url'],
      services: json['services'] != null 
          ? List<String>.from(json['services']) 
          : [],
      experience: json['experience'],
      portfolioUrl: json['portfolio_url'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['total_reviews'],
    );
  }
}
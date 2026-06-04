// models/photographer_preview_model.dart (YANG SUDAH KAMU BUAT)
class PhotographerModel {
  final int id;
  final String name;
  final String location;
  final String price;
  final String image;

  PhotographerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.image,
  });

  factory PhotographerModel.fromJson(Map<String, dynamic> json) {
    return PhotographerModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      price: json['price'],
      image: json['image'],
    );
  }
}

// models/photographer_profile_model.dart (UNTUK HALAMAN PROFILE)
class PhotographerProfile {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? photoUrl;
  final List<String> services; // ["Wedding", "Pre-wedding", dll]
  final String? experience;
  final String? portfolioUrl;
  final double? rating;
  final int? totalReviews;

  PhotographerProfile({
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

  factory PhotographerProfile.fromJson(Map<String, dynamic> json) {
    return PhotographerProfile(
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
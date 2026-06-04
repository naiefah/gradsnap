// models/user_model.dart
enum UserRole {
  customer,
  mua,
  photographer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.mua:
        return 'MUA';
      case UserRole.photographer:
        return 'Photographer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'mua':
        return UserRole.mua;
      case 'photographer':
        return UserRole.photographer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class User {
  final int id;
  final String firebaseUid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? location;
  final String? photoUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.photoUrl,
    this.createdAt,
  });

  bool get isCustomer => role == UserRole.customer;
  bool get isMUA => role == UserRole.mua;
  bool get isPhotographer => role == UserRole.photographer;
  bool get isAdmin => role == UserRole.admin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firebaseUid: json['firebase_uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'customer'),
      phone: json['phone'],
      location: json['location'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phone,
      'location': location,
      'photo_url': photoUrl,
    };
  }

  User copyWith({
    int? id,
    String? firebaseUid,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? location,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
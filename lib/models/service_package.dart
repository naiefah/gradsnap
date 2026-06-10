import 'dart:convert';

class ServicePackage {
  final int id;
  final int vendorId;
  final String name;
  final String description;
  final double price;
  final String duration;
  final List<String> inclusions;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final String? vendorType; // TAMBAHKAN INI
  final String? vendorName;  // TAMBAHKAN INI

  ServicePackage({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.inclusions,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    this.vendorType,     // TAMBAHKAN
    this.vendorName,     // TAMBAHKAN
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    List<String> inclusionsList = [];
    if (json['inclusions'] != null) {
      try {
        final inclusionsData = json['inclusions'];
        if (inclusionsData is String) {
          inclusionsList = List<String>.from(jsonDecode(inclusionsData));
        } else if (inclusionsData is List) {
          inclusionsList = List<String>.from(inclusionsData);
        }
      } catch (e) {
        inclusionsList = [];
      }
    }

    double priceValue;
    final priceData = json['price'];
    if (priceData is num) {
      priceValue = priceData.toDouble();
    } else if (priceData is String) {
      priceValue = double.tryParse(priceData) ?? 0.0;
    } else {
      priceValue = 0.0;
    }

    return ServicePackage(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: priceValue,
      duration: json['duration'] ?? '3 jam',
      inclusions: inclusionsList,
      imageUrl: json['image_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      vendorType: json['vendor_type'],      // TAMBAHKAN - dari join table
      vendorName: json['vendor_name'],      // TAMBAHKAN - dari join table
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'inclusions': jsonEncode(inclusions),
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ServicePackage copyWith({
    int? id,
    int? vendorId,
    String? name,
    String? description,
    double? price,
    String? duration,
    List<String>? inclusions,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    String? vendorType,
    String? vendorName,
  }) {
    return ServicePackage(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      inclusions: inclusions ?? this.inclusions,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      vendorType: vendorType ?? this.vendorType,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  String get formattedPrice => 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  
  bool get isMUA => vendorType == 'mua';
  bool get isPhotographer => vendorType == 'photographer';
}
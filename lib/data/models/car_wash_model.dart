import '../../domain/entities/car_wash.dart';

class CarWashModel extends CarWash {
  const CarWashModel({
    required super.id,
    required super.name,
    required super.address,
    required super.rating,
    required super.reviewCount,
    required super.latitude,
    required super.longitude,
  });

  factory CarWashModel.fromJson(Map<String, dynamic> json) {
    return CarWashModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
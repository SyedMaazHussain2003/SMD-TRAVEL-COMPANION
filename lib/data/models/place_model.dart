import '../../domain/entities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.title,
    required super.url,
    required super.thumbnailUrl,
    super.isFavorite,
    super.description,
    super.latitude,
    super.longitude,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String? ?? 'A beautiful place to visit. Experience the wonderful scenery and culture. This is a generic description for the place since the API does not provide one, but we use AnimatedSize to expand this text and show a rich UI.',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'isFavorite': isFavorite,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PlaceModel.fromEntity(Place entity) {
    return PlaceModel(
      id: entity.id,
      title: entity.title,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      isFavorite: entity.isFavorite,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
  @override
  PlaceModel copyWith({
    int? id,
    String? title,
    String? url,
    String? thumbnailUrl,
    bool? isFavorite,
    String? description,
    double? latitude,
    double? longitude,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

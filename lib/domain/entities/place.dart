import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final bool isFavorite;
  final String description;
  final double latitude;
  final double longitude;

  const Place({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    this.isFavorite = false,
    this.description = 'A beautiful place to visit. Experience the wonderful scenery and culture. This is a generic description for the place since the API does not provide one, but we use AnimatedSize to expand this text and show a rich UI.',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Place copyWith({
    int? id,
    String? title,
    String? url,
    String? thumbnailUrl,
    bool? isFavorite,
    String? description,
    double? latitude,
    double? longitude,
  }) {
    return Place(
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

  @override
  List<Object?> get props => [id, title, url, thumbnailUrl, isFavorite, description, latitude, longitude];
}

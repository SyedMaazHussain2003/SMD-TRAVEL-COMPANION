import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/travel_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/place_model.dart';

class TravelRepositoryImpl implements TravelRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TravelRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<(Failure?, List<Place>?)> getPlaces({int start = 0, int limit = 20}) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlaces = await remoteDataSource.getPlaces(start, limit);
        final favorites = await localDataSource.getFavoritePlaces();
        final mergedPlaces = remotePlaces.map((remote) {
          final isFav = favorites.any((fav) => fav.id == remote.id);
          return remote.copyWith(isFavorite: isFav);
        }).toList();

        if (start == 0) {
          await localDataSource.cachePlaces(mergedPlaces);
        }
        return (null, mergedPlaces);
      } on ServerFailure catch (e) {
        // Fallback to cache
        try {
          final localPlaces = await localDataSource.getCachedPlaces();
          return (null, localPlaces);
        } on CacheFailure {
          return (e, null);
        }
      }
    } else {
      try {
        final localPlaces = await localDataSource.getCachedPlaces();
        return (null, localPlaces);
      } on CacheFailure catch (e) {
        return (e, null);
      }
    }
  }

  @override
  Future<(Failure?, Weather?)> getWeather(double lat, double lon) async {
    if (await networkInfo.isConnected) {
      try {
        final weather = await remoteDataSource.getWeather(lat, lon);
        return (null, weather);
      } on ServerFailure catch (e) {
        return (e, null);
      }
    } else {
      return (const NetworkFailure('No internet connection'), null);
    }
  }

  @override
  Future<(Failure?, List<Place>?)> getFavoritePlaces() async {
    try {
      final favorites = await localDataSource.getFavoritePlaces();
      return (null, favorites);
    } catch (e) {
      return (CacheFailure(e.toString()), null);
    }
  }

  @override
  Future<Failure?> toggleFavorite(Place place) async {
    try {
      await localDataSource.toggleFavorite(PlaceModel.fromEntity(place));
      return null;
    } catch (e) {
      return CacheFailure(e.toString());
    }
  }

  @override
  Future<Failure?> cachePlaces(List<Place> places) async {
    try {
      await localDataSource.cachePlaces(places.map((p) => PlaceModel.fromEntity(p)).toList());
      return null;
    } catch (e) {
      return CacheFailure(e.toString());
    }
  }
}

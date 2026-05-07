import '../../core/error/failures.dart';
import '../entities/place.dart';
import '../entities/weather.dart';

abstract class TravelRepository {
  Future<(Failure?, List<Place>?)> getPlaces({int start = 0, int limit = 20});
  Future<(Failure?, Weather?)> getWeather(double lat, double lon);
  Future<(Failure?, List<Place>?)> getFavoritePlaces();
  Future<Failure?> toggleFavorite(Place place);
  Future<Failure?> cachePlaces(List<Place> places);
}

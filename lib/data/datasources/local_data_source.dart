import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../models/place_model.dart';
import 'mock_data.dart';

abstract class LocalDataSource {
  Future<List<PlaceModel>> getCachedPlaces();
  Future<void> cachePlaces(List<PlaceModel> placesToCache);
  Future<List<PlaceModel>> getFavoritePlaces();
  Future<void> toggleFavorite(PlaceModel place);
}

const cachedPlacesKey = 'CACHED_PLACES';
const favoritePlacesKey = 'FAVORITE_PLACES';

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cachePlaces(List<PlaceModel> placesToCache) {
    final List<String> jsonList = placesToCache.map((place) => json.encode(place.toJson())).toList();
    return sharedPreferences.setStringList(cachedPlacesKey, jsonList);
  }

  @override
  Future<List<PlaceModel>> getCachedPlaces() {
    final jsonList = sharedPreferences.getStringList(cachedPlacesKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      return Future.value(jsonList.map((jsonStr) => PlaceModel.fromJson(json.decode(jsonStr))).toList());
    } else {
      // Fallback to MockData for initial offline experience
      return Future.value(MockData.places);
    }
  }

  @override
  Future<List<PlaceModel>> getFavoritePlaces() {
    final jsonList = sharedPreferences.getStringList(favoritePlacesKey);
    if (jsonList != null) {
      return Future.value(jsonList.map((jsonStr) => PlaceModel.fromJson(json.decode(jsonStr))).toList());
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<void> toggleFavorite(PlaceModel place) async {
    final List<PlaceModel> favorites = await getFavoritePlaces();
    final index = favorites.indexWhere((p) => p.id == place.id);
    
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(place.copyWith(isFavorite: true) as PlaceModel);
    }
    
    final List<String> jsonList = favorites.map((p) => json.encode(p.toJson())).toList();
    await sharedPreferences.setStringList(favoritePlacesKey, jsonList);
  }
}

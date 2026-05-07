import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_favorite_places.dart';
import '../../domain/usecases/get_places.dart';
import '../../domain/usecases/get_weather.dart';
import '../../domain/usecases/toggle_favorite.dart';

part 'travel_event.dart';
part 'travel_state.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  final GetPlaces getPlaces;
  final GetWeather getWeather;
  final GetFavoritePlaces getFavoritePlaces;
  final ToggleFavorite toggleFavorite;

  TravelBloc({
    required this.getPlaces,
    required this.getWeather,
    required this.getFavoritePlaces,
    required this.toggleFavorite,
  }) : super(TravelInitial()) {
    on<FetchPlacesEvent>(_onFetchPlaces);
    on<FetchWeatherEvent>(_onFetchWeather);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SearchPlacesEvent>(_onSearchPlaces);
  }

  List<Place> _allPlaces = [];

  Future<void> _onFetchPlaces(FetchPlacesEvent event, Emitter<TravelState> emit) async {
    if (event.isRefresh) {
      emit(TravelLoading());
    } else if (state is TravelLoaded) {
      _allPlaces = (state as TravelLoaded).places;
    } else {
      emit(TravelLoading());
    }

    final result = await getPlaces(GetPlacesParams(start: 0, limit: 50));
    result.$1 != null
        ? emit(TravelError(message: result.$1!.message))
        : () {
            _allPlaces = result.$2!;
            emit(TravelLoaded(places: _allPlaces));
          }();
  }

  Future<void> _onFetchWeather(FetchWeatherEvent event, Emitter<TravelState> emit) async {
    if (state is TravelLoaded) {
      emit((state as TravelLoaded).copyWith(isWeatherLoading: true, weather: null));
      
      final result = await getWeather(GetWeatherParams(lat: event.lat, lon: event.lon));
      
      if (state is TravelLoaded) {
        if (result.$1 != null) {
          emit((state as TravelLoaded).copyWith(isWeatherLoading: false));
        } else {
          emit((state as TravelLoaded).copyWith(
            isWeatherLoading: false, 
            weather: result.$2!,
          ));
        }
      }
    }
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<TravelState> emit) async {
    await toggleFavorite(event.place);
    
    // Update the master list immutably
    final masterIndex = _allPlaces.indexWhere((p) => p.id == event.place.id);
    if (masterIndex >= 0) {
      final updatedMaster = List<Place>.from(_allPlaces);
      updatedMaster[masterIndex] = updatedMaster[masterIndex].copyWith(isFavorite: !event.place.isFavorite);
      _allPlaces = updatedMaster;
    }

    // Update the current UI state
    if (state is TravelLoaded) {
      final currentPlaces = (state as TravelLoaded).places;
      final index = currentPlaces.indexWhere((p) => p.id == event.place.id);
      if (index >= 0) {
        final updatedPlaces = List<Place>.from(currentPlaces);
        updatedPlaces[index] = updatedPlaces[index].copyWith(isFavorite: !event.place.isFavorite);
        emit(TravelLoaded(places: updatedPlaces));
      }
    }
  }

  Future<void> _onSearchPlaces(SearchPlacesEvent event, Emitter<TravelState> emit) async {
    if (event.query.isEmpty) {
      emit(TravelLoaded(places: _allPlaces));
    } else {
      final filteredPlaces = _allPlaces.where((place) {
        return place.title.toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      emit(TravelLoaded(places: filteredPlaces));
    }
  }
}

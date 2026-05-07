part of 'travel_bloc.dart';

abstract class TravelState extends Equatable {
  const TravelState();
  
  @override
  List<Object?> get props => [];
}

class TravelInitial extends TravelState {}

class TravelLoading extends TravelState {}

class TravelLoaded extends TravelState {
  final List<Place> places;
  final Weather? weather;
  final bool isWeatherLoading;

  const TravelLoaded({
    required this.places,
    this.weather,
    this.isWeatherLoading = false,
  });

  TravelLoaded copyWith({
    List<Place>? places,
    Weather? weather,
    bool? isWeatherLoading,
  }) {
    return TravelLoaded(
      places: places ?? this.places,
      weather: weather ?? this.weather,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
    );
  }

  @override
  List<Object?> get props => [places, weather, isWeatherLoading];
}

class TravelError extends TravelState {
  final String message;

  const TravelError({required this.message});

  @override
  List<Object> get props => [message];
}

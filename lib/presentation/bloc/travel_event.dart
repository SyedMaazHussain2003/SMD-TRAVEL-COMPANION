part of 'travel_bloc.dart';

abstract class TravelEvent extends Equatable {
  const TravelEvent();

  @override
  List<Object> get props => [];
}

class FetchPlacesEvent extends TravelEvent {
  final bool isRefresh;
  const FetchPlacesEvent({this.isRefresh = false});
}

class FetchWeatherEvent extends TravelEvent {
  final double lat;
  final double lon;

  const FetchWeatherEvent(this.lat, this.lon);

  @override
  List<Object> get props => [lat, lon];
}

class ToggleFavoriteEvent extends TravelEvent {
  final Place place;

  const ToggleFavoriteEvent(this.place);

  @override
  List<Object> get props => [place];
}

class SearchPlacesEvent extends TravelEvent {
  final String query;

  const SearchPlacesEvent(this.query);

  @override
  List<Object> get props => [query];
}

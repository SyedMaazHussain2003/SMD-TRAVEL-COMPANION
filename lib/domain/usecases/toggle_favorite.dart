import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/place.dart';
import '../repositories/travel_repository.dart';

class ToggleFavorite implements UseCase<Failure?, Place> {
  final TravelRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Failure?> call(Place place) async {
    return await repository.toggleFavorite(place);
  }
}

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/place.dart';
import '../repositories/travel_repository.dart';

class GetFavoritePlaces implements UseCase<(Failure?, List<Place>?), NoParams> {
  final TravelRepository repository;

  GetFavoritePlaces(this.repository);

  @override
  Future<(Failure?, List<Place>?)> call(NoParams params) async {
    return await repository.getFavoritePlaces();
  }
}

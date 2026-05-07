import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/place.dart';
import '../repositories/travel_repository.dart';

class GetPlaces implements UseCase<(Failure?, List<Place>?), GetPlacesParams> {
  final TravelRepository repository;

  GetPlaces(this.repository);

  @override
  Future<(Failure?, List<Place>?)> call(GetPlacesParams params) async {
    return await repository.getPlaces(start: params.start, limit: params.limit);
  }
}

class GetPlacesParams {
  final int start;
  final int limit;

  GetPlacesParams({this.start = 0, this.limit = 20});
}

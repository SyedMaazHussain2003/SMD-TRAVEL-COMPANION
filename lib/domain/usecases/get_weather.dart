import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/weather.dart';
import '../repositories/travel_repository.dart';

class GetWeather implements UseCase<(Failure?, Weather?), GetWeatherParams> {
  final TravelRepository repository;

  GetWeather(this.repository);

  @override
  Future<(Failure?, Weather?)> call(GetWeatherParams params) async {
    return await repository.getWeather(params.lat, params.lon);
  }
}

class GetWeatherParams {
  final double lat;
  final double lon;

  GetWeatherParams({required this.lat, required this.lon});
}

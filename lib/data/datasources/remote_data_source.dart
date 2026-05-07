import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/error/failures.dart';
import '../models/place_model.dart';
import '../models/weather_model.dart';
import 'mock_data.dart';

abstract class RemoteDataSource {
  Future<List<PlaceModel>> getPlaces(int start, int limit);
  Future<WeatherModel> getWeather(double lat, double lon);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<List<PlaceModel>> getPlaces(int start, int limit) async {
    // Return mock data directly for offline feel and real images
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    return MockData.places;
  }

  @override
  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final response = await client.get(
        Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'),
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw const ServerFailure('Failed to fetch weather');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

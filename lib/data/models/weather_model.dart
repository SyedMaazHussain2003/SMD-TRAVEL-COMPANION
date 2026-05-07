import '../../domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperature,
    required super.windSpeed,
    required super.humidity,
    required super.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? json['current_weather'] ?? {};
    return WeatherModel(
      temperature: (current['temperature_2m'] ?? current['temperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (current['wind_speed_10m'] ?? current['windspeed'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 50.0,
      weatherCode: _mapWeatherCode(current['weather_code'] ?? current['weathercode'] as int? ?? 0),
    );
  }

  static String _mapWeatherCode(int code) {
    // Basic mapping from WMO weather codes to string descriptions or icons
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2 || code == 3) return 'Partly cloudy';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}

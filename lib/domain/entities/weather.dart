import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final double windSpeed;
  final double humidity;
  final String weatherCode;

  const Weather({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
  });

  @override
  List<Object?> get props => [temperature, windSpeed, humidity, weatherCode];
}

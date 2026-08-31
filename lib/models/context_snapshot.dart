import 'weather_snapshot.dart';

class ContextSnapshot {
  const ContextSnapshot({
    required this.latitude,
    required this.longitude,
    required this.weather,
    required this.source,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final WeatherSnapshot weather;
  final String source;
  final DateTime capturedAt;
}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// A data model for the weather data fetched from the API.
class Weather {
// ... existing code ...
  final double temperature;
  final int weatherCode;

  Weather({required this.temperature, required this.weatherCode});

  /// A factory constructor to create a Weather instance from a JSON map.
  factory Weather.fromJson(Map<String, dynamic> json) {
// ... existing code ...
    return Weather(
      // Accessing nested JSON values for temperature and weather code.
      temperature: json['current']['temperature_2m'] as double,
      weatherCode: json['current']['weather_code'] as int,
    );
  }
}

/// A service class to fetch real-time weather data from the Open-Meteo API.
class WeatherService {
  // The API URL is now built dynamically in the method below.
  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Fetches the current weather conditions for a given latitude and longitude.
  Future<Weather> getCurrentWeather(double latitude, double longitude) async {
    // Dynamically build the full API URL with the provided coordinates.
    final String apiUrl =
        '$_baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Catches any errors during the API call (e.g., network issues).
      print("Weather API Error: $e");
      // Return a default/fallback Weather object in case of an error.
      return Weather(temperature: 0, weatherCode: 0);
    }
  }
}
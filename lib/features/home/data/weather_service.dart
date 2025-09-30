import 'dart:convert';
import 'package:http/http.dart' as http;

/// A data model for the weather data fetched from the API.
class Weather {
  final double temperature;
  final int weatherCode;

  Weather({required this.temperature, required this.weatherCode});

  /// A factory constructor to create a Weather instance from a JSON map.
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      // Accessing nested JSON values for temperature and weather code.
      temperature: json['current']['temperature_2m'] as double,
      weatherCode: json['current']['weather_code'] as int,
    );
  }
}

/// A service class to fetch real-time weather data from the Open-Meteo API.
class WeatherService {
  // API URL for Nagpur's coordinates, fetching current temperature and weather code.
  static const String _apiUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=21.1458&longitude=79.0882&current=temperature_2m,weather_code';

  /// Fetches the current weather conditions for the predefined location.
  Future<Weather> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
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

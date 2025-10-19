import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jal_shakti_app/features/home/data/location_service.dart';
import 'package:jal_shakti_app/features/home/data/weather_service.dart';

/// Data class to conveniently hold both Position and Placemark data.
class LocationData {
  final Position position;
  final Placemark placemark;
  LocationData(this.position, this.placemark);

  String get displayCity => placemark.locality ?? 'Unknown';
  String get displayState => placemark.administrativeArea ?? 'Location';
}

// 1. Provider for the LocationService instance.
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

// 2. StateNotifier to manage the asynchronous fetching and state of the user's location.
class LocationNotifier extends StateNotifier<AsyncValue<LocationData?>> {
  final Ref _ref;
  LocationNotifier(this._ref)
      : super(const AsyncValue.data(null)); // Start with no location

  Future<void> fetchLocation() async {
    state = const AsyncValue.loading();
    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      final placemark = await locationService.getPlacemarkFromPosition(position);
      state = AsyncValue.data(LocationData(position, placemark));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void clearLocation() {
    state = const AsyncValue.data(null);
  }
}

// Provider for the LocationNotifier, allowing UI to interact with it.
final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationData?>>(
  (ref) => LocationNotifier(ref),
);

// 3. Provider for the WeatherService instance.
final weatherServiceProvider =
    Provider<WeatherService>((ref) => WeatherService());

// 4. A FutureProvider that fetches weather data.
// It automatically "listens" to the locationProvider. If the location changes,
// this provider will automatically refetch the weather for the new location.
final weatherProvider = FutureProvider<Weather?>((ref) async {
  final locationState = ref.watch(locationProvider);
  final weatherService = ref.watch(weatherServiceProvider);

  // Get the location data if it's available.
  final locationData = locationState.asData?.value;

  if (locationData != null) {
    // If we have a location, fetch the weather for it.
    return weatherService.getCurrentWeather(
      locationData.position.latitude,
      locationData.position.longitude,
    );
  }
  // If there's no location yet, return null.
  return null;
});
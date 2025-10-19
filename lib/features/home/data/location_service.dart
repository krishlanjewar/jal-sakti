import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// A reusable service for handling all location-based operations.
class LocationService {
  /// Determines the current position of the device.
  ///
  /// This method handles requesting permissions and fetching the device's
  /// high-accuracy GPS coordinates.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Gets the placemark (which includes city, country, etc.) from a given position.
  Future<Placemark> getPlacemarkFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks[0];
      } else {
        throw Exception("No placemarks found for the given coordinates.");
      }
    } catch (e) {
      print("Error in getPlacemarkFromPosition: $e");
      throw Exception("Failed to get placemark from coordinates.");
    }
  }
}

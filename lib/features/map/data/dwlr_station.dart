import 'package:google_maps_flutter/google_maps_flutter.dart';

// Enum to represent the water level status for clear, readable code.
enum WaterLevelStatus { low, normal, high }

class DwlrStation {
  final String id;
  final String name;
  final String state;
  final String district;
  final LatLng position;
  final double waterLevel;
  final double pH;
  final double temperature;
  final String waterQualityNotes;
  final WaterLevelStatus status;

  DwlrStation({
    required this.id,
    required this.name,
    required this.state,
    required this.district,
    required this.position,
    required this.waterLevel,
    required this.pH,
    required this.temperature,
    required this.waterQualityNotes,
  }) : status = _getStatusFromWaterLevel(waterLevel);
  
  // A factory constructor to create a DwlrStation from a CSV row (represented as a List of dynamic values).
  factory DwlrStation.fromCsv(List<dynamic> csvRow) {
    return DwlrStation(
      id: csvRow[0].toString(),
      name: csvRow[1].toString(),
      state: csvRow[2].toString(),
      district: csvRow[3].toString(),
      position: LatLng(
        double.tryParse(csvRow[4].toString()) ?? 0.0,
        double.tryParse(csvRow[5].toString()) ?? 0.0,
      ),
      waterLevel: double.tryParse(csvRow[7].toString()) ?? 0.0,
      pH: double.tryParse(csvRow[9].toString()) ?? 0.0,
      temperature: double.tryParse(csvRow[13].toString()) ?? 0.0,
      waterQualityNotes: csvRow[14].toString(),
    );
  }


  // Helper function to determine the status based on the water level.
  // These thresholds can be adjusted based on domain knowledge.
  static WaterLevelStatus _getStatusFromWaterLevel(double level) {
    if (level < 15) {
      return WaterLevelStatus.low;
    } else if (level <= 40) {
      return WaterLevelStatus.normal;
    } else {
      return WaterLevelStatus.high;
    }
  }

  // Helper property for easier searching.
  String get fullLocation => '$name, $district, $state';
}


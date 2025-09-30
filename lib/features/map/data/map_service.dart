import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:jal_shakti_app/features/map/data/dwlr_station.dart';

class MapService {
  // This function now loads and parses the real CSV data from the assets folder.
  Future<List<DwlrStation>> getDwlrStations() async {
    try {
      // Load the CSV file as a string from the assets directory.
      final rawData = await rootBundle.loadString("assets/dwlr_india_synthetic_1000.csv");
      
      // Use the csv package to convert the string into a list of lists.
      const csvConverter = CsvToListConverter();
      final List<List<dynamic>> csvTable = csvConverter.convert(rawData);

      // Skip the header row and convert each subsequent row into a DwlrStation object
      // using the factory constructor from your model.
      final List<DwlrStation> stations = csvTable
          .skip(1) // Skip the header row of the CSV
          .map((row) => DwlrStation.fromCsv(row))
          .toList();

      return stations;
    } catch (e) {
      // If anything goes wrong during file loading or parsing, print an error
      // and return an empty list to prevent the app from crashing.
      print("Error loading or parsing CSV data: $e");
      return [];
    }
  }
}
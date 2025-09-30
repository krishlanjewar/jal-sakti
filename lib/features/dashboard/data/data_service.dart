import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

/// A data model class that holds the aggregated monthly averages for all metrics.
class MonthlyDataPoint {
  final int month;
  final double avgWaterLevel;
  final double avgTemperature;
  final double avgRainfall;
  final double avgPh;
  final double avgDissolvedOxygen;

  MonthlyDataPoint({
    required this.month,
    required this.avgWaterLevel,
    required this.avgTemperature,
    required this.avgRainfall,
    required this.avgPh,
    required this.avgDissolvedOxygen,
  });
}


/// A service class responsible for fetching and processing the CSV data.
class DataService {
  
  /// Loads the CSV from assets, parses it, and calculates the monthly averages.
  Future<List<MonthlyDataPoint>> getMonthlyAverages() async {
    // 1. Load the raw CSV string from the assets folder
    final rawData = await rootBundle.loadString("assets/dwlr_dataset_2023.csv");
    
    // 2. Parse the CSV string into a list of lists (rows and columns)
    // We skip the header row (skip(1))
    final List<List<dynamic>> listData = const CsvToListConverter().convert(rawData).skip(1).toList();

    // 3. Group all the daily data entries by month
    final Map<int, List<List<dynamic>>> monthlyGroupedData = {};
    for (var row in listData) {
      try {
        final DateTime date = DateTime.parse(row[0].toString());
        final int month = date.month;

        if (!monthlyGroupedData.containsKey(month)) {
          monthlyGroupedData[month] = [];
        }
        monthlyGroupedData[month]!.add(row);
      } catch (e) {
        // Skip rows with invalid date formats
        print("Skipping row with invalid date: $row");
      }
    }

    // 4. Calculate the average for each metric for each month
    final List<MonthlyDataPoint> monthlyAverages = [];
    for (int month in monthlyGroupedData.keys.toList()..sort()) {
      final List<List<dynamic>> monthData = monthlyGroupedData[month]!;
      
      // Calculate the average for each column (metric)
      final double avgWaterLevel = _calculateAverage(monthData, 1);
      final double avgTemperature = _calculateAverage(monthData, 2);
      final double avgRainfall = _calculateAverage(monthData, 3);
      final double avgPh = _calculateAverage(monthData, 4);
      final double avgDissolvedOxygen = _calculateAverage(monthData, 5);

      monthlyAverages.add(
        MonthlyDataPoint(
          month: month,
          avgWaterLevel: avgWaterLevel,
          avgTemperature: avgTemperature,
          avgRainfall: avgRainfall,
          avgPh: avgPh,
          avgDissolvedOxygen: avgDissolvedOxygen,
        ),
      );
    }
    
    return monthlyAverages;
  }

  /// Helper function to calculate the average of a specific column.
  double _calculateAverage(List<List<dynamic>> data, int columnIndex) {
    double total = 0;
    int count = 0;
    for (var row in data) {
      // Ensure the value is a number before adding it
      if (row[columnIndex] is num) {
        total += row[columnIndex];
        count++;
      }
    }
    return count > 0 ? total / count : 0.0;
  }
}

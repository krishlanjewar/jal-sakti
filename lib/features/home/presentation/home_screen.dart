
import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:jal_shakti_app/features/dashboard/data/data_service.dart';
import 'package:jal_shakti_app/features/home/data/weather_service.dart';
import 'package:jal_shakti_app/shared/widgets/reusable_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';

// Reminder: Add the http package to your pubspec.yaml for the WeatherService to work:
// dependencies:
//   http: ^1.2.1

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MonthlyDataPoint>> _dataFuture;
  final DataService _dataService = DataService();
  final WeatherService _weatherService = WeatherService();

  // State variables for the location section
  String _locationMessage = 'No location selected';
  bool _isFetchingLocation = false;

  // State variables for real-time temperature
  Weather? _currentWeather;
  bool _isFetchingTemp = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _dataService.getMonthlyAverages();
    _fetchCurrentWeather();
  }

  /// Fetches the current temperature for Nagpur using the WeatherService.
  Future<void> _fetchCurrentWeather() async {
    if (mounted) setState(() => _isFetchingTemp = true);
    try {
      final weather = await _weatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _currentWeather = weather;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentWeather = null; // Set to null on error
        });
      }
      // Optionally show an error message to the user
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not fetch live weather.')));
    } finally {
      if (mounted) setState(() => _isFetchingTemp = false);
    }
  }

  // Handles logic for fetching the user's current GPS location.
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationMessage = 'Location services are disabled.');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable location services.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationMessage = 'Location permissions denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationMessage = 'Permissions permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationMessage = 'Current Lat/Lon: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() => _locationMessage = 'Failed to get location.');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  /// Shows a dialog for the user to manually enter and "search" for a location.
  Future<void> _showManualLocationEntryDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Location Manually'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "E.g., Mumbai, India"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _locationMessage = 'Selected: ${controller.text}';
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MonthlyDataPoint>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        // Show a loading indicator while data is being fetched.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // If data fails to load, show a fallback view with general info.
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildStaticContent();
        }

        final data = snapshot.data!;
        final latestMonthData = data.last;

        // Main UI when data is successfully loaded.
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildQuickAccessGrid(context, latestMonthData),
                const SizedBox(height: 24),
                _buildLocationSection(context),
                const SizedBox(height: 24),
                _buildDwlrInfoSection(context, data),
                const SizedBox(height: 24),
                _buildPredictionSection(context),
                const SizedBox(height: 24),
                _buildGuidelinesSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI BUILDER WIDGETS FOR EACH SECTION ---

  /// --- NEW WIDGET: Header with Greeting and Date ---
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good Morning", // Based on the provided time of 12:32 AM
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            ),
        ),
        const SizedBox(height: 4),
        Text(
          "Wednesday, September 24", // Based on the provided date
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.pin_drop_outlined, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              "Nagpur, Maharashtra", // Based on the provided location
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, MonthlyDataPoint latestData) {
    String phStatus = latestData.avgPh >= 6.5 && latestData.avgPh <= 8.5 ? 'Safe' : 'Unsafe';
    Color phColor = phStatus == 'Safe' ? AppTheme.primaryGreen : AppTheme.accentOrange;
    String qualityStatus = latestData.avgDissolvedOxygen > 6 ? 'Good' : 'Poor';
    Color qualityColor = qualityStatus == 'Good' ? AppTheme.primaryGreen : AppTheme.accentOrange;

    final String tempDisplay = _isFetchingTemp
        ? '...'
        : (_currentWeather != null && _currentWeather!.weatherCode != 0
            ? '${_currentWeather!.temperature.toStringAsFixed(1)}°C'
            : 'N/A');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildInfoCard(context, icon: Icons.water, title: 'Groundwater Level', value: '${latestData.avgWaterLevel.toStringAsFixed(1)}m', color: AppTheme.primaryBlue),
        _buildInfoCard(context, icon: Icons.thermostat, title: 'Nagpur Temp.', value: tempDisplay, color: AppTheme.accentOrange),
        _buildInfoCard(context, icon: Icons.science_outlined, title: 'pH Value', value: '${latestData.avgPh.toStringAsFixed(1)} ($phStatus)', color: phColor),
        _buildInfoCard(context, icon: Icons.check_circle_outline, title: 'Water Quality', value: qualityStatus, color: qualityColor),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String value, required Color color}) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 8),
                Text("Location", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(_locationMessage, style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_location_alt),
                  label: const Text('Manual Entry'),
                  onPressed: _showManualLocationEntryDialog,
                ),
                TextButton.icon(
                  icon: _isFetchingLocation ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
                  label: const Text('Fetch Current'),
                  onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDwlrInfoSection(BuildContext context, List<MonthlyDataPoint> data) {
    final trendChange = data.last.avgWaterLevel - data.first.avgWaterLevel;
    final isIncreasing = trendChange >= 0;

    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DWLR Well Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Aggregated Data - 2023', style: Theme.of(context).textTheme.bodySmall),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(isIncreasing ? Icons.trending_up : Icons.trending_down, color: isIncreasing ? AppTheme.primaryGreen : AppTheme.alertRed),
              title: const Text('Annual Trend'),
              trailing: Text(
                '${trendChange.toStringAsFixed(1)}m',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isIncreasing ? AppTheme.primaryGreen : AppTheme.alertRed, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150, // Increased height to accommodate axis labels
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  // --- ADDED: Axis Titles and Labels ---
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: _bottomTitleWidgets,
                      ),
                      axisNameWidget: const Text("Month (2023)", style: TextStyle(fontSize: 12)),
                      axisNameSize: 22,
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: _leftTitleWidgets,
                        interval: 5, // Adjust interval for clarity
                      ),
                      axisNameWidget: const Text("Level (m)", style: TextStyle(fontSize: 12)),
                      axisNameSize: 22,
                    ),
                  ),
                  // --- End of new titles data ---
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.map((d) => FlSpot(d.month.toDouble(), d.avgWaterLevel)).toList(),
                      isCurved: true,
                      color: AppTheme.primaryBlue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppTheme.primaryBlue.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for bottom (X-axis) titles
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey);
    String text;
    switch (value.toInt()) {
      case 1: text = 'JAN'; break;
      case 3: text = 'MAR'; break;
      case 5: text = 'MAY'; break;
      case 7: text = 'JUL'; break;
      case 9: text = 'SEP'; break;
      case 11: text = 'NOV'; break;
      default: return Container(); // Show only odd months to prevent clutter
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(text, style: style));
  }

  // Helper widget for left (Y-axis) titles
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey);
    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }


  Widget _buildPredictionSection(BuildContext context) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Land Suitability Prediction', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(color: AppTheme.primaryGreen, value: 45, title: '45%', radius: 40, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: AppTheme.primaryBlue, value: 35, title: '35%', radius: 40, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: AppTheme.accentOrange, value: 20, title: '20%', radius: 40, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // This is the indicator/legend section
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: AppTheme.primaryGreen, text: 'Agriculture'),
                    SizedBox(height: 8),
                    _LegendItem(color: AppTheme.primaryBlue, text: 'Habitat'),
                    SizedBox(height: 8),
                    _LegendItem(color: AppTheme.accentOrange, text: 'Industrial'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesSection(BuildContext context) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guidelines & Schemes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.eco, color: AppTheme.primaryGreen),
              title: const Text('Conservation Tips'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.article, color: AppTheme.primaryGreen),
              title: const Text('Ministry of Jal Shakti Schemes'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Fallback view if data loading fails
  Widget _buildStaticContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Could not load live data. Displaying general ministry information and schemes.', textAlign: TextAlign.center))),
            const SizedBox(height: 24),
            _buildPredictionSection(context),
            const SizedBox(height: 24),
            _buildGuidelinesSection(context),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the Pie Chart legend
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}


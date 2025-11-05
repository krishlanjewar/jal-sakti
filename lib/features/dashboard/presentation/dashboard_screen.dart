import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jal_shakti_app/features/dashboard/data/data_service.dart';
import 'dart:math';
import 'package:jal_shakti_app/features/home/presentation/home_providers.dart';
import 'package:jal_shakti_app/features/reports/presentation/reports_screen.dart';
import 'package:jal_shakti_app/shared/widgets/reusable_card.dart';

// The DashboardScreen is now a ConsumerWidget to interact with Riverpod providers.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This data could also be moved to a Riverpod provider in the future.
    final Future<List<MonthlyDataPoint>> monthlyDataFuture =
        DataService().getMonthlyAverages();

    return FutureBuilder<List<MonthlyDataPoint>>(
      future: monthlyDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Failed to load dashboard data.\nError: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        }

        final data = snapshot.data!;
        final latestData = data.last;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Location Fetching Section ---
                _buildLocationSection(context, ref),
                const SizedBox(height: 16),
                _buildQuickStatsGrid(context, latestData),
                const SizedBox(height: 16),
                _buildGraphsAndTrends(context, data),
                const SizedBox(height: 16),
                _buildRainfallChartCard(
                    context, data),
                const SizedBox(height: 16),
                _buildInsightsSection(context, data),
                // The shortcut buttons row has been removed from the end of this list.
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Location Display and Fetching Card ---
  Widget _buildLocationSection(BuildContext context, WidgetRef ref) {
    // Watch the shared location provider from the home feature
    final locationState = ref.watch(locationProvider);

    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 8),
                Text("Location-Based Data",
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            // Dynamically show location status using the provider's state
            locationState.when(
              data: (locationData) => Text(
                locationData != null
                    ? 'Displaying stats for: ${locationData.displayCity}, ${locationData.displayState}'
                    : 'No location set. Data shown is based on national averages.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              loading: () => const Row(children: [
                SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text("Fetching location...")
              ]),
              error: (e, s) => Text('Could not fetch location: ${e.toString()}',
                  style: const TextStyle(color: Colors.red)),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_location_alt),
                  label: const Text('Set Manually'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Manual location entry is a planned feature.')),
                    );
                  },
                ),
                TextButton.icon(
                  icon: locationState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                  label: const Text('Fetch Current'),
                  onPressed: locationState.isLoading
                      ? null
                      : () =>
                          ref.read(locationProvider.notifier).fetchLocation(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Section 1: Quick Stats Grid
  Widget _buildQuickStatsGrid(
      BuildContext context, MonthlyDataPoint latestData) {
    String phStatus =
        latestData.avgPh >= 6.5 && latestData.avgPh <= 8.5 ? 'Safe' : 'Unsafe';
    Color phColor =
        phStatus == 'Safe' ? AppTheme.primaryGreen : AppTheme.accentOrange;
    String qualityStatus = latestData.avgDissolvedOxygen > 6 ? 'Good' : 'Poor';
    Color qualityColor =
        qualityStatus == 'Good' ? AppTheme.primaryGreen : AppTheme.accentOrange;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(
            context,
            'Groundwater Level',
            '${latestData.avgWaterLevel.toStringAsFixed(1)}m',
            0.6,
            AppTheme.primaryBlue,
            Icons.water),
        _buildStatCard(
            context,
            'Temperature',
            '${latestData.avgTemperature.toStringAsFixed(1)}°C',
            0.7,
            AppTheme.accentOrange,
            Icons.thermostat),
        _buildStatCard(
            context,
            'pH Value',
            '${latestData.avgPh.toStringAsFixed(1)} ($phStatus)',
            latestData.avgPh / 14.0,
            phColor,
            Icons.science),
        _buildStatCard(
            context,
            'Water Quality',
            qualityStatus,
            latestData.avgDissolvedOxygen / 10.0,
            qualityColor,
            Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      double percent, Color color, IconData icon) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  backgroundColor: color.withOpacity(0.2),
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Section 2: Graphs and Trends
  Widget _buildGraphsAndTrends(
      BuildContext context, List<MonthlyDataPoint> data) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historical Trends (2023 Monthly Avg)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(_buildMultiLineChartData(data)),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
            const Divider(height: 40),
            Text('Land Suitability',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(_buildPieChartData()),
            ),
          ],
        ),
      ),
    );
  }

  // --- Rainfall Chart Section ---
  Widget _buildRainfallChartCard(
      BuildContext context, List<MonthlyDataPoint> data) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Rainfall (mm)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(_buildBarChartData(data)),
            ),
          ],
        ),
      ),
    );
  }

  // Section 3: Insights (with clickable items)
  Widget _buildInsightsSection(
      BuildContext context, List<MonthlyDataPoint> data) {
    final firstMonthLevel = data.first.avgWaterLevel;
    final lastMonthLevel = data.last.avgWaterLevel;
    final change = lastMonthLevel - firstMonthLevel;
    final percentChange = (change / firstMonthLevel) * 100;
    final insightText = percentChange >= 0
        ? 'Groundwater increased ${percentChange.toStringAsFixed(1)}% through 2023.'
        : 'Groundwater dropped ${(-percentChange).toStringAsFixed(1)}% through 2023.';
    final insightColor = percentChange >= 0 ? AppTheme.primaryGreen : Colors.red;
    final insightIcon =
        percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Insights', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildInsightTile(
              icon: insightIcon,
              text: insightText,
              color: insightColor,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Showing detailed trend analysis below.')),
                );
              }
            ),
            const Divider(),
            _buildInsightTile(
              icon: Icons.agriculture,
              text: 'Water is safe for agriculture, check report for details.',
              color: AppTheme.accentOrange,
              onTap: () {
                 Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReportsScreen(),
                  ));
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  // --- Legend Widget ---
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppTheme.primaryBlue, 'Water Level'),
        const SizedBox(width: 16),
        _buildLegendItem(AppTheme.accentOrange, 'Temperature'),
        const SizedBox(width: 16),
        _buildLegendItem(AppTheme.primaryGreen, 'pH'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  // --- Chart Data Generators ---
  LineChartData _buildMultiLineChartData(List<MonthlyDataPoint> data) {
    final waterLevelSpots =
        data.map((d) => FlSpot(d.month.toDouble(), d.avgWaterLevel)).toList();
    final tempSpots =
        data.map((d) => FlSpot(d.month.toDouble(), d.avgTemperature)).toList();
    final phSpots = data.map((d) => FlSpot(d.month.toDouble(), d.avgPh)).toList();

    final allValues = [
      ...data.map((d) => d.avgWaterLevel),
      ...data.map((d) => d.avgTemperature),
      ...data.map((d) => d.avgPh),
    ];
    final minY = allValues.reduce(min);
    final maxY = allValues.reduce(max);

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                barSpot.y.toStringAsFixed(1),
                TextStyle(
                  color: Colors.blueGrey
                      .withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      minY: (minY - 5).floorToDouble(),
      maxY: (maxY + 5).ceilToDouble(),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: _bottomTitles)),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _createLineBarData(waterLevelSpots, AppTheme.primaryBlue),
        _createLineBarData(tempSpots, AppTheme.accentOrange),
        _createLineBarData(phSpots, AppTheme.primaryGreen),
      ],
    );
  }

  LineChartBarData _createLineBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  PieChartData _buildPieChartData() {
    return PieChartData(
      pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: [
        PieChartSectionData(
            color: AppTheme.primaryGreen,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
        PieChartSectionData(
            color: AppTheme.primaryBlue,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
        PieChartSectionData(
            color: AppTheme.accentOrange,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
      ],
    );
  }

  // --- Bar Chart Data Generator for Rainfall ---
  BarChartData _buildBarChartData(List<MonthlyDataPoint> data) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.round()} mm',
              const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: const FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: _bottomTitles)),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: data.map((d) {
        return BarChartGroupData(
          x: d.month,
          barRods: [
            BarChartRodData(
                toY: d.avgRainfall,
                color: AppTheme.secondaryBlue,
                width: 15,
                borderRadius: BorderRadius.circular(4))
          ],
        );
      }).toList(),
    );
  }
}

Widget _bottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.grey, fontSize: 10);
  String text;
  switch (value.toInt()) {
    case 1:
      text = 'J';
      break;
    case 2:
      text = 'F';
      break;
    case 3:
      text = 'M';
      break;
    case 4:
      text = 'A';
      break;
    case 5:
      text = 'M';
      break;
    case 6:
      text = 'J';
      break;
    case 7:
      text = 'J';
      break;
    case 8:
      text = 'A';
      break;
    case 9:
      text = 'S';
      break;
    case 10:
      text = 'O';
      break;
    case 11:
      text = 'N';
      break;
    case 12:
      text = 'D';
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
      axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
}


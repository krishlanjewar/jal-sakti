import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jal_shakti_app/features/dashboard/data/data_service.dart';
import 'dart:math';

import 'package:jal_shakti_app/shared/widgets/reusable_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<MonthlyDataPoint>> _monthlyData;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _monthlyData = _dataService.getMonthlyAverages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MonthlyDataPoint>>(
      future: _monthlyData,
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
                _buildQuickStatsGrid(context, latestData),
                const SizedBox(height: 16),
                _buildGraphsAndTrends(context, data),
                const SizedBox(height: 16),
                _buildRainfallChartCard(context, data), // <-- NEW RAINFALL CHART ADDED HERE
                const SizedBox(height: 16),
                _buildInsightsSection(context, data),
                const SizedBox(height: 24),
                _buildShortcutsSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section 1: Quick Stats Grid
  Widget _buildQuickStatsGrid(BuildContext context, MonthlyDataPoint latestData) {
    String phStatus = latestData.avgPh >= 6.5 && latestData.avgPh <= 8.5 ? 'Safe' : 'Unsafe';
    Color phColor = phStatus == 'Safe' ? AppTheme.primaryGreen : AppTheme.accentOrange;
    String qualityStatus = latestData.avgDissolvedOxygen > 6 ? 'Good' : 'Poor';
    Color qualityColor = qualityStatus == 'Good' ? AppTheme.primaryGreen : AppTheme.accentOrange;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildStatCard(context, 'Groundwater Level', '${latestData.avgWaterLevel.toStringAsFixed(1)}m', 0.6, AppTheme.primaryBlue, Icons.water),
        _buildStatCard(context, 'Temperature', '${latestData.avgTemperature.toStringAsFixed(1)}°C', 0.7, AppTheme.accentOrange, Icons.thermostat),
        _buildStatCard(context, 'pH Value', '${latestData.avgPh.toStringAsFixed(1)} ($phStatus)', latestData.avgPh / 14.0, phColor, Icons.science),
        _buildStatCard(context, 'Water Quality', qualityStatus, latestData.avgDissolvedOxygen / 10.0, qualityColor, Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, double percent, Color color, IconData icon) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
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
  Widget _buildGraphsAndTrends(BuildContext context, List<MonthlyDataPoint> data) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historical Trends (2023 Monthly Avg)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(_buildMultiLineChartData(data)),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
            const Divider(height: 40),
            Text('Land Suitability', style: Theme.of(context).textTheme.titleLarge),
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
  
  // --- NEW: Rainfall Chart Section ---
  Widget _buildRainfallChartCard(BuildContext context, List<MonthlyDataPoint> data) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Rainfall (mm)', style: Theme.of(context).textTheme.titleLarge),
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


  // Section 3: Insights
  Widget _buildInsightsSection(BuildContext context, List<MonthlyDataPoint> data) {
    final firstMonthLevel = data.first.avgWaterLevel;
    final lastMonthLevel = data.last.avgWaterLevel;
    final change = lastMonthLevel - firstMonthLevel;
    final percentChange = (change / firstMonthLevel) * 100;
    final insightText = percentChange >= 0
        ? 'Groundwater increased ${percentChange.toStringAsFixed(1)}% through 2023.'
        : 'Groundwater dropped ${(-percentChange).toStringAsFixed(1)}% through 2023.';
    final insightColor = percentChange >= 0 ? AppTheme.primaryGreen : Colors.red;
    final insightIcon = percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Key Insights', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildInsightTile(insightIcon, insightText, insightColor),
            const Divider(),
            _buildInsightTile(Icons.agriculture, 'Water is safe for agriculture, unsafe for drinking.', AppTheme.accentOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(IconData icon, String text, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
    );
  }

  // Section 4: Shortcuts
  Widget _buildShortcutsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShortcutButton(context, Icons.location_pin, 'Location'),
        _buildShortcutButton(context, Icons.map, 'Map'),
        _buildShortcutButton(context, Icons.article, 'Reports'),
        _buildShortcutButton(context, Icons.support_agent, 'Contact'),
      ],
    );
  }

  Widget _buildShortcutButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall)
      ],
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
    final waterLevelSpots = data.map((d) => FlSpot(d.month.toDouble(), d.avgWaterLevel)).toList();
    final tempSpots = data.map((d) => FlSpot(d.month.toDouble(), d.avgTemperature)).toList();
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
        '${barSpot.y.toStringAsFixed(1)}',
        TextStyle(
          color: Colors.blueGrey.withOpacity(0.8), // Color set here
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
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: _bottomTitles)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
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
        PieChartSectionData(color: AppTheme.primaryGreen, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
        PieChartSectionData(color: AppTheme.primaryBlue, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
        PieChartSectionData(color: AppTheme.accentOrange, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
      ],
    );
  }

  // --- NEW: Bar Chart Data Generator for Rainfall ---
  BarChartData _buildBarChartData(List<MonthlyDataPoint> data) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
  touchTooltipData: BarTouchTooltipData(
    getTooltipItem: (group, groupIndex, rod, rodIndex) {
      return BarTooltipItem(
        '${rod.toY.round()} mm',
        TextStyle(
          color: Colors.blueGrey, // Set color here instead of tooltipColor
          fontWeight: FontWeight.bold,
        ),
      );
    },
  ),
),

      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: _bottomTitles)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              borderRadius: BorderRadius.circular(4)
            )
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
    case 1: text = 'J'; break;
    case 2: text = 'F'; break;
    case 3: text = 'M'; break;
    case 4: text = 'A'; break;
    case 5: text = 'M'; break;
    case 6: text = 'J'; break;
    case 7: text = 'J'; break;
    case 8: text = 'A'; break;
    case 9: text = 'S'; break;
    case 10: text = 'O'; break;
    case 11: text = 'N'; break;
    case 12: text = 'D'; break;
    default: text = ''; break;
  }
  return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
}

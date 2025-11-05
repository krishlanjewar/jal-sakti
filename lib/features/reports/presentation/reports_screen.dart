import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:jal_shakti_app/features/dashboard/data/data_service.dart';
import 'package:jal_shakti_app/shared/widgets/reusable_card.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'dart:math';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DataService _dataService = DataService();
  late Future<List<MonthlyDataPoint>> _reportData;

  @override
  void initState() {
    super.initState();
    _reportData = _dataService.getMonthlyAverages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Report'),
      ),
      body: FutureBuilder<List<MonthlyDataPoint>>(
        future: _reportData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Could not generate report. Data is unavailable.'));
          }

          final data = snapshot.data!;
          // Perform analysis on the data
          final analysis = _analyzeData(data);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildReportHeader(context),
              const SizedBox(height: 24),
              _buildSectionCard(
                context,
                icon: Icons.insights,
                title: 'Key Findings',
                child: _buildKeyFindings(context, analysis),
              ),
              _buildSectionCard(
                context,
                icon: Icons.analytics,
                title: 'Detailed Analysis: Monthly Trends',
                child: _buildDetailedAnalysisChart(data),
              ),
               _buildSectionCard(
                context,
                icon: Icons.rule,
                title: 'Recommendations',
                child: _buildRecommendations(context),
              ),
              const SizedBox(height: 16),
              _buildDownloadButton(context),
            ],
          );
        },
      ),
    );
  }

  // --- ANALYSIS LOGIC ---
  Map<String, String> _analyzeData(List<MonthlyDataPoint> data) {
    final overallAverage = data.map((d) => d.avgWaterLevel).reduce((a, b) => a + b) / data.length;
    final peakMonthData = data.reduce((curr, next) => curr.avgWaterLevel > next.avgWaterLevel ? curr : next);
    final lowMonthData = data.reduce((curr, next) => curr.avgWaterLevel < next.avgWaterLevel ? curr : next);
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return {
      'average': '${overallAverage.toStringAsFixed(1)}m',
      'peakMonth': '${monthNames[peakMonthData.month - 1]} (${peakMonthData.avgWaterLevel.toStringAsFixed(1)}m)',
      'lowMonth': '${monthNames[lowMonthData.month - 1]} (${lowMonthData.avgWaterLevel.toStringAsFixed(1)}m)',
    };
  }


  // --- UI BUILDER WIDGETS ---

  Widget _buildReportHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Groundwater Analysis Report',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Chip(
          label: Text('Date Range: Jan 2023 - Dec 2023'),
          avatar: Icon(Icons.calendar_today, size: 16),
          backgroundColor: AppTheme.lightGray,
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildKeyFindings(BuildContext context, Map<String, String> analysis) {
    return Column(
      children: [
        _buildFindingRow('Annual Average Water Level:', analysis['average']!),
        _buildFindingRow('Highest Water Level Month:', analysis['peakMonth']!),
        _buildFindingRow('Lowest Water Level Month:', analysis['lowMonth']!),
      ],
    );
  }

  Widget _buildFindingRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }
  
  Widget _buildDetailedAnalysisChart(List<MonthlyDataPoint> data) {
     return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: _bottomTitles)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.map((d) => FlSpot(d.month.toDouble(), d.avgWaterLevel)).toList(),
              isCurved: true,
              color: AppTheme.primaryBlue,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue.withOpacity(0.3), AppTheme.primaryBlue.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return const Column(
      children: [
        _RecommendationItem(text: 'Increase monitoring in low-level areas during peak summer months.'),
        _RecommendationItem(text: 'Promote rainwater harvesting initiatives to augment recharge during monsoon season.'),
        _RecommendationItem(text: 'Conduct targeted awareness campaigns in districts showing consistent decline.'),
      ],
    );
  }
  
  Widget _buildDownloadButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Download Report (PDF/CSV)'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppTheme.primaryGreen,
      ),
      onPressed: () {
        // Placeholder action
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download functionality is a planned future feature.')),
        );
      },
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;
  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

// Helper for chart bottom titles
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
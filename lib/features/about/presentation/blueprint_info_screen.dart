import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';

class BlueprintInfoScreen extends StatelessWidget {
  const BlueprintInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategic Blueprint'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTitleAndContext(context),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Objective & Strategic Imperative',
            content:
                "India's socio-economic fabric is inextricably linked to groundwater, which underpins over 60% of irrigated agriculture and 85% of rural drinking water supplies. The nation faces a severe crisis of over-extraction, with declining water tables threatening agricultural sustainability, environmental stability, and long-term water security. This blueprint outlines a system designed to shift national groundwater governance from a reactive, historical assessment model to a proactive, real-time, data-driven framework.",
          ),
          const Divider(height: 32),
          _buildSection(
            context,
            title: 'Key Components',
            contentWidget: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubSection(
                  title: 'Strategic Imperative',
                  points: [
                    'Acknowledge India\'s profound dependency on groundwater for food and water security.',
                    'Address the widespread crisis of over-extraction and deteriorating water quality.',
                    'Leverage real-time intelligence to enable proactive and evidence-based decision-making.'
                  ],
                ),
                _SubSection(
                  title: 'Policy Alignment',
                  points: [
                    'Directly supports the Atal Bhujal Yojana by providing real-time data for Gram Panchayat Water Security Plans.',
                    'Aligns with the National Water Mission\'s goal of ensuring integrated water resource management.',
                    'Provides a foundational data layer for numerous national and state-level water conservation initiatives.'
                  ],
                ),
                _SubSection(
                  title: 'Technical Foundation',
                  points: [
                    'Utilizes the national network of ~80,000 Digital Water Level Recorders (DWLRs) as the core data source.',
                    'Highlights the critical need for a standardized, real-time "India Groundwater API" to ensure data accessibility.',
                  ],
                ),
                _SubSection(
                  title: 'Scientific Methodology',
                  points: [
                    'Employs the Water-Table Fluctuation (WTF) method as the core analytical engine for recharge estimation.',
                    'Implements a tiered approach (Tier-I, II, III) for progressively accurate estimations, from regional to local scales.',
                  ],
                ),
                 _SubSection(
                  title: 'System Architecture',
                  points: [
                    'Proposes a Kappa Architecture backend for robust, scalable real-time and batch data processing.',
                    'Recommends a cross-platform mobile frontend (Flutter) with an advanced geospatial SDK (Google Maps) for visualization.',
                  ],
                ),
                 _SubSection(
                  title: 'User-Centric Design',
                  points: [
                    'Defines key user personas: Field Hydrogeologists, State-Level Planners, and National Policymakers.',
                    'Focuses on intuitive UI/UX with multi-layered geospatial visualizations and customizable dashboards.',
                  ],
                ),
                 _SubSection(
                  title: 'Implementation & Risks',
                  points: [
                    'Outlines a phased implementation roadmap: Pilot -> State-Level Rollout -> National Integration.',
                    'Identifies key risks such as data quality, API availability, and user adoption, with defined mitigation strategies.',
                  ],
                ),
              ],
            )
          ),
           const Divider(height: 32),
           _buildSection(
            context,
            title: 'Strategic Recommendations',
            contentWidget: const Column(
              children: [
                _BulletPoint(text: 'Formal integration with the Atal Bhujal Yojana to serve as its primary mobile data interface.'),
                _BulletPoint(text: 'Prioritize the monitoring and integration of groundwater extraction data to "close the water budget loop."'),
                _BulletPoint(text: 'Establish the "India Groundwater API" as a national digital public good to foster an ecosystem of innovation.'),
              ],
            )
           ),
           const Divider(height: 32),
            _buildSection(
            context,
            title: 'Vision & Conclusion',
            content:
                "This blueprint envisions a future where India's groundwater resources are managed not through periodic, historical reports, but through a live, dynamic, and intelligent system. By providing actionable intelligence directly to stakeholders at all levels, this application has the potential to transform national groundwater management into a proactive, evidence-based paradigm, securing India's water future and fostering a new era of hydroinformatics innovation.",
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndContext(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.assessment, size: 40, color: AppTheme.primaryBlue),
        const SizedBox(height: 8),
        Text(
          'Groundwater Resource Evaluation Blueprint',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'A Strategic & Technical Framework for a Real-Time Application',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, String? content, Widget? contentWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 8),
        if (content != null)
           Text(
            content,
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        if (contentWidget != null)
          contentWidget,
      ],
    );
  }
}

// Helper widget for sub-sections
class _SubSection extends StatelessWidget {
  final String title;
  final List<String> points;
  const _SubSection({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...points.map((point) => _BulletPoint(text: point)),
        ],
      ),
    );
  }
}


// Helper widget for consistent bullet point styling
class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

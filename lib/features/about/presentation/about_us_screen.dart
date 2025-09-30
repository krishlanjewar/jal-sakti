import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
// import 'package:jal_shakti_app/features/about/presentation/blueprint_info_screen.dart';
import 'package:jal_shakti_app/features/about/presentation/contact_us_screen.dart';
import 'package:jal_shakti_app/shared/widgets/reusable_card.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Double-check that your image filenames match this list exactly.
  final List<String> _imagePaths = [
    'assets/images/event_launch.png',
    'assets/images/water_conservation.png',
    'assets/images/awareness_drive.png',
    'assets/images/tech_monitoring.png',
    'assets/images/community_participation.png',
    'assets/images/before_after.png',
    'assets/images/workshop.png',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll the carousel every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _currentPage = (_currentPage + 1) % _imagePaths.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildImageCarousel(),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'About The Jal Shakti App',
            content: 'The Jal Shakti App is an initiative under the Ministry of Jal Shakti, Government of India, designed to empower citizens with real-time groundwater and water resource information. Built on data from the Central Ground Water Board (CGWB), the app provides easy access to groundwater levels, water quality, and conservation resources — helping individuals, communities, and policymakers make informed decisions.',
          ),
          _buildSection(
            context,
            title: 'Our Mission',
            contentWidget: const Column(
              children: [
                _InfoItem(icon: Icons.water_drop_outlined, text: 'Ensure sustainable use and management of India’s groundwater.'),
                _InfoItem(icon: Icons.verified_user, text: 'Provide transparent, reliable, and accessible data to every citizen.'),
                _InfoItem(icon: Icons.group_work, text: 'Encourage awareness and participation in water conservation efforts.'),
              ],
            ),
          ),
          _buildSection(
            context,
            title: 'What We Offer',
            contentWidget: const Column(
              children: [
                _InfoItem(icon: Icons.bar_chart, text: 'Live Groundwater Monitoring – Levels, trends, and water quality indicators.'),
                _InfoItem(icon: Icons.map_outlined, text: 'DWLR Maps & Reports – Access detailed aquifer and monitoring station data.'),
                _InfoItem(icon: Icons.eco, text: 'Conservation Guidance – Tips on rainwater harvesting, recharge methods, and sustainable practices.'),
                _InfoItem(icon: Icons.article_outlined, text: 'Government Schemes & Guidelines – Information on Jal Shakti Abhiyan, Atal Bhujal Yojana, and more.'),
              ],
            ),
          ),
          const Divider(height: 32),
          // Card(
          //   elevation: 2,
          //   child: ListTile(
          //     leading: const Icon(Icons.assessment, color: AppTheme.primaryBlue),
          //     title: const Text('View Strategic Blueprint'),
          //     subtitle: const Text('Read the technical framework for this application.'),
          //     trailing: const Icon(Icons.arrow_forward_ios),
          //     onTap: () {
          //       Navigator.of(context).push(MaterialPageRoute(
          //         builder: (_) => const BlueprintInfoScreen(),
          //       ));
          //     },
          //   ),
          // ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.contact_mail, color: AppTheme.primaryGreen),
              title: const Text('Contact Information'),
              subtitle: const Text('View address, helpline, and contact details.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ContactUsScreen(),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ReusableCard(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _imagePaths[index],
                    fit: BoxFit.cover,
                    // --- NEW: Improved Error Widget ---
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.red.shade100,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Failed to load image:\n${_imagePaths[index]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
            // Page indicator dots
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imagePaths.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppTheme.primaryBlue : Colors.white70,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ReusableCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.water_drop, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Our Vision',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '“To secure every drop of water today, for the prosperity of tomorrow.”',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, String? content, Widget? contentWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          if (contentWidget != null)
            contentWidget,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
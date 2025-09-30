import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final LatLng _headquartersLocation = const LatLng(28.6234, 77.2114); // Approx. LatLng for Shram Shakti Bhawan

  // Helper function to launch URLs (for phone, email, etc.)
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMapSection(),
          const SizedBox(height: 24),
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          _buildContactTile(
            context,
            icon: Icons.location_on,
            title: 'Headquarters',
            subtitle: 'Shram Shakti Bhawan, Rafi Marg, New Delhi, Delhi 110001',
            onTap: () => _launchUrl(Uri.parse('https://maps.google.com/?q=28.6234,77.2114')),
          ),
          _buildContactTile(
            context,
            icon: Icons.phone,
            title: 'Helpline',
            subtitle: '1800-11-2047',
            onTap: () => _launchUrl(Uri.parse('tel:1800112047')),
          ),
          _buildContactTile(
            context,
            icon: Icons.email,
            title: 'Email Us',
            subtitle: 'contact@jalshakti.gov.in',
            onTap: () => _launchUrl(Uri.parse('mailto:contact@jalshakti.gov.in')),
          ),
           _buildContactTile(
            context,
            icon: Icons.public,
            title: 'Official Website',
            subtitle: 'jalshakti-dowr.gov.in',
            onTap: () => _launchUrl(Uri.parse('http://jalshakti-dowr.gov.in/')),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures the map respects the card's rounded corners
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _headquartersLocation,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('headquarters'),
              position: _headquartersLocation,
              infoWindow: const InfoWindow(title: 'Ministry of Jal Shakti HQ'),
            )
          },
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
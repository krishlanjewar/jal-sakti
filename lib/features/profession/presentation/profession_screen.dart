

import 'package:flutter/material.dart';
import 'package:jal_shakti_app/core/theme/app_theme.dart';

// Enum to define the user roles for better type safety and readability.
enum UserRole {
  policyMaker,
  researcher,
  farmer,
  citizen,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.policyMaker:
        return 'Policy Maker';
      case UserRole.researcher:
        return 'Researcher';
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.citizen:
        return 'Citizen';
    }
  }
}

class ProfessionScreen extends StatefulWidget {
  const ProfessionScreen({super.key});

  @override
  State<ProfessionScreen> createState() =>
      _ProfessionScreen();
}

class _ProfessionScreen
    extends State<ProfessionScreen> {
  UserRole? _selectedRole;

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _resetRole() {
    setState(() {
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedRole == null
            ? 'Select Your Role'
            : '${_selectedRole!.displayName} View'),
        backgroundColor: AppTheme.primaryBlue,
        actions: [
          if (_selectedRole != null)
            IconButton(
              icon: const Icon(Icons.change_circle_outlined),
              onPressed: _resetRole,
              tooltip: 'Change Role',
            ),
        ],
      ),
      body: _selectedRole == null
          ? _buildRoleSelection()
          : _buildContentDisplay(),
    );
  }

  Widget _buildRoleSelection() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_outlined, size: 80, color: AppTheme.primaryBlue),
            const SizedBox(height: 20),
            Text(
              'Welcome to the ProFractional Context Page',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please select your role to access tailored tools and information for water sustainability.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                _buildRoleCard(
                    context,
                    UserRole.policyMaker,
                    Icons.gavel_rounded,
                    Colors.blue.shade700),
                _buildRoleCard(
                    context,
                    UserRole.researcher,
                    Icons.science_outlined,
                    Colors.green.shade700),
                _buildRoleCard(
                    context,
                    UserRole.farmer,
                    Icons.agriculture_outlined,
                    Colors.orange.shade700),
                _buildRoleCard(
                    context,
                    UserRole.citizen,
                    Icons.person_outline,
                    Colors.purple.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, UserRole role, IconData icon, Color color) {
    return InkWell(
      onTap: () => _selectRole(role),
      borderRadius: BorderRadius.circular(15.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 150, minHeight: 150),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: color),
                const SizedBox(height: 15),
                Text(
                  role.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentDisplay() {
    bool isAdvancedUser = _selectedRole == UserRole.policyMaker ||
        _selectedRole == UserRole.researcher;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (isAdvancedUser) ...[
          const _AdvancedTierWidget(),
          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
        _PracticalTierWidget(role: _selectedRole!),
      ],
    );
  }
}

// --- Tier Widgets ---

class _AdvancedTierWidget extends StatelessWidget {
  const _AdvancedTierWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Advanced Tier',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.model_training_outlined,
          title: 'Decision Support AI',
          content: const [
            'AI-powered policy and research assistant.',
            'Generates water management strategies.',
            'Runs scenario simulations.',
            'Predictive analytics for water table projections.',
          ],
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.dataset_outlined,
          title: 'Dataset Reports',
          content: const [
            'Download reports in CSV, PDF, Excel.',
            'Access rainfall, aquifer levels, and usage data.',
            'Yearly and seasonal comparative trends.',
          ],
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.construction_outlined,
          title: 'Advanced Tools',
          content: const [
            'GIS Mapping (rainfall vs recharge heatmaps).',
            'Aquifer recharge simulation models.',
            'Statistical calculators and analysis dashboards.',
          ],
        ),
      ],
    );
  }
}

class _PracticalTierWidget extends StatelessWidget {
  final UserRole role;
  const _PracticalTierWidget({required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Practical Tier',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.info_outline,
          title: 'Information & Guidelines',
          content: _getGuidelinesForRole(),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.water_drop_outlined,
          title: 'Effective Water Usage',
          content: const [
            'Sector-based recommendations (Agri, Domestic).',
            'Crop-specific irrigation advice.',
            'Household water footprint calculators.',
          ],
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.assessment_outlined,
          title: 'Groundwater Recharge Estimation',
          content: const [
            'Simple rainfall-to-recharge calculators.',
            'Farm/household level estimation tools.',
            'Easy-to-understand graphs and infographics.',
          ],
        ),
      ],
    );
  }

  List<String> _getGuidelinesForRole() {
    switch (role) {
      case UserRole.policyMaker:
      case UserRole.researcher:
        return [
          'Detailed best practices for water management.',
          'Access to relevant laws and regulations.',
          'In-depth case studies of conservation projects.'
        ];
      case UserRole.farmer:
        return [
          'Localized, simple steps for on-farm conservation.',
          'Guides on drip irrigation and farm ponds.',
          'Information on government schemes.'
        ];
      case UserRole.citizen:
        return [
          'Easy household tips for water saving.',
          'Information on greywater reuse.',
          'Guides for setting up rainwater harvesting.'
        ];
    }
  }
}

// --- Helper Widgets ---

Widget _buildFeatureCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required List<String> content,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ExpansionTile(
      leading: Icon(icon, color: AppTheme.primaryBlue, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: content.map((item) => ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 20),
                  title: Text(item),
                  dense: true,
                )).toList(),
          ),
        ),
      ],
    ),
  );
}
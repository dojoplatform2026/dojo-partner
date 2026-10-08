import 'package:flutter/material.dart';

import '../../theme.dart';
import 'navigation_screen.dart';

class WalkDetailsScreen extends StatelessWidget {
  const WalkDetailsScreen({
    super.key,
    required this.time,
    required this.dogName,
    required this.type,
    required this.duration,
    required this.location,
  });

  final String time;
  final String dogName;
  final String type;
  final String duration;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Walk Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 38,
                    child: Icon(
                      Icons.pets,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dogName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: DojoPartnerTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 15,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WALK INFORMATION',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.access_time_rounded,
              title: 'Scheduled Time',
              value: time,
            ),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.timer_outlined,
              title: 'Duration',
              value: duration,
            ),
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.location_on_outlined,
              title: 'Pickup Location',
              value: location,
            ),
            const SizedBox(height: 28),
            const Text(
              'CUSTOMER / DOG',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person_outline),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Customer details will appear here',
                          style: TextStyle(
                            fontSize: 13,
                            color: DojoPartnerTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NavigationScreen(
                      time: time,
                      dogName: dogName,
                      location: location,
                      duration: duration,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.navigation_outlined,
              ),
              label: const Text(
                'Navigate to Pickup',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DojoPartnerTheme.primaryOrange.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: DojoPartnerTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

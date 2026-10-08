import 'package:flutter/material.dart';

import '../../theme.dart';
import 'walk_details_screen.dart';
import 'schedule_screen.dart';

class PartnerHomeScreen extends StatelessWidget {
  const PartnerHomeScreen({super.key});

  void _openWalkDetails(
    BuildContext context, {
    required String time,
    required String dogName,
    required String type,
    required String duration,
    required String location,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalkDetailsScreen(
          time: time,
          dogName: dogName,
          type: type,
          duration: duration,
          location: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DOJO Partner',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Good Morning, Rahul 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: DojoPartnerTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Here is your work for today.',
              style: TextStyle(
                color: DojoPartnerTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Working',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Today',
                    style: TextStyle(
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "TODAY'S WORK",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _WalkCard(
              time: '07:00 AM',
              dogName: 'Bruno',
              type: 'Regular Walk',
              duration: '60 min',
              location: 'Civil Lines',
              onTap: () {
                _openWalkDetails(
                  context,
                  time: '07:00 AM',
                  dogName: 'Bruno',
                  type: 'Regular Walk',
                  duration: '60 min',
                  location: 'Civil Lines',
                );
              },
            ),
            const SizedBox(height: 12),
            _WalkCard(
              time: '06:00 PM',
              dogName: 'Bruno',
              type: 'Regular Walk',
              duration: '60 min',
              location: 'Civil Lines',
              onTap: () {
                _openWalkDetails(
                  context,
                  time: '06:00 PM',
                  dogName: 'Bruno',
                  type: 'Regular Walk',
                  duration: '60 min',
                  location: 'Civil Lines',
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleScreen(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _WalkCard extends StatelessWidget {
  const _WalkCard({
    required this.time,
    required this.dogName,
    required this.type,
    required this.duration,
    required this.location,
    required this.onTap,
  });

  final String time;
  final String dogName;
  final String type;
  final String duration;
  final String location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEAEAEA),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.pets),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          dogName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$type • $duration',
                          style: const TextStyle(
                            color:
                                DojoPartnerTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          location,
                          style: const TextStyle(
                            color:
                                DojoPartnerTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

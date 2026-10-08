import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../onboarding/bank_details_screen.dart';
import 'earnings_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'walk_details_screen.dart';
import 'working_schedule_screen.dart';

class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({super.key});

  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  bool _isLoading = true;
  bool _bankAdded = false;
  bool _scheduleSet = false;

  String _fullName = 'Partner';
  String _partnerId = 'DOJO-W-00124';

  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data() ?? <String, dynamic>{};

        final bank = data['bank'];
        final schedule = data['workingSchedule'];
        final fullName = data['fullName'];
        final walkerId = data['walkerId'];

        setState(() {
          _fullName = fullName is String &&
                  fullName.trim().isNotEmpty
              ? fullName.trim()
              : 'Partner';

          _partnerId = walkerId is String &&
                  walkerId.trim().isNotEmpty
              ? walkerId.trim()
              : 'DOJO-W-00124';

          _bankAdded = bank is Map &&
              bank['status'] != null &&
              bank['status'].toString().trim().isNotEmpty;

          _scheduleSet = schedule is Map &&
              schedule['status'] != null &&
              schedule['status'].toString().trim().isNotEmpty;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _openTab(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ScheduleScreen(),
          ),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const EarningsScreen(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _openBankDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BankDetailsScreen(),
      ),
    );

    if (!mounted) return;

    await _loadPartnerData();
  }

  Future<void> _openWorkingSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkingScheduleScreen(),
      ),
    );

    if (!mounted) return;

    await _loadPartnerData();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _fullName.trim().split(' ').first;

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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: DojoPartnerTheme.primaryOrange,
                ),
              )
            : RefreshIndicator(
                color: DojoPartnerTheme.primaryOrange,
                onRefresh: _loadPartnerData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    24,
                  ),
                  children: [
                    Text(
                      'Good morning, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: DojoPartnerTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Here's your work for today.",
                      style: TextStyle(
                        color: DojoPartnerTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // PARTNER CARD
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFEAEAEA),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: DojoPartnerTheme.primaryOrange
                                  .withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: DojoPartnerTheme.primaryOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Verified Partner',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Partner ID  •  $_partnerId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        DojoPartnerTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SETUP SECTION
                    if (!_bankAdded || !_scheduleSet) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'COMPLETE YOUR SETUP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: DojoPartnerTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (!_bankAdded)
                        _SetupCard(
                          icon: Icons.account_balance_outlined,
                          title: 'Add Bank Account',
                          description:
                              'Add your bank account to receive your earnings.',
                          buttonText: 'Add Bank Account',
                          onTap: _openBankDetails,
                        ),

                      if (!_bankAdded && !_scheduleSet)
                        const SizedBox(height: 12),

                      if (!_scheduleSet)
                        _SetupCard(
                          icon: Icons.calendar_month_outlined,
                          title: 'Set Working Schedule',
                          description:
                              'Set your working days and regular walk timings.',
                          buttonText: 'Set Schedule',
                          onTap: _openWorkingSchedule,
                        ),
                    ],

                    const SizedBox(height: 24),

                    // WORK STATUS
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
                            size: 11,
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

                    // TODAY OVERVIEW
                    const Text(
                      "TODAY'S OVERVIEW",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: DojoPartnerTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.directions_walk_outlined,
                            title: 'Walks',
                            value: '2',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.timer_outlined,
                            title: 'Hours',
                            value: '2 hrs',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // TODAY'S WORK
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

                    const SizedBox(height: 24),

                    // SUPPORT
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                                  color: DojoPartnerTheme.primaryOrange
                                      .withValues(alpha: 0.10),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.support_agent_outlined,
                                  color:
                                      DojoPartnerTheme.primaryOrange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need a day off?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Submit a leave request to DOJO.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            DojoPartnerTheme.textSecondary,
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          _openTab(context, index);
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
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
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

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE1C7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DojoPartnerTheme.primaryOrange
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: DojoPartnerTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          DojoPartnerTheme.primaryOrange,
                      side: const BorderSide(
                        color: DojoPartnerTheme.primaryOrange,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonText),
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: DojoPartnerTheme.primaryOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DojoPartnerTheme.textSecondary,
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

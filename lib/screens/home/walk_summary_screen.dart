import 'package:flutter/material.dart';

import '../../theme.dart';

class WalkSummaryScreen extends StatelessWidget {
  const WalkSummaryScreen({
    super.key,
    required this.dogName,
    required this.type,
    required this.scheduledTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.location,
  });

  final String dogName;
  final String type;
  final String scheduledTime;
  final int durationSeconds;
  final double distanceKm;
  final String location;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;

    if (minutes == 0) {
      return '$seconds sec';
    }

    return '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Walk Summary',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 72,
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'WALK COMPLETED',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  dogName,
                  style: const TextStyle(
                    fontSize: 17,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

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
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      scheduledTime,
                      style: const TextStyle(
                        color: DojoPartnerTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            icon: Icons.timer_outlined,
                            title: 'Duration',
                            value: formattedDuration,
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            icon: Icons.route_outlined,
                            title: 'Distance',
                            value:
                                '${distanceKm.toStringAsFixed(2)} km',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _SummaryItem(
                      icon: Icons.location_on_outlined,
                      title: 'Pickup',
                      value: location,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earning',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  DojoPartnerTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '₹XXX',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color:
                                  DojoPartnerTheme.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: DojoPartnerTheme.primaryOrange,
        ),
        const SizedBox(width: 10),
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
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

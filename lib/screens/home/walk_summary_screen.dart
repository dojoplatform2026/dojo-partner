import 'package:flutter/material.dart';

import '../../theme.dart';
import 'partner_home_screen.dart';

class WalkSummaryScreen extends StatelessWidget {
  const WalkSummaryScreen({
    super.key,
    required this.dogName,
    required this.walkType,
    required this.scheduledTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.location,
    this.peeCount = 0,
    this.poopCount = 0,
  });

  final String dogName;
  final String walkType;
  final String scheduledTime;
  final int durationSeconds;
  final double distanceKm;
  final String location;
  final int peeCount;
  final int poopCount;

  String _formatDuration() {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;

    if (minutes == 0) {
      return '$seconds sec';
    }

    if (seconds == 0) {
      return '$minutes min';
    }

    return '$minutes min $seconds sec';
  }

  String _formatDistance() {
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  String _earning() {
    // Current MVP earning for a regular 60-minute walk.
    // Actual earning will come from backend/booking data later.
    return '₹120';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoPartnerTheme.background,
      appBar: AppBar(
        title: const Text(
          'Walk Report',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),

                    // Completed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Dog
                    Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: DojoPartnerTheme.primaryOrange
                                .withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: DojoPartnerTheme.primaryOrange,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dogName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          walkType,
                          style: const TextStyle(
                            color: DojoPartnerTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Earning
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _earning(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: DojoPartnerTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Earning',
                            style: TextStyle(
                              color: DojoPartnerTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Walk details
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            text: scheduledTime,
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.timer_outlined,
                            text:
                                '${_formatDuration()}  •  ${_formatDistance()}',
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: location,
                          ),
                        ],
                      ),
                    ),

                    if (peeCount > 0 || poopCount > 0) ...[
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🐾 Walk Notes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (peeCount > 0)
                                  Expanded(
                                    child: Text(
                                      '💧 Pee × $peeCount',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (poopCount > 0)
                                  Expanded(
                                    child: Text(
                                      '💩 Poop × $poopCount',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Returned
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.pets,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dog returned',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Continue to Home
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartnerHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue to Home'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: DojoPartnerTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme.dart';
import 'live_walk_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({
    super.key,
    required this.time,
    required this.dogName,
    required this.location,
    required this.duration,
  });

  final String time;
  final String dogName;
  final String location;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Navigate to Pickup',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE9E9E9),
            child: const Center(
              child: Icon(
                Icons.map_outlined,
                size: 100,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),

          // Pickup information
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
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
                  const CircleAvatar(
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
                          'Pickup • $location',
                          style: const TextStyle(
                            color:
                                DojoPartnerTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          time,
                          style: const TextStyle(
                            color:
                                DojoPartnerTheme.primaryOrange,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFEAEAEA),
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color:
                              DojoPartnerTheme.primaryOrange,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You are navigating to the pickup location.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveWalkScreen(
                                time: time,
                                dogName: dogName,
                                location: location,
                                duration: duration,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Start Walk',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

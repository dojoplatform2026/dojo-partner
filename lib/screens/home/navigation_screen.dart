import 'package:flutter/material.dart';

import '../../theme.dart';
import 'live_walk_screen.dart';

class NavigationScreen extends StatefulWidget {
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
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _arrived = false;

  void _markArrived() {
    setState(() {
      _arrived = true;
    });
  }

  void _startWalk() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LiveWalkScreen(
          time: widget.time,
          dogName: widget.dogName,
          location: widget.location,
          duration: widget.duration,
        ),
      ),
    );
  }

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
          // Map placeholder.
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

          // Pickup information.
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
                    backgroundColor: Color(0xFFFFF1E8),
                    child: Icon(
                      Icons.pets,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dogName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pickup • ${widget.location}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DojoPartnerTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.time,
                          style: const TextStyle(
                            color: DojoPartnerTheme.primaryOrange,
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

          // Bottom action.
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
                    Row(
                      children: [
                        Icon(
                          _arrived
                              ? Icons.check_circle
                              : Icons.navigation_outlined,
                          color: _arrived
                              ? Colors.green
                              : DojoPartnerTheme.primaryOrange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _arrived
                                ? 'Pickup location reached. You can start the walk.'
                                : 'Navigate to the pickup location and mark your arrival.',
                            style: const TextStyle(
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
                        onPressed:
                            _arrived ? _startWalk : _markArrived,
                        child: Text(
                          _arrived
                              ? 'Start Walk'
                              : 'Arrived at Pickup',
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

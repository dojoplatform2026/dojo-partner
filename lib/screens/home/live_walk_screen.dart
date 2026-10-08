import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme.dart';
import 'walk_summary_screen.dart';

class LiveWalkScreen extends StatefulWidget {
  const LiveWalkScreen({
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
  State<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends State<LiveWalkScreen> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  int _seconds = 0;
  double _distanceMeters = 0;

  Position? _lastPosition;

  bool _isStarting = true;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _startWalk();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startWalk() async {
    final permission = await _checkLocationPermission();

    if (!permission) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is required to start the walk.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _isStarting = false;
    });

    // Start walk timer.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _seconds++;
        });
      },
    );

    // Start GPS tracking.
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        if (_lastPosition != null) {
          final meters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // Ignore GPS jumps/noise.
          if (meters > 0 && meters < 100) {
            _distanceMeters += meters;
          }
        }

        _lastPosition = position;

        if (mounted) {
          setState(() {});
        }
      },
      onError: (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to update your location.',
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkLocationPermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return false;

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Location is off',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            content: const Text(
              'Please turn on location services to start the walk.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
      }

      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  String get _formattedTime {
    final hours = _seconds ~/ 3600;
    final minutes = (_seconds % 3600) ~/ 60;
    final seconds = _seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get _formattedDistance {
    final kilometers = _distanceMeters / 1000;

    return '${kilometers.toStringAsFixed(2)} km';
  }

  Future<void> _endWalk() async {
    if (_isEnding) return;

    setState(() {
      _isEnding = true;
    });

    _timer?.cancel();

    await _positionSubscription?.cancel();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WalkSummaryScreen(
          dogName: widget.dogName,
          type: 'Regular Walk',
          scheduledTime: widget.time,
          durationSeconds: _seconds,
          distanceKm: _distanceMeters / 1000,
          location: widget.location,
        ),
      ),
    );
  }

  Future<void> _confirmEndWalk() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'End Walk?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to end the walk with ${widget.dogName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Continue Walk'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('End Walk'),
            ),
          ],
        );
      },
    );

    if (shouldEnd == true) {
      await _endWalk();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: DojoPartnerTheme.primaryOrange,
              ),
              SizedBox(height: 18),
              Text(
                'Starting walk...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Walk in Progress',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Dog information
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                        radius: 42,
                        child: Icon(
                          Icons.pets,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.dogName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Regular Walk • ${widget.duration}',
                        style: const TextStyle(
                          color: DojoPartnerTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          color:
                              DojoPartnerTheme.primaryOrange,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Timer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: DojoPartnerTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'WALK TIME',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formattedTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.route_outlined,
                        title: 'Distance',
                        value: _formattedDistance,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.location_on_outlined,
                        title: 'Pickup',
                        value: widget.location,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // End walk
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isEnding ? null : _confirmEndWalk,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                    ),
                    label: Text(
                      _isEnding
                          ? 'Ending Walk...'
                          : 'End Walk',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      child: Column(
        children: [
          Icon(
            icon,
            color: DojoPartnerTheme.primaryOrange,
          ),
          const SizedBox(height: 8),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

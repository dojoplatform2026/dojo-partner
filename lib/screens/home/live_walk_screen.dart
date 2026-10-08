import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    this.bookingId,
  });

  final String time;
  final String dogName;
  final String location;
  final String duration;
  final String? bookingId;

  @override
  State<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends State<LiveWalkScreen> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  int _seconds = 0;
  double _distanceMeters = 0;

  int _peeCount = 0;
  int _poopCount = 0;

  Position? _lastPosition;
  Position? _startPosition;

  DateTime? _startedAt;

  final List<Position> _route = [];

  bool _isStarting = true;
  bool _isEnding = false;
  bool _locationTracking = false;

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

    _startedAt = DateTime.now();

    setState(() {
      _isStarting = false;
      _locationTracking = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || _isEnding) return;

        setState(() {
          _seconds++;
        });
      },
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        _startPosition ??= position;

        if (_lastPosition != null) {
          final meters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          if (meters > 0 && meters < 100) {
            _distanceMeters += meters;
          }
        }

        _lastPosition = position;

        if (_route.isEmpty) {
          _route.add(position);
        } else {
          final last = _route.last;

          final movement = Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            position.latitude,
            position.longitude,
          );

          if (movement >= 3 && movement < 100) {
            _route.add(position);
          }
        }

        if (mounted) {
          setState(() {});
        }
      },
      onError: (_) {
        if (!mounted) return;

        setState(() {
          _locationTracking = false;
        });

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

  void _increasePee() {
    setState(() {
      _peeCount++;
    });
  }

  void _increasePoop() {
    setState(() {
      _poopCount++;
    });
  }

  void _decreasePee() {
    if (_peeCount == 0) return;

    setState(() {
      _peeCount--;
    });
  }

  void _decreasePoop() {
    if (_poopCount == 0) return;

    setState(() {
      _poopCount--;
    });
  }

  String get _formattedTime {
    final hours = _seconds ~/ 3600;
    final minutes = (_seconds % 3600) ~/ 60;
    final seconds = _seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
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
      _locationTracking = false;
    });

    _timer?.cancel();
    await _positionSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isEnding = false;
        _locationTracking = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to identify partner account.',
          ),
        ),
      );

      return;
    }

    try {
      final startedAt = _startedAt ?? DateTime.now();
      final endedAt = DateTime.now();

      final walkData = <String, dynamic>{
        'walkerId': user.uid,
        'dogName': widget.dogName,
        'walkType': 'Regular Walk',
        'scheduledTime': widget.time,
        'duration': _seconds,
        'distance': _distanceMeters / 1000,
        'location': widget.location,
        'peeCount': _peeCount,
        'poopCount': _poopCount,
        'startedAt': Timestamp.fromDate(startedAt),
        'endedAt': Timestamp.fromDate(endedAt),
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.bookingId != null &&
          widget.bookingId!.isNotEmpty) {
        walkData['bookingId'] = widget.bookingId;
      }

      if (_startPosition != null) {
        walkData['startLocation'] = GeoPoint(
          _startPosition!.latitude,
          _startPosition!.longitude,
        );
      }

      if (_lastPosition != null) {
        walkData['endLocation'] = GeoPoint(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
        );
      }

      await FirebaseFirestore.instance
          .collection('walks')
          .add(walkData);

      if (widget.bookingId != null &&
          widget.bookingId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WalkSummaryScreen(
            dogName: widget.dogName,
            walkType: 'Regular Walk',
            scheduledTime: widget.time,
            durationSeconds: _seconds,
            distanceKm: _distanceMeters / 1000,
            location: widget.location,
            peeCount: _peeCount,
            poopCount: _poopCount,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isEnding = false;
        _locationTracking = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Walk could not be saved. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmEndWalk() async {
    if (_isEnding) return;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DogHeader(
                  dogName: widget.dogName,
                  duration: widget.duration,
                ),
                const SizedBox(height: 12),
                _LiveMap(
                  route: _route,
                  tracking: _locationTracking,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        value: _formattedTime,
                        label: 'Walk Time',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: _formattedDistance,
                        label: 'Distance',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WalkNotesCard(
                  peeCount: _peeCount,
                  poopCount: _poopCount,
                  onPee: _increasePee,
                  onPoop: _increasePoop,
                  onPeeMinus: _decreasePee,
                  onPoopMinus: _decreasePoop,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _locationTracking
                          ? Icons.gps_fixed
                          : Icons.gps_off,
                      size: 18,
                      color: _locationTracking
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _locationTracking
                          ? 'GPS Tracking'
                          : 'GPS unavailable',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _locationTracking
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Return to Customer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SlideToEnd(
                  enabled: !_isEnding,
                  onCompleted: _confirmEndWalk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DogHeader extends StatelessWidget {
  const _DogHeader({
    required this.dogName,
    required this.duration,
  });

  final String dogName;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFFFF1E8),
          child: Icon(
            Icons.pets,
            color: DojoPartnerTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dogName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Regular Walk • $duration',
                style: const TextStyle(
                  fontSize: 13,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMap extends StatelessWidget {
  const _LiveMap({
    required this.route,
    required this.tracking,
  });

  final List<Position> route;
  final bool tracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E3E3),
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _RoutePainter(
              route: route,
              tracking: tracking,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tracking
                        ? Icons.gps_fixed
                        : Icons.gps_off,
                    size: 15,
                    color: tracking
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tracking ? 'LIVE GPS' : 'GPS OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: tracking
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.route,
    required this.tracking,
  });

  final List<Position> route;
  final bool tracking;

  @override
  void paint(Canvas canvas, Size size) {
    _drawMapBackground(canvas, size);

    if (route.isEmpty) {
      _drawStartMarker(
        canvas,
        Offset(
          size.width * 0.35,
          size.height * 0.52,
        ),
      );

      _drawCurrentMarker(
        canvas,
        Offset(
          size.width * 0.65,
          size.height * 0.52,
        ),
      );

      return;
    }

    if (route.length == 1) {
      final point = Offset(
        size.width * 0.55,
        size.height * 0.52,
      );

      _drawStartMarker(canvas, point);
      _drawCurrentMarker(canvas, point);

      return;
    }

    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (final position in route) {
      minLat = math.min(
        minLat,
        position.latitude,
      );
      maxLat = math.max(
        maxLat,
        position.latitude,
      );
      minLng = math.min(
        minLng,
        position.longitude,
      );
      maxLng = math.max(
        maxLng,
        position.longitude,
      );
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    final paddedLatRange =
        latRange == 0 ? 0.001 : latRange * 1.25;

    final paddedLngRange =
        lngRange == 0 ? 0.001 : lngRange * 1.25;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final scale = math.min(
      (size.width - 70) / paddedLngRange,
      (size.height - 70) / paddedLatRange,
    );

    Offset project(Position position) {
      final x = size.width / 2 +
          (position.longitude - centerLng) * scale;

      final y = size.height / 2 -
          (position.latitude - centerLat) * scale;

      return Offset(x, y);
    }

    final path = Path();

    for (var i = 0; i < route.length; i++) {
      final point = project(route[i]);

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      path,
      shadowPaint,
    );

    final routePaint = Paint()
      ..color = DojoPartnerTheme.primaryOrange
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      path,
      routePaint,
    );

    _drawStartMarker(
      canvas,
      project(route.first),
    );

    _drawCurrentMarker(
      canvas,
      project(route.last),
    );
  }

  void _drawMapBackground(
    Canvas canvas,
    Size size,
  ) {
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 55) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x + 70,
          size.height,
        ),
        roadPaint,
      );
    }

    for (var y = 25.0; y < size.height; y += 58) {
      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width,
          y + 35,
        ),
        roadPaint,
      );
    }

    final blockPaint = Paint()
      ..color = const Color(0xFFE8EAEA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var x = 25.0; x < size.width; x += 105) {
      for (var y = 35.0; y < size.height; y += 95) {
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            y,
            60,
            45,
          ),
          blockPaint,
        );
      }
    }
  }

  void _drawStartMarker(
    Canvas canvas,
    Offset point,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF333333);

    canvas.drawCircle(
      point,
      8,
      paint,
    );

    final inner = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      point,
      3,
      inner,
    );
  }

  void _drawCurrentMarker(
    Canvas canvas,
    Offset point,
  ) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18);

    canvas.drawCircle(
      point.translate(0, 2),
      14,
      shadow,
    );

    final outer = Paint()
      ..color = DojoPartnerTheme.primaryOrange;

    canvas.drawCircle(
      point,
      14,
      outer,
    );

    final inner = Paint()
      ..color = Colors.white;

    canvas.drawCircle(
      point,
      6,
      inner,
    );
  }

  @override
  bool shouldRepaint(
    covariant _RoutePainter oldDelegate,
  ) {
    return oldDelegate.route.length != route.length ||
        oldDelegate.tracking != tracking;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DojoPartnerTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkNotesCard extends StatelessWidget {
  const _WalkNotesCard({
    required this.peeCount,
    required this.poopCount,
    required this.onPee,
    required this.onPoop,
    required this.onPeeMinus,
    required this.onPoopMinus,
  });

  final int peeCount;
  final int poopCount;
  final VoidCallback onPee;
  final VoidCallback onPoop;
  final VoidCallback onPeeMinus;
  final VoidCallback onPoopMinus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        13,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Walk Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NoteControl(
                  emoji: '💧',
                  label: 'Pee',
                  count: peeCount,
                  onAdd: onPee,
                  onMinus: onPeeMinus,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NoteControl(
                  emoji: '💩',
                  label: 'Poop',
                  count: poopCount,
                  onAdd: onPoop,
                  onMinus: onPoopMinus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteControl extends StatelessWidget {
  const _NoteControl({
    required this.emoji,
    required this.label,
    required this.count,
    required this.onAdd,
    required this.onMinus,
  });

  final String emoji;
  final String label;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 19,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label $count',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: count > 0 ? onMinus : null,
            icon: const Icon(
              Icons.remove,
              size: 18,
            ),
            tooltip: 'Decrease $label',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            tooltip: 'Add $label',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SlideToEnd extends StatefulWidget {
  const _SlideToEnd({
    required this.enabled,
    required this.onCompleted,
  });

  final bool enabled;
  final Future<void> Function() onCompleted;

  @override
  State<_SlideToEnd> createState() => _SlideToEndState();
}

class _SlideToEndState extends State<_SlideToEnd> {
  double _value = 0;
  bool _completed = false;

  void _onChanged(double value) {
    if (!widget.enabled || _completed) return;

    setState(() {
      _value = value;
    });

    if (value >= 0.9) {
      _completed = true;
      widget.onCompleted();
    }
  }

  @override
  void didUpdateWidget(
    covariant _SlideToEnd oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled) {
      _value = 0;
      _completed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 55,
              ),
              child: const Text(
                'Slide to End Walk  →',
                style: TextStyle(
                  color: DojoPartnerTheme.primaryOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 58,
              activeTrackColor:
                  DojoPartnerTheme.primaryOrange,
              inactiveTrackColor:
                  Colors.transparent,
              thumbColor: Colors.white,
              overlayColor:
                  Colors.transparent,
              thumbShape:
                  const RoundSliderThumbShape(
                enabledThumbRadius: 25,
              ),
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 1,
              onChanged:
                  widget.enabled ? _onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

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
  bool _dogReceived = false;
  double _slideValue = 0;

  void _markArrived() {
    setState(() {
      _arrived = true;
    });
  }

  void _markDogReceived() {
    setState(() {
      _dogReceived = true;
    });
  }

  void _onSlideChanged(double value) {
    setState(() {
      _slideValue = value;
    });

    if (value >= 0.92) {
      _startWalk();
    }
  }

  void _startWalk() {
    if (!_dogReceived) return;

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
    final bool readyToStart = _arrived && _dogReceived;

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          readyToStart
                              ? Icons.check_circle
                              : _arrived
                                  ? Icons.pets
                                  : Icons.navigation_outlined,
                          color: readyToStart
                              ? Colors.green
                              : DojoPartnerTheme.primaryOrange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            !_arrived
                                ? 'Navigate to the pickup location and mark your arrival.'
                                : !_dogReceived
                                    ? 'Pickup location reached. Confirm that you received the dog.'
                                    : '${widget.dogName} received. You can start the walk.',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!_arrived)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _markArrived,
                          child: const Text('Arrived at Pickup'),
                        ),
                      )
                    else if (!_dogReceived)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _markDogReceived,
                          icon: const Icon(Icons.pets),
                          label: const Text('Dog Received'),
                        ),
                      )
                    else
                      _SlideToStart(
                        value: _slideValue,
                        onChanged: _onSlideChanged,
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

class _SlideToStart extends StatelessWidget {
  const _SlideToStart({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                minThumbSeparation: 0,
                trackHeight: 58,
                activeTrackColor:
                    DojoPartnerTheme.primaryOrange,
                inactiveTrackColor:
                    const Color(0xFFFFE0CC),
                thumbColor: Colors.white,
                overlayColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 25,
                ),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                onChanged: onChanged,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Text(
              'Slide to Start',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: DojoPartnerTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

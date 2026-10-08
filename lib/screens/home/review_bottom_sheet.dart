import 'package:flutter/material.dart';

import '../../theme.dart';

class ReviewResult {
  const ReviewResult({
    required this.submitted,
    required this.rating,
    required this.note,
  });

  final bool submitted;
  final int rating;
  final String note;
}

class ReviewBottomSheet extends StatefulWidget {
  const ReviewBottomSheet({
    super.key,
    required this.dogName,
  });

  final String dogName;

  @override
  State<ReviewBottomSheet> createState() =>
      _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _rating = 0;

  final TextEditingController _noteController =
      TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      ReviewResult(
        submitted: true,
        rating: _rating,
        note: _noteController.text.trim(),
      ),
    );
  }

  void _skipReview() {
    Navigator.pop(
      context,
      const ReviewResult(
        submitted: false,
        rating: 0,
        note: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D8D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'Rate Walk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F3F3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dogName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Regular Walk',
                        style: TextStyle(
                          fontSize: 13,
                          color: DojoPartnerTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'How was the walk?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) {
                    final starNumber = index + 1;
                    final selected = starNumber <= _rating;

                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = starNumber;
                        });
                      },
                      iconSize: 38,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: selected
                            ? DojoPartnerTheme.primaryOrange
                            : const Color(0xFFBDBDBD),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Optional note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 300,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Tell us about the walk...',
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text(
                    'Submit Review',
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Center(
                child: TextButton(
                  onPressed: _skipReview,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: DojoPartnerTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

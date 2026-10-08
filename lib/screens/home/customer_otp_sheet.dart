import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class CustomerOtpSheet extends StatefulWidget {
  const CustomerOtpSheet({
    super.key,
    required this.bookingId,
    required this.dogName,
  });

  final String bookingId;
  final String dogName;

  @override
  State<CustomerOtpSheet> createState() =>
      _CustomerOtpSheetState();
}

class _CustomerOtpSheetState
    extends State<CustomerOtpSheet> {
  final TextEditingController _otpController =
      TextEditingController();

  bool _isVerifying = false;
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final enteredOtp =
        _otpController.text.trim();

    if (enteredOtp.length != 4) {
      setState(() {
        _errorText = 'Enter the 4-digit OTP.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      final bookingSnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(widget.bookingId)
              .get();

      final data = bookingSnapshot.data();

      if (data == null) {
        setState(() {
          _isVerifying = false;
          _errorText =
              'Booking information not found.';
        });
        return;
      }

      final customerOtp = _getCustomerOtp(data);

      if (customerOtp == null ||
          customerOtp.isEmpty) {
        setState(() {
          _isVerifying = false;
          _errorText =
              'Customer OTP is not available.';
        });
        return;
      }

      if (enteredOtp != customerOtp) {
        setState(() {
          _isVerifying = false;
          _errorText =
              'Incorrect OTP. Please try again.';
        });
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _errorText =
            'Unable to verify OTP. Please try again.';
      });
    }
  }

  String? _getCustomerOtp(
    Map<String, dynamic> data,
  ) {
    const possibleFields = [
      'customerOtp',
      'returnOtp',
      'otp',
    ];

    for (final field in possibleFields) {
      final value = data[field];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom +
                  20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D5D5),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFF1E8),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color:
                        DojoPartnerTheme
                            .primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verify Customer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.dogName,
                        style: const TextStyle(
                          fontSize: 13,
                          color:
                              DojoPartnerTheme
                                  .textSecondary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Enter Customer OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ask the customer for the 4-digit OTP '
              'to confirm safe handover.',
              style: TextStyle(
                fontSize: 13,
                color:
                    DojoPartnerTheme
                        .textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _otpController,
              autofocus: true,
              enabled: !_isVerifying,
              keyboardType:
                  TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                errorText: _errorText,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 17,
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _isVerifying
                        ? null
                        : _verifyOtp,
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Verify OTP',
                      ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'OTP is required only when return location does not match.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      DojoPartnerTheme
                          .textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

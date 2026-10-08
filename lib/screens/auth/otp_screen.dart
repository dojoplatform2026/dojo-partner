import 'package:flutter/material.dart';

import '../../theme.dart';
import 'account_check_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the 6-digit OTP'),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Temporary OTP verification.
    // Firebase Phone Auth will replace this later.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AccountCheckScreen(
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter the 6-digit OTP sent to ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '------',
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify OTP'),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: _isVerifying ? null : () {},
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: DojoPartnerTheme.primaryOrange,
                      fontWeight: FontWeight.w700,
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

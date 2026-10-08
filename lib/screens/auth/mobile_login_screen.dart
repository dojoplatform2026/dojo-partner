import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import 'otp_screen.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = '+91${_phoneController.text.trim()}';

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(
              credential,
            );

            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  phoneNumber: phone,
                  verificationId: '',
                ),
              ),
            );
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.message ?? 'Automatic verification failed.',
                ),
              ),
            );
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          String message = 'Unable to send OTP.';

          if (e.code == 'invalid-phone-number') {
            message = 'Invalid mobile number.';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many attempts. Please try again later.';
          } else if (e.message != null) {
            message = e.message!;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phoneNumber: phone,
                verificationId: verificationId,
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // OTP timeout is handled by Firebase.
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Something went wrong.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                const Text(
                  'DOJO',
                  style: TextStyle(
                    color: DojoPartnerTheme.primaryOrange,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Walker Partner',
                  style: TextStyle(
                    fontSize: 16,
                    color: DojoPartnerTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 48),

                const Text(
                  'Welcome back 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Enter your mobile number to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    counterText: '',
                    prefixText: '+91  ',
                    prefixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: DojoPartnerTheme.textPrimary,
                    ),
                    hintText: 'Mobile Number',
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Enter your mobile number';
                    }

                    if (!RegExp(r'^[6-9][0-9]{9}$')
                        .hasMatch(phone)) {
                      return 'Enter a valid 10-digit mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send OTP'),
                ),

                const SizedBox(height: 24),

                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: DojoPartnerTheme.textSecondary,
                      ),
                      children: [
                        TextSpan(text: 'New to DOJO? '),
                        TextSpan(
                          text: 'Join as a Walker',
                          style: TextStyle(
                            color: DojoPartnerTheme.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                const Center(
                  child: Text(
                    'Terms • Privacy • Help',
                    style: TextStyle(
                      fontSize: 12,
                      color: DojoPartnerTheme.textSecondary,
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

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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final phone = '+91${_phoneController.text.trim()}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(phoneNumber: phone),
      ),
    );
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

                    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
                      return 'Enter a valid 10-digit mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
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

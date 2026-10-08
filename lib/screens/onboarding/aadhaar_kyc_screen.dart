import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class AadhaarKycScreen extends StatefulWidget {
  const AadhaarKycScreen({super.key});

  @override
  State<AadhaarKycScreen> createState() => _AadhaarKycScreenState();
}

class _AadhaarKycScreenState extends State<AadhaarKycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();

  bool _isSaving = false;
  bool _obscureAadhaar = true;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  String _cleanAadhaar(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login session expired. Please login again.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final aadhaar = _cleanAadhaar(
        _aadhaarController.text,
      );

      // Do not store the full Aadhaar number in Firestore.
      // This temporary masked value is only for onboarding state.
      final maskedAadhaar =
          'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';

      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .set(
        {
          'kyc': {
            'aadhaar': {
              'status': 'pending',
              'maskedNumber': maskedAadhaar,
            },
          },
          'verificationStatus': 'pending',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aadhaar details submitted for verification.',
          ),
        ),
      );

      // Next step: PAN KYC.
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to save KYC information.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhaar KYC'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              32,
            ),
            children: [
              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your 12-digit Aadhaar number for identity verification.',
                style: TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                obscureText: _obscureAadhaar,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Aadhaar Number',
                  hintText: '12-digit Aadhaar number',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip: _obscureAadhaar
                        ? 'Show Aadhaar'
                        : 'Hide Aadhaar',
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _obscureAadhaar = !_obscureAadhaar;
                            });
                          },
                    icon: Icon(
                      _obscureAadhaar
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final aadhaar = _cleanAadhaar(
                    value ?? '',
                  );

                  if (aadhaar.isEmpty) {
                    return 'Enter your Aadhaar number';
                  }

                  if (aadhaar.length != 12) {
                    return 'Aadhaar must contain 12 digits';
                  }

                  if (aadhaar.startsWith('0') ||
                      aadhaar.startsWith('1')) {
                    return 'Enter a valid Aadhaar number';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFE0C2),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: DojoPartnerTheme.primaryOrange,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your Aadhaar number should only be used for identity verification. DOJO will not store the complete number in the app database.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: DojoPartnerTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _isSaving ? null : _continue,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

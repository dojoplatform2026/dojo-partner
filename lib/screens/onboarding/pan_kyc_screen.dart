import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class PanKycScreen extends StatefulWidget {
  const PanKycScreen({super.key});

  @override
  State<PanKycScreen> createState() => _PanKycScreenState();
}

class _PanKycScreenState extends State<PanKycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();

  bool _isSaving = false;
  bool _obscurePan = true;

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  String _cleanPan(String value) {
    return value.trim().toUpperCase().replaceAll(' ', '');
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
      final pan = _cleanPan(_panController.text);

      final maskedPan =
          'XXXXX${pan.substring(pan.length - 4)}';

      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .set(
        {
          'kyc': {
            'pan': {
              'status': 'pending',
              'maskedNumber': maskedPan,
            },
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PAN details submitted for verification.',
          ),
        ),
      );

      // Next step: Live selfie verification.
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to save PAN information.',
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
        title: const Text('PAN KYC'),
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
                'PAN verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your 10-character PAN number for verification.',
                style: TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _panController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                obscureText: _obscurePan,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'PAN Number',
                  hintText: 'ABCDE1234F',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePan ? 'Show PAN' : 'Hide PAN',
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _obscurePan = !_obscurePan;
                            });
                          },
                    icon: Icon(
                      _obscurePan
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final pan = _cleanPan(value ?? '');

                  if (pan.isEmpty) {
                    return 'Enter your PAN number';
                  }

                  if (!RegExp(
                    r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                  ).hasMatch(pan)) {
                    return 'Enter a valid PAN number';
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
                        'Only a masked PAN reference is stored in the app database. Full KYC verification will be handled securely.',
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

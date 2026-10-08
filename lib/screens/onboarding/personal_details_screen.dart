import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState
    extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login session expired. Please login again.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final uid = user.uid;
      final phone = user.phoneNumber ?? '';

      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(uid)
          .set(
        {
          'userId': uid,
          'walkerId': uid,
          'fullName': _nameController.text.trim(),
          'phone': phone,
          'status': 'pending',
          'isActive': false,
          'isApproved': false,
          'verificationStatus': 'not_started',
          'services': <String>[],
          'rating': 0,
          'totalWalks': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Personal details saved successfully.',
          ),
        ),
      );

      // Next step:
      // Work Zone screen will be added here.
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to save your details.',
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
        title: const Text('Personal Details'),
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
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your basic details to start your DOJO Partner application.',
                style: TextStyle(
                  fontSize: 15,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter your full name';
                  }

                  if (name.length < 3) {
                    return 'Name must be at least 3 characters';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DojoPartnerTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                FirebaseAuth.instance.currentUser?.phoneNumber ??
                    'Verified mobile number',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DojoPartnerTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
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

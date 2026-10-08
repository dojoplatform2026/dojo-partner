import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class ReviewSubmitScreen extends StatefulWidget {
  const ReviewSubmitScreen({super.key});

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  bool _loading = true;
  bool _submitting = false;
  bool _agreed = false;

  Map<String, dynamic>? _walkerData;

  @override
  void initState() {
    super.initState();
    _loadWalkerData();
  }

  Future<void> _loadWalkerData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        _walkerData = snapshot.data();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load your details. Please try again.',
          ),
        ),
      );
    }
  }

  String _value(String key) {
    final value = _walkerData?[key];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Not provided';
    }

    return value.toString();
  }

  String _nestedValue(List<String> keys) {
    dynamic current = _walkerData;

    for (final key in keys) {
      if (current is Map) {
        current = current[key];
      } else {
        return 'Not provided';
      }
    }

    if (current == null || current.toString().trim().isEmpty) {
      return 'Not provided';
    }

    return current.toString();
  }

  Future<void> _submitApplication() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please confirm that your information is correct.',
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session expired. Please login again.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('walkers')
          .doc(user.uid)
          .set(
        {
          'status': 'under_review',
          'isActive': false,
          'isApproved': false,
          'verificationStatus': 'pending',
          'applicationSubmittedAt':
              FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ApplicationSubmittedScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Submission failed. Please try again.',
          ),
        ),
      );
    }
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DojoPartnerTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: DojoPartnerTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DojoPartnerTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(
    String title,
    String status,
  ) {
    final pending = status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            pending
                ? Icons.hourglass_empty_rounded
                : Icons.check_circle_outline_rounded,
            size: 21,
            color: pending
                ? const Color(0xFF777777)
                : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: pending
                  ? const Color(0xFF777777)
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: DojoPartnerTheme.primaryOrange,
              ),
            )
          : _walkerData == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load your application.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWalkerData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final aadhaarStatus = _nestedValue(
      ['kyc', 'aadhaar', 'status'],
    );

    final panStatus = _nestedValue(
      ['kyc', 'pan', 'status'],
    );

    final selfieStatus = _nestedValue(
      ['kyc', 'selfie', 'status'],
    );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Review your application',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: DojoPartnerTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please check your details before submitting your application.',
                    style: TextStyle(
                      fontSize: 14,
                      color: DojoPartnerTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _section(
                    title: 'Personal Details',
                    children: [
                      _row(
                        'Full Name',
                        _value('fullName'),
                      ),
                      _row(
                        'Phone',
                        _value('phone'),
                      ),
                    ],
                  ),

                  _section(
                    title: 'Work Zone',
                    children: [
                      _row(
                        'Primary Zone',
                        _value('zoneName'),
                      ),
                    ],
                  ),

                  _section(
                    title: 'KYC & Verification',
                    children: [
                      _verificationRow(
                        'Aadhaar KYC',
                        aadhaarStatus,
                      ),
                      _verificationRow(
                        'PAN KYC',
                        panStatus,
                      ),
                      _verificationRow(
                        'Live Selfie',
                        selfieStatus,
                      ),
                    ],
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFDFC4),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color:
                              DojoPartnerTheme.primaryOrange,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'After submission, DOJO will review your application. You will not be able to accept walks until your Partner account is approved.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color:
                                  DojoPartnerTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _agreed = !_agreed;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: _agreed
                              ? DojoPartnerTheme
                                  .primaryOrange
                              : const Color(0xFFE5E5E5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreed,
                            activeColor:
                                DojoPartnerTheme
                                    .primaryOrange,
                            onChanged: (value) {
                              setState(() {
                                _agreed = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 12,
                                right: 4,
                              ),
                              child: Text(
                                'I confirm that the information provided by me is correct and I agree to DOJO reviewing my Partner application.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE8E8E8),
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : _submitApplication,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Application',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationSubmittedScreen extends StatelessWidget {
  const ApplicationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  height: 82,
                  width: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8EE),
                    borderRadius:
                        BorderRadius.circular(41),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Application Submitted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your DOJO Partner application is now under review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: DojoPartnerTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              DojoPartnerTheme
                                  .textSecondary,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'UNDER REVIEW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color:
                              DojoPartnerTheme
                                  .primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'DOJO will review your details and notify you once your Partner account is approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color:
                        DojoPartnerTheme
                            .textSecondary,
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

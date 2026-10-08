import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../home/partner_home_screen.dart';

class AccountCheckScreen extends StatefulWidget {
  const AccountCheckScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  State<AccountCheckScreen> createState() => _AccountCheckScreenState();
}

class _AccountCheckScreenState extends State<AccountCheckScreen> {
  String _message = 'Checking your DOJO Partner account...';

  @override
  void initState() {
    super.initState();
    _checkAccount();
  }

  Future<void> _checkAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'not-signed-in',
          message: 'Your login session could not be found.',
        );
      }

      final uid = user.uid;

      final walkerDoc = await FirebaseFirestore.instance
          .collection('walkers')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (!walkerDoc.exists) {
        setState(() {
          _message = 'New Walker account detected.';
        });

        _showNewWalkerMessage();
        return;
      }

      final data = walkerDoc.data() ?? {};

      final status = data['status']?.toString() ?? 'pending';
      final isActive = data['isActive'] == true;
      final isApproved = data['isApproved'] == true;

      if (status == 'approved' && isActive && isApproved) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const PartnerHomeScreen(),
          ),
          (route) => false,
        );
        return;
      }

      if (status == 'pending' || status == 'under_review') {
        setState(() {
          _message = 'Your application is under review.';
        });
        return;
      }

      if (status == 'correction_required') {
        setState(() {
          _message = 'Some information needs correction.';
        });
        return;
      }

      if (status == 'suspended') {
        setState(() {
          _message = 'Your DOJO Partner account is suspended.';
        });
        return;
      }

      if (status == 'rejected') {
        setState(() {
          _message = 'Your Partner application was not approved.';
        });
        return;
      }

      if (status == 'left') {
        setState(() {
          _message = 'This Partner account is inactive.';
        });
        return;
      }

      setState(() {
        _message = 'Your account is being checked by DOJO.';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _message = e.message ?? 'Unable to check your account.';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _message = e.message ?? 'Unable to connect to DOJO.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message = 'Something went wrong. Please try again.';
      });
    }
  }

  void _showNewWalkerMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'New Walker account detected. Onboarding will be available next.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DOJO',
                  style: TextStyle(
                    color: DojoPartnerTheme.primaryOrange,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DOJO Partner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DojoPartnerTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: DojoPartnerTheme.primaryOrange,
                ),
                const SizedBox(height: 24),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: DojoPartnerTheme.textSecondary,
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

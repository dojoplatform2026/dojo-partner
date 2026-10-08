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
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Temporary: approved Walker flow.
      // Firebase account status check will replace this.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PartnerHomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: DojoPartnerTheme.primaryOrange,
            ),
            SizedBox(height: 20),
            Text(
              'Checking your DOJO Partner account...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: DojoPartnerTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

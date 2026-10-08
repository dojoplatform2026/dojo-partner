import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/splash/splash_screen.dart';

class DojoPartnerApp extends StatelessWidget {
  const DojoPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOJO Partner',
      debugShowCheckedModeBanner: false,
      theme: DojoPartnerTheme.light(),
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme.dart';

/// Branded loading screen shown for the brief moment while saved data loads.
/// Mirrors the native iOS launch screen so there's no visual jump once
/// Flutter takes over.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ColoredBox(
      color: c.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GREASETRAIL',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 3, color: c.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'by lemai.re',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.2, color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        backgroundColor: CarNationColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: CarNationColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(
                        CarNationRadii.page,
                      ),
                      border: Border.all(color: CarNationColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/company_logo.png',
                      fit: BoxFit.contain,
                      semanticLabel: 'CarNation logo',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CarNation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CarNationColors.textPrimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find the car that fits your next journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CarNationColors.textSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Semantics(
                    label: 'Loading CarNation',
                    liveRegion: true,
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

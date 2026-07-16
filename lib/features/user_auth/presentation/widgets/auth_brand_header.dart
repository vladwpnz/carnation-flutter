import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String supportingText;

  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.supportingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: CarNationColors.surfaceRaised,
              borderRadius: BorderRadius.circular(CarNationRadii.card),
              border: Border.all(color: CarNationColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/company_logo.png',
              fit: BoxFit.contain,
              semanticLabel: 'CarNation logo',
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'CarNation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          supportingText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CarNationColors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

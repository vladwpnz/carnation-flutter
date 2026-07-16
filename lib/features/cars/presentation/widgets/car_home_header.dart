import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/cars/presentation/widgets/saved_badge_button.dart';
import 'package:motor_show/features/compare/application/comparison_controller.dart';
import 'package:motor_show/features/saved/application/saved_cars_controller.dart';

enum _HomeMenuAction { compare, signOut }

class CarHomeHeader extends StatelessWidget {
  final SavedCarsController savedCarsController;
  final ComparisonController comparisonController;
  final VoidCallback onSavedPressed;
  final VoidCallback onComparePressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onLogoutPressed;

  const CarHomeHeader({
    super.key,
    required this.savedCarsController,
    required this.comparisonController,
    required this.onSavedPressed,
    required this.onComparePressed,
    required this.onProfilePressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CarNationColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  'assets/company_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CarNation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SavedBadgeButton(
                controller: savedCarsController,
                onPressed: onSavedPressed,
              ),
              const SizedBox(width: 2),
              Tooltip(
                message: 'Open profile',
                child: Semantics(
                  button: true,
                  label: 'Open profile',
                  child: InkWell(
                    onTap: onProfilePressed,
                    borderRadius: BorderRadius.circular(999),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'assets/profile_picture.jpg',
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: comparisonController,
                builder: (context, _) {
                  return PopupMenuButton<_HomeMenuAction>(
                    key: const Key('home-more-menu'),
                    tooltip: 'More actions',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (action) {
                      switch (action) {
                        case _HomeMenuAction.compare:
                          onComparePressed();
                        case _HomeMenuAction.signOut:
                          onLogoutPressed();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _HomeMenuAction.compare,
                        child: Row(
                          children: [
                            const Icon(Icons.compare_arrows_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                comparisonController.count == 0
                                    ? 'Compare vehicles'
                                    : 'Compare vehicles (${comparisonController.count})',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: _HomeMenuAction.signOut,
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded),
                            SizedBox(width: 12),
                            Text('Sign out'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Find the right car',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search by model, compare prices, and filter the catalogue instantly.',
            style: TextStyle(
              color: CarNationColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
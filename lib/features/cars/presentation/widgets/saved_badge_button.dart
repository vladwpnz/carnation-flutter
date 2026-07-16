import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/saved/application/saved_cars_controller.dart';

class SavedBadgeButton extends StatelessWidget {
  final SavedCarsController controller;
  final VoidCallback onPressed;

  const SavedBadgeButton({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              key: const Key('open-saved-cars'),
              tooltip: 'Saved cars',
              onPressed: onPressed,
              icon: const Icon(Icons.favorite_outline_rounded),
            ),
            if (controller.count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Semantics(
                  label: '${controller.count} saved vehicles',
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CarNationColors.accent,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: CarNationColors.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      controller.count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

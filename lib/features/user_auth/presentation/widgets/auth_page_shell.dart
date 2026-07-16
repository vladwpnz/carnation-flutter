import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';

class AuthPageShell extends StatelessWidget {
  final Widget child;
  final Widget? topAction;

  const AuthPageShell({
    super.key,
    required this.child,
    this.topAction,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Builder(
        builder: (context) {
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

          return Scaffold(
            backgroundColor: CarNationColors.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight =
                      constraints.maxHeight - 40 - keyboardInset;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      24 + keyboardInset,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                availableHeight > 0 ? availableHeight : 0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (topAction != null) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: topAction!,
                                ),
                                const SizedBox(height: 4),
                              ],
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

class RequestStatusBadge extends StatelessWidget {
  final VehicleRequestStatus status;

  const RequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == VehicleRequestStatus.cancelled;
    final foreground = isCancelled
        ? CarNationColors.danger
        : status == VehicleRequestStatus.completed
            ? const Color(0xFF86EFAC)
            : CarNationColors.accentSoft;

    return Semantics(
      label: 'Current status: ${status.label}',
      child: Container(
        key: Key('request-status-${status.firestoreValue}'),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foreground.withValues(alpha: 0.55)),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

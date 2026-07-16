import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

class RequestStatusTimeline extends StatelessWidget {
  static const _normalStages = <_TimelineStage>[
    _TimelineStage(
      status: VehicleRequestStatus.submitted,
      title: 'Submitted',
      explanation: 'The request has been received.',
    ),
    _TimelineStage(
      status: VehicleRequestStatus.underReview,
      title: 'Under review',
      explanation: 'The vehicle and selected services are being reviewed.',
    ),
    _TimelineStage(
      status: VehicleRequestStatus.customerContacted,
      title: 'Customer contacted',
      explanation: 'A representative has contacted the customer.',
    ),
    _TimelineStage(
      status: VehicleRequestStatus.offerPrepared,
      title: 'Offer prepared',
      explanation: 'The vehicle offer has been prepared.',
    ),
    _TimelineStage(
      status: VehicleRequestStatus.completed,
      title: 'Completed',
      explanation: 'The request process has been completed.',
    ),
  ];

  final VehicleRequestStatus status;

  const RequestStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final entries = _entriesForStatus();

    return Semantics(
      label: 'Request status timeline',
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index += 1)
            _TimelineRow(
              entry: entries[index],
              isLast: index == entries.length - 1,
            ),
        ],
      ),
    );
  }

  List<_TimelineEntry> _entriesForStatus() {
    if (status == VehicleRequestStatus.cancelled) {
      return <_TimelineEntry>[
        _TimelineEntry(
          stage: _normalStages.first,
          state: _TimelineState.completed,
        ),
        const _TimelineEntry(
          stage: _TimelineStage(
            status: VehicleRequestStatus.cancelled,
            title: 'Cancelled',
            explanation: 'The request will no longer be processed.',
          ),
          state: _TimelineState.current,
        ),
        for (final stage in _normalStages.skip(1))
          _TimelineEntry(stage: stage, state: _TimelineState.upcoming),
      ];
    }

    final currentIndex = _normalStages.indexWhere(
      (stage) => stage.status == status,
    );
    final safeCurrentIndex = currentIndex < 0 ? 0 : currentIndex;

    return <_TimelineEntry>[
      for (var index = 0; index < _normalStages.length; index += 1)
        _TimelineEntry(
          stage: _normalStages[index],
          state: index < safeCurrentIndex
              ? _TimelineState.completed
              : index == safeCurrentIndex
                  ? _TimelineState.current
                  : _TimelineState.upcoming,
        ),
    ];
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineEntry entry;
  final bool isLast;

  const _TimelineRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final stateName = entry.state.name;
    final isCancelled = entry.stage.status == VehicleRequestStatus.cancelled;
    final nodeColor = isCancelled
        ? CarNationColors.danger
        : switch (entry.state) {
            _TimelineState.completed => const Color(0xFF4ADE80),
            _TimelineState.current => CarNationColors.accentSoft,
            _TimelineState.upcoming => CarNationColors.textMuted,
          };
    final icon = switch (entry.state) {
      _TimelineState.completed => Icons.check_rounded,
      _TimelineState.current when isCancelled => Icons.close_rounded,
      _TimelineState.current => Icons.circle,
      _TimelineState.upcoming => Icons.circle_outlined,
    };

    return Semantics(
      label: '${entry.stage.title}, $stateName. ${entry.stage.explanation}',
      child: Row(
        key: Key(
          'timeline-${entry.stage.status.firestoreValue}-$stateName',
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.state == _TimelineState.current
                        ? nodeColor.withValues(alpha: 0.16)
                        : CarNationColors.surfaceRaised,
                    border: Border.all(color: nodeColor, width: 2),
                  ),
                  child: Icon(icon, size: 16, color: nodeColor),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 58,
                    color: entry.state == _TimelineState.completed
                        ? nodeColor
                        : CarNationColors.border,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.stage.title,
                    style: TextStyle(
                      color: entry.state == _TimelineState.upcoming
                          ? CarNationColors.textSecondary
                          : CarNationColors.textPrimary,
                      fontSize: 15,
                      fontWeight: entry.state == _TimelineState.current
                          ? FontWeight.w900
                          : FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.stage.explanation,
                    style: const TextStyle(
                      color: CarNationColors.textMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TimelineState { completed, current, upcoming }

class _TimelineStage {
  final VehicleRequestStatus status;
  final String title;
  final String explanation;

  const _TimelineStage({
    required this.status,
    required this.title,
    required this.explanation,
  });
}

class _TimelineEntry {
  final _TimelineStage stage;
  final _TimelineState state;

  const _TimelineEntry({required this.stage, required this.state});
}

import 'package:flutter/material.dart';
import 'package:carnation/core/navigation/carnation_route.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/additional_service.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/pages/my_requests_page.dart';
import 'package:carnation/features/requests/presentation/widgets/request_status_badge.dart';

class RequestConfirmationPage extends StatelessWidget {
  final String requestId;
  final Car car;
  final List<AdditionalService> selectedServices;
  final int estimatedTotal;
  final VehicleRequestRepository requestRepository;

  const RequestConfirmationPage({
    super.key,
    required this.requestId,
    required this.car,
    required this.selectedServices,
    required this.estimatedTotal,
    required this.requestRepository,
  });

  @override
  Widget build(BuildContext context) {
    final servicesSubtotal = selectedServices.fold(
      0,
      (total, service) => total + service.price,
    );

    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(title: const Text('Request submitted')),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: CarNationColors.surface,
                          borderRadius: BorderRadius.circular(
                            CarNationRadii.page,
                          ),
                          border: Border.all(
                            color: CarNationColors.accent,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: CarNationColors.accentSoft,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Request submitted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CarNationColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        shortVehicleRequestDisplayId(requestId),
                        key: const Key('submitted-request-id'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CarNationColors.accentSoft,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const RequestStatusBadge(
                        status: VehicleRequestStatus.submitted,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your vehicle request has been saved. Its status will appear in My requests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CarNationColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No payment has been processed and the vehicle has not been reserved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CarNationColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _RequestSummary(
                        car: car,
                        selectedServices: selectedServices,
                        servicesSubtotal: servicesSubtotal,
                        estimatedTotal: estimatedTotal,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('view-my-requests'),
                          onPressed: () => Navigator.of(context).push(
                            carNationRoute<void>(
                              builder: (_) => MyRequestsPage(
                                requestRepository: requestRepository,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('View my requests'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          ),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Back to Home'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSummary extends StatelessWidget {
  final Car car;
  final List<AdditionalService> selectedServices;
  final int servicesSubtotal;
  final int estimatedTotal;

  const _RequestSummary({
    required this.car,
    required this.selectedServices,
    required this.servicesSubtotal,
    required this.estimatedTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CarNationColors.surface,
        borderRadius: BorderRadius.circular(CarNationRadii.card),
        border: Border.all(color: CarNationColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request summary',
            style: TextStyle(
              color: CarNationColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            car.fullName,
            style: const TextStyle(
              color: CarNationColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
              label: 'Vehicle price', value: Car.formatPrice(car.price)),
          const Divider(height: 24),
          if (selectedServices.isEmpty)
            const Text(
              'No additional services selected',
              style: TextStyle(color: CarNationColors.textMuted),
            )
          else
            for (final service in selectedServices)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SummaryRow(
                  label: service.title,
                  value:
                      service.isFree ? 'Free' : Car.formatPrice(service.price),
                ),
              ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Services subtotal',
            value: Car.formatPrice(servicesSubtotal),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Estimated total',
            value: Car.formatPrice(estimatedTotal),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized
                  ? CarNationColors.textPrimary
                  : CarNationColors.textSecondary,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: emphasized
                  ? CarNationColors.accentSoft
                  : CarNationColors.textPrimary,
              fontSize: emphasized ? 18 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

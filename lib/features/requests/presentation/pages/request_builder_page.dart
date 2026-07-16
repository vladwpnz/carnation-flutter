import 'package:flutter/material.dart';
import 'package:motor_show/core/navigation/carnation_route.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/cars/domain/car.dart';
import 'package:motor_show/features/requests/application/request_builder_controller.dart';
import 'package:motor_show/features/requests/data/local_service_catalog.dart';
import 'package:motor_show/features/requests/domain/additional_service.dart';
import 'package:motor_show/features/requests/presentation/pages/request_confirmation_page.dart';

class RequestBuilderPage extends StatefulWidget {
  final Car car;
  final RequestBuilderController? controller;

  const RequestBuilderPage({
    super.key,
    required this.car,
    this.controller,
  });

  @override
  State<RequestBuilderPage> createState() => _RequestBuilderPageState();
}

class _RequestBuilderPageState extends State<RequestBuilderPage> {
  late final RequestBuilderController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        RequestBuilderController(basePrice: widget.car.price);
    _ownsController = widget.controller == null;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Build your request')),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SelectedVehicle(car: widget.car),
                          const SizedBox(height: 26),
                          const Text(
                            'Optional services',
                            style: TextStyle(
                              color: CarNationColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Choose only the services you want included in this estimate.',
                            style: TextStyle(
                              color: CarNationColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final service in localAdditionalServices) ...[
                            _ServiceOption(
                              service: service,
                              selected: _controller.contains(service.id),
                              onChanged: () => _controller.toggle(service),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 14),
                          _EstimateSummary(
                            car: widget.car,
                            servicesSubtotal: _controller.servicesSubtotal,
                            estimatedTotal: _controller.estimatedTotal,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const Key('submit-request'),
                              onPressed: _confirmAndSubmit,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Submit request'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This estimate is not a purchase or reservation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CarNationColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Submit this request?'),
          content: const Text(
            'This request is not a purchase. No payment will be processed and the vehicle will not be automatically reserved. A CarNation representative will contact you about the next steps.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Submit request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    Navigator.of(context).push(
      carNationRoute<void>(
        builder: (_) => RequestConfirmationPage(
          car: widget.car,
          selectedServices: List<AdditionalService>.of(
            _controller.selectedServices,
          ),
          estimatedTotal: _controller.estimatedTotal,
        ),
      ),
    );
  }
}

class _SelectedVehicle extends StatelessWidget {
  final Car car;

  const _SelectedVehicle({required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CarNationRadii.control),
              child: SizedBox(
                width: 112,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(car.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: const TextStyle(
                      color: CarNationColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Car.formatPrice(car.price),
                    style: const TextStyle(
                      color: CarNationColors.accentSoft,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Base vehicle price',
                    style: TextStyle(
                      color: CarNationColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  final AdditionalService service;
  final bool selected;
  final VoidCallback onChanged;

  const _ServiceOption({
    required this.service,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priceLabel = service.isFree
        ? 'Free'
        : Car.formatPrice(service.price);

    return Semantics(
      button: true,
      selected: selected,
      label: '${service.title}, $priceLabel',
      child: Material(
        color: selected
            ? CarNationColors.surfaceRaised
            : CarNationColors.surface,
        borderRadius: BorderRadius.circular(CarNationRadii.card),
        child: InkWell(
          key: Key('service-${service.id}'),
          onTap: onChanged,
          borderRadius: BorderRadius.circular(CarNationRadii.card),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CarNationRadii.card),
              border: Border.all(
                color: selected
                    ? CarNationColors.accent
                    : CarNationColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) => onChanged(),
                  semanticLabel: service.title,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service.title,
                              style: const TextStyle(
                                color: CarNationColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              color: CarNationColors.accentSoft,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        service.description,
                        style: const TextStyle(
                          color: CarNationColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 7),
                        const Text(
                          'Selected',
                          style: TextStyle(
                            color: CarNationColors.accentSoft,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstimateSummary extends StatelessWidget {
  final Car car;
  final int servicesSubtotal;
  final int estimatedTotal;

  const _EstimateSummary({
    required this.car,
    required this.servicesSubtotal,
    required this.estimatedTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CarNationColors.surface,
        borderRadius: BorderRadius.circular(CarNationRadii.card),
        border: Border.all(color: CarNationColors.border),
      ),
      child: Column(
        children: [
          _EstimateRow(
            label: 'Base vehicle price',
            value: Car.formatPrice(car.price),
          ),
          const SizedBox(height: 12),
          _EstimateRow(
            label: 'Services subtotal',
            value: Car.formatPrice(servicesSubtotal),
          ),
          const Divider(height: 28),
          _EstimateRow(
            label: 'Estimated total',
            value: Car.formatPrice(estimatedTotal),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _EstimateRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _EstimateRow({
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
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
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
              fontSize: emphasized ? 20 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

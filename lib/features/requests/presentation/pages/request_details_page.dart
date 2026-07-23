import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/cars/presentation/widgets/car_image.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/widgets/request_presentation_formatters.dart';
import 'package:carnation/features/requests/presentation/widgets/request_status_badge.dart';
import 'package:carnation/features/requests/presentation/widgets/request_status_timeline.dart';

class RequestDetailsPage extends StatefulWidget {
  final String requestId;
  final VehicleRequestRepository? requestRepository;

  const RequestDetailsPage({
    super.key,
    required this.requestId,
    this.requestRepository,
  });

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  late final VehicleRequestRepository _repository;
  late Stream<VehicleRequest?> _request;
  bool _isCancelling = false;
  bool _cancellationDialogOpen = false;
  String? _cancellationError;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.requestRepository ?? const FirestoreVehicleRequestRepository();
    _request = _watchRequestSafely();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(title: const Text('Request details')),
        body: SafeArea(
          top: false,
          child: StreamBuilder<VehicleRequest?>(
            stream: _request,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _DetailsErrorState(onRetry: _retry);
              }

              final request = snapshot.data;
              if (request == null) {
                return const _RequestNotFoundState();
              }

              return _buildDetails(request);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(VehicleRequest request) {
    return ListView(
      key: const Key('request-details-loaded'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RequestIdentityCard(request: request),
                const SizedBox(height: 16),
                _PriceAndServicesCard(request: request),
                const SizedBox(height: 16),
                _StatusTimelineCard(status: request.status),
                if (_cancellationError != null) ...[
                  const SizedBox(height: 14),
                  _ActionError(message: _cancellationError!),
                ],
                if (request.status == VehicleRequestStatus.submitted) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    key: const Key('cancel-request'),
                    onPressed: _isCancelling ? null : _confirmCancellation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CarNationColors.danger,
                      side: const BorderSide(color: CarNationColors.danger),
                    ),
                    icon: _isCancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: Text(
                      _isCancelling ? 'Cancelling...' : 'Cancel request',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Stream<VehicleRequest?> _watchRequestSafely() {
    try {
      return _repository.watchRequestById(widget.requestId);
    } catch (error, stackTrace) {
      return Stream<VehicleRequest?>.error(error, stackTrace);
    }
  }

  void _retry() {
    setState(() {
      _request = _watchRequestSafely();
    });
  }

  Future<void> _confirmCancellation() async {
    if (_isCancelling || _cancellationDialogOpen) {
      return;
    }

    _cancellationDialogOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel this request?'),
          content: const Text(
            'This action stops the request from being processed. The request will remain in your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep request'),
            ),
            FilledButton(
              key: const Key('confirm-cancel-request'),
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: CarNationColors.danger,
              ),
              child: const Text('Cancel request'),
            ),
          ],
        );
      },
    );
    _cancellationDialogOpen = false;

    if (confirmed != true || !mounted || _isCancelling) {
      return;
    }

    setState(() {
      _isCancelling = true;
      _cancellationError = null;
    });

    try {
      await _repository.cancelSubmittedRequest(widget.requestId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Request cancelled.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cancellationError = _readableError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  String _readableError(Object error) {
    if (error is VehicleRequestRepositoryException) {
      return error.message;
    }
    return 'The request could not be cancelled. Please try again.';
  }
}

class _RequestIdentityCard extends StatelessWidget {
  final VehicleRequest request;

  const _RequestIdentityCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CarNationRadii.control),
              child: AspectRatio(
                aspectRatio: 16 / 8,
                child: CarImage(
                  imagePath: request.car.imageAssetPath,
                  brand: inferCarImageBrand(
                    imagePath: request.car.imageAssetPath,
                    displayName: request.car.displayName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              request.car.displayName,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            RequestStatusBadge(status: request.status),
            const Divider(height: 28),
            _DetailRow(label: 'Request number', value: request.id),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Submitted',
              value: formatRequestDate(request.createdAt),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Contact email', value: request.contactEmail),
          ],
        ),
      ),
    );
  }
}

class _PriceAndServicesCard extends StatelessWidget {
  final VehicleRequest request;

  const _PriceAndServicesCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Estimate details',
              style: TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Base vehicle price',
              value: Car.formatPrice(request.car.basePrice),
            ),
            const Divider(height: 28),
            const Text(
              'Selected services',
              style: TextStyle(
                color: CarNationColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (request.selectedServices.isEmpty)
              const Text(
                'No additional services selected',
                style: TextStyle(color: CarNationColors.textMuted),
              )
            else
              for (final service in request.selectedServices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DetailRow(
                    label: service.title,
                    value: service.price == 0
                        ? 'Free'
                        : Car.formatPrice(service.price),
                  ),
                ),
            const Divider(height: 28),
            _DetailRow(
              label: 'Services subtotal',
              value: Car.formatPrice(request.servicesSubtotal),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Estimated total',
              value: Car.formatPrice(request.estimatedTotal),
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTimelineCard extends StatelessWidget {
  final VehicleRequestStatus status;

  const _StatusTimelineCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Status timeline',
              style: TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            RequestStatusTimeline(status: status),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _DetailRow({
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
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: SelectableText(
            value.isEmpty ? 'Unavailable' : value,
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

class _ActionError extends StatelessWidget {
  final String message;

  const _ActionError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('cancellation-error'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CarNationColors.warningSurface,
        borderRadius: BorderRadius.circular(CarNationRadii.control),
        border: Border.all(color: CarNationColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: CarNationColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _DetailsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: CarNationColors.warning,
            ),
            const SizedBox(height: 16),
            const Text(
              'Request details could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CarNationColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestNotFoundState extends StatelessWidget {
  const _RequestNotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'This request is unavailable or you no longer have access to it.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CarNationColors.textSecondary,
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

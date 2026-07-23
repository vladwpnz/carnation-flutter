import 'package:flutter/material.dart';
import 'package:carnation/core/navigation/carnation_route.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/cars/presentation/widgets/car_image.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/pages/request_details_page.dart';
import 'package:carnation/features/requests/presentation/widgets/request_presentation_formatters.dart';
import 'package:carnation/features/requests/presentation/widgets/request_status_badge.dart';

class MyRequestsPage extends StatefulWidget {
  final VehicleRequestRepository? requestRepository;

  const MyRequestsPage({super.key, this.requestRepository});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  late final VehicleRequestRepository _repository;
  late Stream<List<VehicleRequest>> _requests;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.requestRepository ?? const FirestoreVehicleRequestRepository();
    _requests = _watchRequestsSafely();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(title: const Text('My requests')),
        body: SafeArea(
          top: false,
          child: StreamBuilder<List<VehicleRequest>>(
            stream: _requests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _RequestsLoadingState();
              }

              if (snapshot.hasError) {
                return _RequestsErrorState(onRetry: _retry);
              }

              final requests = snapshot.data ?? const <VehicleRequest>[];
              if (requests.isEmpty) {
                return const _RequestsEmptyState();
              }

              return ListView.separated(
                key: const Key('my-requests-list'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _RequestCard(
                        request: request,
                        onViewDetails: () => _openDetails(request),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Stream<List<VehicleRequest>> _watchRequestsSafely() {
    try {
      return _repository.watchUserRequests();
    } catch (error, stackTrace) {
      return Stream<List<VehicleRequest>>.error(error, stackTrace);
    }
  }

  void _retry() {
    setState(() {
      _requests = _watchRequestsSafely();
    });
  }

  void _openDetails(VehicleRequest request) {
    Navigator.of(context).push(
      carNationRoute<void>(
        builder: (_) => RequestDetailsPage(
          requestId: request.id,
          requestRepository: _repository,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final VehicleRequest request;
  final VoidCallback onViewDetails;

  const _RequestCard({
    required this.request,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('request-card-${request.id}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(CarNationRadii.control),
                  child: SizedBox(
                    width: 108,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _RequestVehicleImage(
                        assetPath: request.car.imageAssetPath,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.car.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CarNationColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        request.shortDisplayId,
                        style: const TextStyle(
                          color: CarNationColors.accentSoft,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        formatRequestDate(request.createdAt),
                        style: const TextStyle(
                          color: CarNationColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                RequestStatusBadge(status: request.status),
                const Spacer(),
                Text(
                  Car.formatPrice(request.estimatedTotal),
                  style: const TextStyle(
                    color: CarNationColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: Key('view-request-${request.id}'),
              onPressed: onViewDetails,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestVehicleImage extends StatelessWidget {
  final String assetPath;

  const _RequestVehicleImage({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return CarImage(
      imagePath: assetPath,
      brand: inferCarImageBrand(imagePath: assetPath),
    );
  }
}

class _RequestsLoadingState extends StatelessWidget {
  const _RequestsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading vehicle requests',
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _RequestsEmptyState extends StatelessWidget {
  const _RequestsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('my-requests-empty'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 58,
                color: CarNationColors.accentSoft,
              ),
              SizedBox(height: 18),
              Text(
                'No requests yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CarNationColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 9),
              Text(
                'Submitted vehicle requests will appear here, along with their latest status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CarNationColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _RequestsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('my-requests-error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 54,
                color: CarNationColors.warning,
              ),
              const SizedBox(height: 16),
              const Text(
                'Requests could not be loaded',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CarNationColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Check your connection or Firestore access, then try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CarNationColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('retry-my-requests'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

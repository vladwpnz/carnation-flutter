import 'package:flutter/material.dart';
import 'package:carnation/core/navigation/carnation_route.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/data/local_car_catalog.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/cars/domain/car_catalog_query.dart';
import 'package:carnation/features/cars/presentation/pages/car_details_page.dart';
import 'package:carnation/features/cars/presentation/widgets/car_brand_filters.dart';
import 'package:carnation/features/cars/presentation/widgets/car_catalog_card.dart';
import 'package:carnation/features/cars/presentation/widgets/car_catalog_empty_state.dart';
import 'package:carnation/features/cars/presentation/widgets/car_filter_actions.dart';
import 'package:carnation/features/cars/presentation/widgets/car_filters_sheet.dart';
import 'package:carnation/features/cars/presentation/widgets/car_home_header.dart';
import 'package:carnation/features/cars/presentation/widgets/car_results_header.dart';
import 'package:carnation/features/cars/presentation/widgets/car_search_field.dart';
import 'package:carnation/features/compare/application/comparison_controller.dart';
import 'package:carnation/features/compare/presentation/pages/compare_page.dart';
import 'package:carnation/features/saved/application/saved_cars_controller.dart';
import 'package:carnation/features/saved/presentation/pages/saved_cars_page.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:carnation/features/user_auth/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final FirebaseAuthService _authService;
  final SavedCarsController? savedCarsController;
  final ComparisonController? comparisonController;

  const HomePage({
    super.key,
    FirebaseAuthService? authService,
    this.savedCarsController,
    this.comparisonController,
  }) : _authService = authService ?? const FirebaseAuthService();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  late final SavedCarsController _savedCarsController;
  late final ComparisonController _comparisonController;
  late final bool _ownsSavedCarsController;
  late final bool _ownsComparisonController;

  String _searchQuery = '';
  String? _selectedBrand;
  String? _selectedBodyType;
  String? _selectedFuelType;
  int? _minPrice;
  int? _maxPrice;
  CarSortOption _sortOption = CarSortOption.recommended;

  List<String> get _brands => _uniqueValues((car) => car.brand);
  List<String> get _bodyTypes => _uniqueValues((car) => car.bodyType);
  List<String> get _fuelTypes => _uniqueValues((car) => car.fuelType);

  List<Car> get _visibleCars {
    return applyCarCatalogueQuery(
      localCarCatalog,
      filters: CarCatalogueFilters(
        searchQuery: _searchQuery,
        brand: _selectedBrand,
        bodyType: _selectedBodyType,
        fuelType: _selectedFuelType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
      sortOption: _sortOption,
    );
  }

  bool get _hasActiveFilters {
    return _selectedBrand != null ||
        _selectedBodyType != null ||
        _selectedFuelType != null ||
        _minPrice != null ||
        _maxPrice != null;
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedBrand != null) {
      count += 1;
    }
    if (_selectedBodyType != null) {
      count += 1;
    }
    if (_selectedFuelType != null) {
      count += 1;
    }
    if (_minPrice != null || _maxPrice != null) {
      count += 1;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _savedCarsController = widget.savedCarsController ?? SavedCarsController();
    _comparisonController =
        widget.comparisonController ?? ComparisonController();
    _ownsSavedCarsController = widget.savedCarsController == null;
    _ownsComparisonController = widget.comparisonController == null;
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    if (_ownsSavedCarsController) {
      _savedCarsController.dispose();
    }
    if (_ownsComparisonController) {
      _comparisonController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCars = _visibleCars;

    return Theme(
      data: CarNationTheme.dark,
      child: AnimatedBuilder(
        animation: _savedCarsController,
        builder: (context, _) {
          return AnimatedBuilder(
            animation: _comparisonController,
            builder: (context, _) {
              return Scaffold(
                backgroundColor: CarNationColors.background,
                body: SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CarHomeHeader(
                                savedCarsController: _savedCarsController,
                                comparisonController: _comparisonController,
                                onSavedPressed: _openSavedCars,
                                onComparePressed: _openComparison,
                                onProfilePressed: _openProfile,
                                onLogoutPressed: () => _signOut(context),
                              ),
                              const SizedBox(height: 20),
                              CarSearchField(
                                controller: _searchController,
                                query: _searchQuery,
                              ),
                              const SizedBox(height: 16),
                              CarBrandFilters(
                                brands: _brands,
                                selectedBrand: _selectedBrand,
                                onSelected: _selectBrand,
                              ),
                              const SizedBox(height: 16),
                              CarFilterActions(
                                hasActiveFilters: _hasActiveFilters,
                                onOpenFilters: _openFilters,
                                onResetFilters: _resetFilters,
                              ),
                              const SizedBox(height: 18),
                              CarResultsHeader(
                                resultCount: visibleCars.length,
                                activeFilterCount: _activeFilterCount,
                                sortOption: _sortOption,
                                onSortChanged: _selectSortOption,
                              ),
                              const SizedBox(height: 12),
                              if (visibleCars.isEmpty)
                                CarCatalogEmptyState(
                                  onReset: _resetAllCatalogueControls,
                                )
                              else
                                for (final car in visibleCars) ...[
                                  CarCatalogCard(
                                    car: car,
                                    isSaved:
                                        _savedCarsController.contains(car.id),
                                    isCompared:
                                        _comparisonController.contains(car.id),
                                    onToggleSaved: () => _toggleSaved(car),
                                    onToggleComparison: () =>
                                        _toggleComparison(car),
                                    onViewDetails: () => _openCarDetails(car),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openFilters() async {
    final filters = await showCarFiltersSheet(
      context: context,
      initialFilters: CarCatalogueFilters(
        brand: _selectedBrand,
        bodyType: _selectedBodyType,
        fuelType: _selectedFuelType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
      brands: _brands,
      bodyTypes: _bodyTypes,
      fuelTypes: _fuelTypes,
    );

    if (filters == null || !mounted) {
      return;
    }

    setState(() {
      _selectedBrand = filters.brand;
      _selectedBodyType = filters.bodyType;
      _selectedFuelType = filters.fuelType;
      _minPrice = filters.minPrice;
      _maxPrice = filters.maxPrice;
    });
  }

  List<String> _uniqueValues(String Function(Car car) selector) {
    return localCarCatalog.map(selector).toSet().toList();
  }

  void _handleSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _selectBrand(String? brand) {
    setState(() {
      _selectedBrand = brand;
    });
  }

  void _selectSortOption(CarSortOption option) {
    setState(() {
      _sortOption = option;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _selectedBodyType = null;
      _selectedFuelType = null;
      _minPrice = null;
      _maxPrice = null;
    });
  }

  void _resetAllCatalogueControls() {
    setState(() {
      _selectedBrand = null;
      _selectedBodyType = null;
      _selectedFuelType = null;
      _minPrice = null;
      _maxPrice = null;
      _sortOption = CarSortOption.recommended;
    });
    _searchController.clear();
  }

  void _openProfile() {
    Navigator.push(
      context,
      carNationRoute<void>(builder: (_) => const ProfilePage()),
    );
  }

  void _openCarDetails(Car car) {
    Navigator.push(
      context,
      carNationRoute<void>(
        builder: (_) => CarDetailsPage(
          car: car,
          savedCarsController: _savedCarsController,
          comparisonController: _comparisonController,
        ),
      ),
    );
  }

  void _openSavedCars() {
    Navigator.push(
      context,
      carNationRoute<void>(
        builder: (_) => SavedCarsPage(
          savedCarsController: _savedCarsController,
          comparisonController: _comparisonController,
        ),
      ),
    );
  }

  void _openComparison() {
    Navigator.push(
      context,
      carNationRoute<void>(
        builder: (_) => ComparePage(
          comparisonController: _comparisonController,
        ),
      ),
    );
  }

  void _toggleSaved(Car car) {
    final saved = _savedCarsController.toggle(car);
    _showMessage(
      saved
          ? '${car.fullName} saved.'
          : '${car.fullName} removed from saved cars.',
    );
  }

  void _toggleComparison(Car car) {
    final result = _comparisonController.toggle(car);
    final message = switch (result) {
      ComparisonToggleResult.added => '${car.fullName} added to comparison.',
      ComparisonToggleResult.removed =>
        '${car.fullName} removed from comparison.',
      ComparisonToggleResult.limitReached =>
        'You can compare up to ${ComparisonController.maxVehicles} vehicles.',
    };
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await widget._authService.signOut();
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

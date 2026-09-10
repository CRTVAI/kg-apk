import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/container_list_response.dart';
import '../../models/global_search_response.dart';
import '../../models/pickup_request_response.dart';
import '../../models/vehicle_list_response.dart';
import '../car/car_details_screen.dart';
import '../container/container_details_screen.dart';
import '../styles/app_theme.dart';
import '../widgets/app_widgets.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (_homeController.globalSearchController.text.trim().length >= 2) {
      _homeController.globalSearch();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _homeController.globalSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Global search'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _homeController.globalSearchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: (_) => _homeController.globalSearch(),
                decoration: InputDecoration(
                  hintText: 'Search VIN, container, booking, pickup...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(
                    () => _homeController.kGlobalSearchLoading.isTrue
                        ? const Padding(
                            padding: EdgeInsets.all(13),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _homeController.globalSearchController.clear();
                              _homeController.globalSearchResults.value =
                                  GlobalSearchResults.empty();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final query =
                    _homeController.globalSearchController.text.trim();
                final results = _homeController.globalSearchResults.value;

                if (query.length < 2) {
                  return const _SearchEmptyState(
                    icon: Icons.manage_search_rounded,
                    title: 'Search everything',
                    message:
                        'Find vehicles, containers, bookings, VINs, and pickup requests from one place.',
                  );
                }

                if (_homeController.kGlobalSearchLoading.isTrue &&
                    results.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (results.isEmpty) {
                  return const _SearchEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No results found',
                    message:
                        'Try a VIN, container number, booking number, or pickup name.',
                  );
                }

                return ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _ResultSummary(total: results.totalCount),
                    if (results.vehicles.isNotEmpty)
                      _VehicleResults(vehicles: results.vehicles),
                    if (results.containers.isNotEmpty)
                      _ContainerResults(containers: results.containers),
                    if (results.pickupRequests.isNotEmpty)
                      _PickupResults(requests: results.pickupRequests),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.primary),
          const SizedBox(width: 7),
          Text(
            '$total results',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _VehicleResults extends StatelessWidget {
  const _VehicleResults({required this.vehicles});

  final List<VehicleList> vehicles;

  @override
  Widget build(BuildContext context) {
    return _ResultSection(
      icon: Icons.directions_car_outlined,
      title: 'Vehicles',
      count: vehicles.length,
      children: vehicles
          .map((item) => _SearchTile(
                icon: Icons.directions_car_rounded,
                title: _vehicleTitle(item.vehicle),
                subtitle: 'VIN ${_text(item.vehicle?.vin)}',
                meta: _text(item.vehicle?.status?.name, 'Vehicle'),
                onTap: () {
                  final controller = Get.find<VehicleController>();
                  controller.selectedPickupVehicle.value = item;
                  controller.vehicleImageList.assignAll(
                    item.vehicle?.vehicleImages ?? <VehicleImage>[],
                  );
                  controller.filterVehicleImageList();
                  Get.to(() => CarDetailsScreen(vehicleList: item));
                },
              ))
          .toList(),
    );
  }
}

class _ContainerResults extends StatelessWidget {
  const _ContainerResults({required this.containers});

  final List<Containers> containers;

  @override
  Widget build(BuildContext context) {
    return _ResultSection(
      icon: Icons.inventory_2_outlined,
      title: 'Containers',
      count: containers.length,
      children: containers
          .map((item) => _SearchTile(
                icon: Icons.inventory_2_rounded,
                title: _text(item.containerNo, 'Container #${item.id}'),
                subtitle: 'Booking ${_text(item.bookingNo)}',
                meta: _text(item.status?.name ?? item.statusName, 'Container'),
                onTap: () => Get.to(() => ContainerDetailsScreen(con: item)),
              ))
          .toList(),
    );
  }
}

class _PickupResults extends StatelessWidget {
  const _PickupResults({required this.requests});

  final List<PickupRequest> requests;

  @override
  Widget build(BuildContext context) {
    return _ResultSection(
      icon: Icons.local_shipping_outlined,
      title: 'Pickup requests',
      count: requests.length,
      children: requests
          .map((item) => _SearchTile(
                icon: Icons.local_shipping_rounded,
                title: _text(item.pickerName, 'Pickup request #${item.id}'),
                subtitle: 'VIN ${_text(item.vehicle?.vin)}',
                meta: _text(item.status, 'Waiting'),
                onTap: () => _showPickupDetails(context, item),
              ))
          .toList(),
    );
  }

  void _showPickupDetails(BuildContext context, PickupRequest request) {
    final date = request.createdAt == null
        ? 'Date unavailable'
        : DateFormat('MMM d, yyyy').format(request.createdAt!);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIconTile(icon: Icons.local_shipping_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pickup request #${request.id}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailLine(
                label: 'Status', value: _text(request.status, 'Waiting')),
            _DetailLine(label: 'Date', value: date),
            _DetailLine(label: 'VIN', value: _text(request.vehicle?.vin)),
            _DetailLine(label: 'Picker', value: _text(request.pickerName)),
            _DetailLine(label: 'Comments', value: _text(request.comments)),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.icon,
    required this.title,
    required this.count,
    required this.children,
  });

  final IconData icon;
  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Text('$count', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              AppIconTile(icon: icon, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 92),
                child: AppStatusBadge(label: meta, color: AppTheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: AppTheme.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 38),
            ),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _vehicleTitle(Vehicle? vehicle) {
  final parts = [
    _text(vehicle?.modal, ''),
    _text(vehicle?.companyName, ''),
    _text(vehicle?.name, ''),
  ].where((value) => value.isNotEmpty).toList();
  return parts.isEmpty ? 'Vehicle' : parts.join(' ');
}

String _text(dynamic value, [String fallback = '-']) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
}

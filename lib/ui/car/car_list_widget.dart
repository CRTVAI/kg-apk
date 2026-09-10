import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle_list_response.dart';
import '../styles/app_theme.dart';
import 'car_details_screen.dart';

class MyCarScreen extends StatefulWidget {
  const MyCarScreen({super.key});

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen> {
  final VehicleController _controller = Get.find<VehicleController>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _showPageLoader = false;

  @override
  void initState() {
    super.initState();
    _controller.getVehicleFilters();
    _controller.getVehicleList(
      isRefresh: true,
      tabIndex: _controller.selectedTabIndex.value,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool showPageLoader = true}) async {
    if (showPageLoader && mounted) {
      setState(() => _showPageLoader = true);
    }
    try {
      await _controller.refreshVehicleListNow(
        refreshController: _refreshController,
        tabIndex: _controller.selectedTabIndex.value,
      );
    } finally {
      if (showPageLoader && mounted) {
        setState(() => _showPageLoader = false);
      }
    }
  }

  String _text(dynamic value, [String fallback = '-']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? fallback : result;
  }

  void _openVehicle(VehicleList vehicleList) {
    final vehicle = vehicleList.vehicle;
    if (vehicle == null) return;
    _controller.selectedPickupVehicle.value = vehicleList;
    _controller.vehicleImageList.assignAll(
      vehicle.vehicleImages ?? <VehicleImage>[],
    );
    _controller.filterVehicleImageList();
    Get.to(() => CarDetailsScreen(vehicleList: vehicleList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My vehicles'),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _showFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Refresh vehicles',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Column(
                children: [
                  TextField(
                    controller: _controller.searchStringController,
                    textInputAction: TextInputAction.search,
                    onChanged: _controller.onChangeHandler,
                    onSubmitted: (_) => _controller.searchByVin(),
                    decoration: InputDecoration(
                      hintText: 'Search by VIN',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        tooltip: 'Search',
                        onPressed: _controller.searchByVin,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActiveFilterBar(
                    count: _activeFilterCount,
                    onClear: () {
                      setState(() {
                        _controller.clearVehicleSearchAndFilters();
                        _controller.selectedTabIndex.value = 0;
                      });
                      _refresh();
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _controller.tabOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final selected =
                              _controller.selectedTabIndex.value == index;
                          return ChoiceChip(
                            selected: selected,
                            avatar: selected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                            label: Text(_controller.tabOptions[index]),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: selected ? Colors.white : AppTheme.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.surface,
                            side: BorderSide(
                              color:
                                  selected ? AppTheme.primary : AppTheme.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            onSelected: (_) {
                              _controller.clearVehicleSearchAndFilters();
                              _controller.selectedTabIndex.value = index;
                              _controller.getVehicleList(
                                isRefresh: true,
                                tabIndex: index,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  Obx(() {
                    if (_controller.kLoadingVehicle.isTrue &&
                        _controller.filterVehicleList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_controller.filterVehicleList.isEmpty) {
                      return _EmptyVehicleList(onRefresh: _refresh);
                    }
                    return SmartRefresher(
                      controller: _refreshController,
                      enablePullUp: true,
                      header: const WaterDropHeader(),
                      onRefresh: () => _refresh(showPageLoader: false),
                      onLoading: () => _controller.loadMoreVehicle(
                        _refreshController,
                        _controller.selectedTabIndex.value,
                      ),
                      child: ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _controller.filterVehicleList.length,
                        itemBuilder: (_, index) {
                          final VehicleList item =
                              _controller.filterVehicleList[index];
                          final vehicle = item.vehicle;
                          if (vehicle == null) return const SizedBox.shrink();
                          final title = [
                            vehicle.modal,
                            vehicle.companyName,
                            vehicle.name,
                          ]
                              .map((value) => _text(value, ''))
                              .where((value) => value.isNotEmpty)
                              .join(' ');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => _openVehicle(item),
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.primarySoft,
                                child: Icon(
                                  Icons.directions_car_outlined,
                                  color: AppTheme.primary,
                                ),
                              ),
                              title: Text(
                                title.isEmpty ? 'Vehicle' : title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lot: ${_text(vehicle.lotnumber)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'VIN: ${_text(vehicle.vin)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Terminal: ${_text(vehicle.terminal?.name)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  if (_showPageLoader) const _VehiclePageLoader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _activeFilterCount {
    var count = 0;
    if (_controller.selectedFilterBuyer.value != null) count++;
    if (_controller.selectedFilterTerminal.value != null) count++;
    if (_controller.selectedFilterDestination.value != null) count++;
    if (_controller.selectedFilterPayment.value != null) count++;
    if (_controller.selectedFilterFuel.value != null) count++;
    if (_controller.selectedFilterStatus.value != null) count++;
    if (_controller.selectedTabIndex.value != 0) count++;
    if (_controller.purchaseFromController.text.trim().isNotEmpty) count++;
    if (_controller.purchaseToController.text.trim().isNotEmpty) count++;
    if (_controller.deliveryFromController.text.trim().isNotEmpty) count++;
    if (_controller.deliveryToController.text.trim().isNotEmpty) count++;
    return count;
  }

  List<dynamic> _options(String key) {
    final value = _controller.vehicleFilterOptions[key];
    return value is List ? value : <dynamic>[];
  }

  String _label(dynamic option) {
    if (option is Map) {
      return (option['name'] ?? option['label'] ?? option['value'] ?? '')
          .toString();
    }
    return option?.toString() ?? '';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (selected == null) return;
    controller.text =
        '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Vehicle filters',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FilterDropdown(
                    label: 'Sub-user',
                    value: _controller.selectedFilterBuyer.value,
                    options: _options('sub_users'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterBuyer.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Terminal',
                    value: _controller.selectedFilterTerminal.value,
                    options: _options('terminals'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterTerminal.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Destination',
                    value: _controller.selectedFilterDestination.value,
                    options: _options('destinations'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterDestination.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Payment',
                    value: _controller.selectedFilterPayment.value,
                    options: _options('payment_statuses'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterPayment.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Fuel',
                    value: _controller.selectedFilterFuel.value,
                    options: _options('fuel_types'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterFuel.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Status',
                    value: _controller.selectedFilterStatus.value,
                    options: _options('statuses'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterStatus.value = value,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Purchase from',
                          controller: _controller.purchaseFromController,
                          onTap: () =>
                              _pickDate(_controller.purchaseFromController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'Purchase to',
                          controller: _controller.purchaseToController,
                          onTap: () =>
                              _pickDate(_controller.purchaseToController),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Delivery from',
                          controller: _controller.deliveryFromController,
                          onTap: () =>
                              _pickDate(_controller.deliveryFromController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'Delivery to',
                          controller: _controller.deliveryToController,
                          onTap: () =>
                              _pickDate(_controller.deliveryToController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _controller.clearVehicleSearchAndFilters();
                              _controller.selectedTabIndex.value = 0;
                            });
                            _refresh();
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _controller.selectedTabIndex.value = 0;
                            });
                            _refresh();
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({required this.count, required this.onClear});

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count filter${count == 1 ? '' : 's'} active',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('Clear'),
        ),
      ],
    );
  }
}

class _VehiclePageLoader extends StatelessWidget {
  const _VehiclePageLoader();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: AppTheme.canvas.withOpacity(0.72),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading vehicles',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final dynamic value;
  final List<dynamic> options;
  final String Function(dynamic) labelFor;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<dynamic>(
        value: value,
        isExpanded: true,
        items: options
            .map(
              (option) => DropdownMenuItem<dynamic>(
                value: option,
                child: Text(
                  labelFor(option),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.filter_alt_outlined),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear date',
                  onPressed: controller.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

class _EmptyVehicleList extends StatelessWidget {
  const _EmptyVehicleList({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EEF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No vehicles found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Try another status or search with a different VIN.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

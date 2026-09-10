import 'package:cargo/controllers/container_controller.dart';
import 'package:cargo/models/container_list_response.dart';
import 'package:cargo/ui/container/container_details_screen.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContainerScreen extends StatefulWidget {
  const ContainerScreen({super.key});

  @override
  State<ContainerScreen> createState() => _ContainerScreenState();
}

class _ContainerScreenState extends State<ContainerScreen> {
  final ContainerController _containerController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _containerController.getContainerFilters();
    _containerController.getContainerList(isRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _copyValue(String value, String label) async {
    if (value == '—') return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Containers'),
          actions: [
            IconButton(
              tooltip: 'Filters',
              onPressed: _showFilters,
              icon: const Icon(Icons.tune_rounded),
            ),
            IconButton(
              tooltip: 'Refresh containers',
              onPressed: () =>
                  _containerController.getContainerList(isRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _containerController.searchStringController,
                  onChanged: _containerController.onChangeHandler,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _containerController.searchByContainer(),
                  decoration: InputDecoration(
                    hintText: 'Search by container number',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      onPressed: _containerController.searchByContainer,
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
                    setState(_containerController.clearAdvancedFilters);
                    _containerController.getContainerList(isRefresh: true);
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Container list',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_containerController.filterContainerList.length}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.primary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (_containerController.kIsLoading.isTrue) {
                      return Center(child: getLoading());
                    }

                    final containers = _containerController.filterContainerList;
                    if (containers.isEmpty) {
                      return _EmptyContainerState(
                        onRefresh: () => _containerController.getContainerList(
                          isRefresh: true,
                        ),
                      );
                    }

                    return SmartRefresher(
                      header: const WaterDropHeader(
                        waterDropColor: AppTheme.primary,
                      ),
                      controller: _refreshController,
                      enablePullUp: true,
                      onRefresh: () => _containerController.refreshContainer(
                        _refreshController,
                      ),
                      onLoading: () => _containerController.loadMoreContainer(
                        _refreshController,
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: containers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final container = containers[index];
                          return _ContainerCard(
                            container: container,
                            onOpen: () => Get.to(
                              () => ContainerDetailsScreen(con: container),
                            ),
                            onTrack: () {
                              final shippingLine =
                                  container.shippingLine?.name ??
                                      container.shippingLineName ??
                                      '';
                              final containerNo = container.containerNo ?? '';
                              _containerController.trackContainer(
                                shippingLine.toString(),
                                containerNo.toString(),
                              );
                            },
                            onCopy: _copyValue,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int get _activeFilterCount {
    var count = 0;
    if (_containerController.selectedFilterPort.value != null) count++;
    if (_containerController.selectedFilterStatus.value != null) count++;
    if (_containerController.selectedFilterPayment.value != null) count++;
    return count;
  }

  List<dynamic> _options(String key) {
    final value = _containerController.containerFilterOptions[key];
    return value is List ? value : <dynamic>[];
  }

  String _label(dynamic option) {
    if (option is Map) {
      return (option['name'] ?? option['label'] ?? option['value'] ?? '')
          .toString();
    }
    return option?.toString() ?? '';
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
                        'Container filters',
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
                    label: 'Port',
                    allLabel: 'All Ports',
                    value: _containerController.selectedFilterPort.value,
                    options: _options('ports'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () =>
                          _containerController.selectedFilterPort.value = value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Status',
                    allLabel: 'All Statuses',
                    value: _containerController.selectedFilterStatus.value,
                    options: _options('statuses'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _containerController.selectedFilterStatus.value =
                          value,
                    ),
                  ),
                  _FilterDropdown(
                    label: 'Payment',
                    allLabel: 'All',
                    value: _containerController.selectedFilterPayment.value,
                    options: _options('payment_statuses'),
                    labelFor: _label,
                    onChanged: (value) => setSheetState(
                      () => _containerController.selectedFilterPayment.value =
                          value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(_containerController.clearAdvancedFilters);
                            _containerController.getContainerList(
                                isRefresh: true);
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
                            setState(() {});
                            _containerController.getContainerList(
                                isRefresh: true);
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.allLabel,
    required this.value,
    required this.options,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final String allLabel;
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
        items: [
          DropdownMenuItem<dynamic>(
            value: null,
            child: Text(allLabel, overflow: TextOverflow.ellipsis),
          ),
          ...options.map(
            (option) => DropdownMenuItem<dynamic>(
              value: option,
              child: Text(labelFor(option), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.filter_alt_outlined),
        ),
      ),
    );
  }
}

class _ContainerCard extends StatefulWidget {
  final Containers container;
  final VoidCallback onOpen;
  final VoidCallback onTrack;
  final Future<void> Function(String value, String label) onCopy;

  const _ContainerCard({
    required this.container,
    required this.onOpen,
    required this.onTrack,
    required this.onCopy,
  });

  @override
  State<_ContainerCard> createState() => _ContainerCardState();
}

class _ContainerCardState extends State<_ContainerCard> {
  bool _showMore = false;

  String _value(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? '-' : result;
  }

  String get _shippingLine {
    final relationName = _value(widget.container.shippingLine?.name);
    if (relationName != '-') return relationName;
    return _value(widget.container.shippingLineName);
  }

  String _date(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return DateFormat('MMM dd, yyyy').format(value);
    final text = value.toString();
    if (text.isEmpty || text == '0000-00-00') return '-';
    final parsed = DateTime.tryParse(text);
    return parsed == null
        ? _value(value)
        : DateFormat('MMM dd, yyyy').format(parsed);
  }

  String get _status =>
      _value(widget.container.status?.name ?? widget.container.statusName);

  String get _payment {
    final paid = widget.container.allPaid?.toString();
    if (paid == '1' || paid == 'true') return 'Paid';
    if (paid == '0' || paid == 'false') return 'Unpaid';
    return '-';
  }

  Color get _paymentColor =>
      _payment == 'Paid' ? AppTheme.success : AppTheme.warning;

  String _vehicleDescription(VehicleElement item) {
    final vehicle = item.vehicle;
    if (vehicle == null) return 'Vehicle information unavailable';
    final parts = [
      _value(vehicle.modal),
      _value(vehicle.companyName),
      _value(vehicle.name),
    ].where((value) => value != '-').toList();
    return parts.isEmpty ? 'Vehicle information unavailable' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.container.vehicles ?? <VehicleElement>[];
    final booking = _value(widget.container.bookingNo);
    final containerNumber = _value(widget.container.containerNo);
    final destination = _value(widget.container.destinationPort?.name ??
        widget.container.destinationPortName);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            containerNumber == '-'
                                ? 'Container'
                                : 'Container $containerNumber',
                            overflow: TextOverflow.visible,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_boat_filled_rounded,
                                size: 14,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _shippingLine,
                                  overflow: TextOverflow.visible,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.muted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(
                      label: _status,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AssignedVehiclesBox(
                  vehicles: vehicles,
                  value: _value,
                  vehicleDescription: _vehicleDescription,
                  onCopyVin: (vin) => widget.onCopy(vin, 'VIN'),
                ),
                const SizedBox(height: 12),
                _ContainerExpandToggle(
                  isExpanded: _showMore,
                  onTap: () => setState(() => _showMore = !_showMore),
                ),
                if (_showMore) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ContainerCopyField(
                          label: 'CONTAINER NO.',
                          value: containerNumber,
                          icon: Icons.tag_rounded,
                          onTap: () => widget.onCopy(
                              containerNumber, 'Container number'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ContainerCopyField(
                          label: 'BOOKING NO.',
                          value: booking,
                          icon: Icons.confirmation_number_outlined,
                          onTap: () => widget.onCopy(booking, 'Booking number'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ContainerInfoGrid(
                    children: [
                      _ContainerDataPill(
                        icon: Icons.flight_takeoff_rounded,
                        label: 'ETD (Departure)',
                        value: _date(widget.container.departure),
                      ),
                      _ContainerDataPill(
                        icon: Icons.flight_land_rounded,
                        label: 'ETA (Arrival)',
                        value: _date(widget.container.arrival),
                      ),
                      _ContainerDataPill(
                        icon: Icons.anchor_rounded,
                        label: 'Destination',
                        value: destination,
                      ),
                      _ContainerDataPill(
                        icon: Icons.credit_card_rounded,
                        label: 'Payment Status',
                        value: _payment,
                        valueColor: _paymentColor,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onOpen,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 17),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onTrack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.location_on_outlined, size: 17),
                        label: const Text('Track Cargo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignedVehiclesBox extends StatelessWidget {
  const _AssignedVehiclesBox({
    required this.vehicles,
    required this.value,
    required this.vehicleDescription,
    required this.onCopyVin,
  });

  final List<VehicleElement> vehicles;
  final String Function(dynamic value) value;
  final String Function(VehicleElement item) vehicleDescription;
  final void Function(String vin) onCopyVin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                size: 15,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Assigned Vehicles (${vehicles.length})',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vehicles.isEmpty)
            Text(
              'No assigned vehicles',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            )
          else
            ...vehicles.map(
              (item) {
                final vin = value(item.vehicle?.vin);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _AssignedVehicleRow(
                    description: vehicleDescription(item),
                    vin: vin,
                    onCopyVin: onCopyVin,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AssignedVehicleRow extends StatelessWidget {
  const _AssignedVehicleRow({
    required this.description,
    required this.vin,
    required this.onCopyVin,
  });

  final String description;
  final String vin;
  final void Function(String vin) onCopyVin;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 3),
              Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onCopyVin(vin),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'VIN',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                    fontSize: 9.5,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vin,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                  fontSize: 10.5,
                                  height: 1.15,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContainerExpandToggle extends StatelessWidget {
  const _ContainerExpandToggle({
    required this.isExpanded,
    required this.onTap,
  });

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isExpanded ? 'Hide info' : 'Show more',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 6),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  Color get _badgeColor {
    final lower = label.toLowerCase();
    if (lower.contains('shipped') || lower.contains('delivered')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('loaded') || lower.contains('booked')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('terminal') || lower.contains('gate')) {
      return const Color(0xFFD97706);
    }
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    return Container(
      constraints: const BoxConstraints(maxWidth: 115),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _ContainerCopyField extends StatelessWidget {
  const _ContainerCopyField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: AppTheme.primary.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContainerInfoGrid extends StatelessWidget {
  const _ContainerInfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ContainerDataPill extends StatelessWidget {
  const _ContainerDataPill({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, size: 14, color: AppTheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: valueColor ?? AppTheme.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyContainerState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyContainerState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 32,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No containers found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Try another container number or refresh the list.',
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

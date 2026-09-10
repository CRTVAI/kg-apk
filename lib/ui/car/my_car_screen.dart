import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controllers/user_controller.dart';
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
  final UserController _userController = Get.find<UserController>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final Set<String> _expandedVehicleCards = <String>{};
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

  Future<void> _refresh() => _controller.refreshVehicleListNow(
        refreshController: _refreshController,
        tabIndex: _controller.selectedTabIndex.value,
      );

  Future<void> _reloadVehicles({bool showPageLoader = true}) async {
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

  Future<void> _showAllVehicles() async {
    _controller.clearVehicleSearchAndFilters();
    _controller.selectedTabIndex.value = 0;
    setState(() {});
    await _reloadVehicles();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  String _text(dynamic value, [String fallback = '-']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? fallback : result;
  }

  String _date(dynamic value) {
    final text = _text(value, '');
    if (text.isEmpty || text == '0000-00-00') return '-';
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;
    return '${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}-${parsed.year}';
  }

  String _availability(dynamic value) {
    final text = _text(value, '').toLowerCase();
    return text.isNotEmpty && text != 'no' && text != '0' && text != 'false'
        ? 'Yes'
        : 'No';
  }

  String? _vehicleImageUrl(Vehicle vehicle) {
    final images = vehicle.vehicleImages ?? <VehicleImage>[];
    if (images.isEmpty) return null;
    final filename = _text(images.first.filename, '');
    if (filename.isEmpty) return null;
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    final filepath = _text(images.first.filepath, '');
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$filepath$filename';
  }

  Future<void> _copyValue(String label, dynamic value) async {
    final copiedValue = _text(value, '');
    if (copiedValue.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: copiedValue));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copied'),
          duration: const Duration(seconds: 1),
        ),
      );
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

  Future<bool> _confirmRemoveAssignedUser(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove assigned user?'),
        content: Text('Remove $name from this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _showAssignedUsersSheet(VehicleList item) {
    final assignments = List<VehicleSubUserAssignment>.from(
      item.subUsers ?? <VehicleSubUserAssignment>[],
    );
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppTheme.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) => FractionallySizedBox(
            heightFactor: .62,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.group_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned users',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${assignments.length} user${assignments.length == 1 ? '' : 's'} assigned to this vehicle',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.muted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: assignments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Text(
                              'No assigned users found for this vehicle.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: assignments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final assignment = assignments[index];
                            final user = assignment.user;
                            final name = _text(
                              user?.surname,
                              _text(user?.name, 'Unnamed user'),
                            );

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primarySoft,
                                  foregroundColor: AppTheme.primary,
                                  child:
                                      Text(name.substring(0, 1).toUpperCase()),
                                ),
                                title: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                trailing: IconButton.filledTonal(
                                  tooltip: 'Remove assigned user',
                                  onPressed: () async {
                                    final confirmed =
                                        await _confirmRemoveAssignedUser(name);
                                    if (!confirmed) return;
                                    final removed = await _userController
                                        .removeUserFromVehicle(assignment.id);
                                    if (!removed) return;
                                    setSheetState(() {
                                      assignments.removeWhere(
                                        (value) => value.id == assignment.id,
                                      );
                                      item.subUsers = assignments;
                                    });
                                    _controller
                                        .selectedPickupVehicle.value?.subUsers
                                        ?.removeWhere(
                                      (value) => value.id == assignment.id,
                                    );
                                    _controller.selectedPickupVehicle.refresh();
                                    await _reloadVehicles(
                                        showPageLoader: false);
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            onPressed: _reloadVehicles,
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
                      _reloadVehicles();
                    },
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
                      return _EmptyVehicleList(
                        currentStatus: _controller
                            .tabOptions[_controller.selectedTabIndex.value],
                        onRefresh: _reloadVehicles,
                        onShowAll: _showAllVehicles,
                      );
                    }
                    return SmartRefresher(
                      controller: _refreshController,
                      enablePullUp: _controller.kVehicleHasMore.isTrue,
                      header: const WaterDropHeader(),
                      footer: const ClassicFooter(),
                      onRefresh: _refresh,
                      onLoading: () => _controller.loadMoreVehicle(
                        _refreshController,
                        _controller.selectedTabIndex.value,
                      ),
                      child: ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _controller.filterVehicleList.length,
                        itemBuilder: (_, index) => _buildVehicleListItem(
                            _controller.filterVehicleList[index]),
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

  Widget _buildVehicleListItem(VehicleList item) {
    try {
      final vehicle = item.vehicle;
      if (vehicle == null) return const SizedBox.shrink();
      final status = _text(vehicle.status?.name, 'New');
      final title = [
        vehicle.modal,
        vehicle.companyName,
        vehicle.name,
      ]
          .map((value) => _text(value, ''))
          .where((value) => value.isNotEmpty)
          .join(' ');
      final destination = _text(
        vehicle.destinationPort?.name ?? vehicle.destinationManual,
      );
      final imageUrl = _vehicleImageUrl(vehicle);
      final titleAvail = _availability(vehicle.title);
      final keysAvail = _availability(vehicle.keys);
      final fuelType = _text(vehicle.fuelType);
      final purchaseDate = _date(vehicle.purchaseDate);
      final deliveryDate = _date(vehicle.deliveredOnDate);
      final assignedUsersCount = item.subUsers?.length ?? 0;
      final cardKey = item.id.toString();
      final expanded = _expandedVehicleCards.contains(cardKey);

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
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
              onTap: () => _openVehicle(item),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.12),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 74,
                              height: 74,
                              child: imageUrl == null
                                  ? const _VehicleImageFallback()
                                  : CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          const _VehicleImageFallback(),
                                      errorWidget: (_, __, ___) =>
                                          const _VehicleImageFallback(),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.isEmpty ? 'Vehicle' : title,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_outlined,
                                    size: 13,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      destination,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.muted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _DateLine(
                                    icon: Icons.event_outlined,
                                    value: purchaseDate,
                                  ),
                                  if (deliveryDate != '-') ...[
                                    const SizedBox(height: 2),
                                    _DateLine(
                                      icon: Icons.local_shipping_outlined,
                                      value: deliveryDate,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 88,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _SmallStatusBadge(label: status),
                              const SizedBox(height: 8),
                              _DetailsPill(onTap: () => _openVehicle(item)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _VehicleInfoBox(
                            label: 'VIN',
                            value: _text(vehicle.vin),
                            icon: Icons.fingerprint_rounded,
                            onCopy: () => _copyValue('VIN', vehicle.vin),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _AssignedUsersPill(
                          count: assignedUsersCount,
                          onTap: () => _showAssignedUsersSheet(item),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          if (expanded) {
                            _expandedVehicleCards.remove(cardKey);
                          } else {
                            _expandedVehicleCards.add(cardKey);
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              expanded ? 'Hide info' : 'Show info',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              expanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Column(
                        children: [
                          const SizedBox(height: 8),
                          _VehicleInfoBox(
                            label: 'LOT NUMBER',
                            value: _text(vehicle.lotnumber),
                            icon: Icons.tag_rounded,
                            onCopy: () =>
                                _copyValue('LOT number', vehicle.lotnumber),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _SpecTile(
                                  icon: Icons.description_outlined,
                                  label: 'Title',
                                  value: titleAvail,
                                  isPositive: titleAvail == 'Yes',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SpecTile(
                                  icon: Icons.key_rounded,
                                  label: 'Keys',
                                  value: keysAvail,
                                  isPositive: keysAvail == 'Yes',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _VehicleInfoBox(
                            label: 'FUEL',
                            value: fuelType,
                            icon: Icons.local_gas_station_outlined,
                          ),
                        ],
                      ),
                      crossFadeState: expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (_) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: AppTheme.danger),
          title: Text('Vehicle #${item.id}'),
          subtitle: const Text('Unable to display full vehicle data'),
        ),
      );
    }
  }

  int get _activeFilterCount {
    var count = 0;
    if (_controller.selectedFilterBuyer.value != null) count++;
    if (_controller.selectedFilterTerminal.value != null) count++;
    if (_controller.selectedFilterDestination.value != null) count++;
    if (_controller.selectedFilterFuel.value != null) count++;
    if (_controller.selectedFilterStatus.value != null) count++;
    if (_controller.selectedTabIndex.value != 0) count++;
    if (_controller.selectedFilterYear.value != null) count++;
    if (_controller.selectedFilterMake.value != null) count++;
    if (_controller.selectedFilterModel.value != null) count++;
    if (_controller.purchaseFromController.text.trim().isNotEmpty) count++;
    if (_controller.purchaseToController.text.trim().isNotEmpty) count++;
    return count;
  }

  List<dynamic> _options(String key) {
    final value = _controller.vehicleFilterOptions[key];
    return value is List ? value : <dynamic>[];
  }

  List<dynamic> _filterOptions(List<String> keys, Iterable<dynamic> fallback) {
    for (final key in keys) {
      final options = _options(key);
      if (options.isNotEmpty) return options;
    }
    final values = fallback
        .map((value) => _text(value, ''))
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
    return values;
  }

  dynamic _dropdownValue(List<dynamic> options, dynamic value) {
    if (value == null) return null;
    return options.contains(value) ? value : null;
  }

  List<dynamic> get _yearOptions => _filterOptions(
        const ['years', 'year_options', 'vehicle_years'],
        _controller.vehicleList.map((item) => item.vehicle?.modal),
      );

  List<dynamic> get _makeOptions => _filterOptions(
        const ['makes', 'make_options', 'vehicle_makes', 'companies'],
        _controller.vehicleList.map((item) => item.vehicle?.companyName),
      );

  int? _brandId(dynamic option) {
    if (option is Map) {
      final raw = option['brand_id'] ?? option['vehicle_brand_id'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    }
    return null;
  }

  List<dynamic> get _modelOptions {
    final selectedMake = _controller.selectedFilterMake.value;
    final selectedBrandId = _brandId(selectedMake);
    final allModels = _filterOptions(
      const ['models', 'model_options', 'vehicle_models'],
      _controller.vehicleList.map((item) => item.vehicle?.name),
    );
    if (selectedBrandId == null) {
      return <dynamic>[];
    }
    return allModels
        .where((model) => _brandId(model) == selectedBrandId)
        .toList();
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
                        child: _FilterDropdown(
                          label: 'Year',
                          value: _dropdownValue(
                            _yearOptions,
                            _controller.selectedFilterYear.value,
                          ),
                          options: _yearOptions,
                          labelFor: _label,
                          onChanged: (value) => setSheetState(
                            () => _controller.selectedFilterYear.value = value,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Make',
                          value: _dropdownValue(
                            _makeOptions,
                            _controller.selectedFilterMake.value,
                          ),
                          options: _makeOptions,
                          labelFor: _label,
                          onChanged: (value) => setSheetState(() {
                            _controller.selectedFilterMake.value = value;
                            _controller.selectedFilterModel.value = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                  _FilterDropdown(
                    label: 'Model',
                    value: _dropdownValue(
                      _modelOptions,
                      _controller.selectedFilterModel.value,
                    ),
                    options: _modelOptions,
                    labelFor: _label,
                    enabled: _controller.selectedFilterMake.value != null,
                    onChanged: (value) => setSheetState(
                      () => _controller.selectedFilterModel.value = value,
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
                            _reloadVehicles();
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
                            _reloadVehicles();
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

class _SmallStatusBadge extends StatelessWidget {
  const _SmallStatusBadge({required this.label});

  final String label;

  Color get _badgeColor {
    final lower = label.toLowerCase();
    if (lower.contains('shipped') || lower.contains('delivered')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('loaded') || lower.contains('booked')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('terminal')) {
      return const Color(0xFFD97706);
    }
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    return Container(
      constraints: const BoxConstraints(maxWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9.5,
            ),
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppTheme.muted,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.muted,
                  fontSize: 10,
                ),
          ),
        ),
      ],
    );
  }
}

class _VehicleInfoBox extends StatelessWidget {
  const _VehicleInfoBox({
    required this.label,
    required this.value,
    this.icon,
    this.onCopy,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
              ],
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
              if (onCopy != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppTheme.primary.withOpacity(0.8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsPill extends StatelessWidget {
  const _DetailsPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 14,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedUsersPill extends StatelessWidget {
  const _AssignedUsersPill({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_outlined,
              size: 15,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 5),
            Text(
              '$count assigned',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isPositive,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    Color effectiveColor;
    if (isPositive == true) {
      effectiveColor = const Color(0xFF059669);
    } else if (isPositive == false) {
      effectiveColor = const Color(0xFFD97706);
    } else {
      effectiveColor = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: effectiveColor.withOpacity(0.18), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: effectiveColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
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
                        color: effectiveColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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

class _VehicleImageFallback extends StatelessWidget {
  const _VehicleImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primarySoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_car_filled_outlined,
        color: AppTheme.primary,
        size: 28,
      ),
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
    this.enabled = true,
  });

  final String label;
  final dynamic value;
  final List<dynamic> options;
  final String Function(dynamic) labelFor;
  final ValueChanged<dynamic> onChanged;
  final bool enabled;

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
        onChanged: enabled ? onChanged : null,
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
  const _EmptyVehicleList({
    required this.currentStatus,
    required this.onRefresh,
    required this.onShowAll,
  });

  final String currentStatus;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onShowAll;

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
              currentStatus == 'All Vehicle'
                  ? 'Try another search or refresh the list.'
                  : 'No vehicles found for $currentStatus. You can refresh this status or show all vehicles.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                ),
                if (currentStatus != 'All Vehicle') ...[
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onShowAll,
                    icon: const Icon(Icons.directions_car_rounded),
                    label: const Text('Show all'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

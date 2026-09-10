import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/destination_port_response.dart';
import 'package:cargo/models/pickup_request_response.dart';
import 'package:cargo/models/vehicle_list_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/ui/widgets/app_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen> {
  final VehicleController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    _controller.pickupHistorySearchController.clear();
    _controller.pickupHistoryStatus.value = 'all';
    _controller.pickupHistoryDestination.value = null;
    _controller.getPickupHistory(resetPage: true);
    _controller.getPickupEligibleVehicles();
    _controller.getPickupPreference();
  }

  String _assetUrl(String? file) {
    final value = file?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$value';
  }

  String _previousPickupLabel(Map<String, dynamic> option) {
    final name = option['picker_name']?.toString().trim() ?? '';
    final type = option['type']?.toString().trim() ??
        option['request_type']?.toString().trim() ??
        '';
    final comments = option['comments']?.toString().trim() ?? '';
    final hasDocument = option['has_document'] == true ||
        (option['document']?.toString().trim().isNotEmpty ?? false);
    final label = [
      name.isEmpty ? 'No name' : name,
      if (type.isNotEmpty) type,
      if (comments.isNotEmpty) comments,
      if (hasDocument) 'document',
    ].join(' - ');
    return label;
  }

  Future<void> _applyFilters() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await _controller.getPickupHistory(resetPage: true);
  }

  String _pickupVehicleLabel(VehicleList item) {
    final vehicle = item.vehicle;
    final vin = vehicle?.vin?.toString() ?? '';
    final model = [
      vehicle?.modal,
      vehicle?.companyName,
      vehicle?.name,
    ]
        .map((value) => value?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .join(' ');
    return model.isEmpty ? vin : '$vin ($model)';
  }

  void _showAddPickupSheet() {
    _controller.getPickupPreference();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const AppIconTile(
                      icon: Icons.local_shipping_outlined,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New pickup request',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setPickupState) {
                    return DropdownSearch<VehicleList>.multiSelection(
                      items: _controller.pickupEligibleVehicleList
                          .toList(growable: false),
                      selectedItems:
                          _controller.selectedPickupVehicles.toList(),
                      itemAsString: _pickupVehicleLabel,
                      compareFn: (a, b) => a.id == b.id,
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        menuProps: MenuProps(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search VIN, make, or model',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Select vehicles',
                          hintText:
                              'Only delivered vehicles without pickup request',
                          prefixIcon: Icon(Icons.directions_car_outlined),
                        ),
                      ),
                      onChanged: (values) {
                        _controller.selectedPickupVehicles.assignAll(values);
                        setPickupState(() {});
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                Obx(
                  () => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'Authorization',
                        label: Text('Authorization'),
                        icon: Icon(Icons.verified_user_outlined),
                      ),
                      ButtonSegment<String>(
                        value: 'Waiver',
                        label: Text('Waiver'),
                        icon: Icon(Icons.description_outlined),
                      ),
                    ],
                    selected: {_controller.pickupRequestType.value},
                    onSelectionChanged: (values) {
                      _controller.pickupRequestType.value = values.first;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final options =
                      _controller.previousPickupOptions.toList(growable: false);
                  if (options.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedPreviousPickupKey.value,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Use previous pickup info',
                          prefixIcon: Icon(Icons.history_rounded),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Use New Picker'),
                          ),
                          ...options.map(
                            (option) => DropdownMenuItem<String?>(
                              value: option['_dropdown_key']?.toString(),
                              child: SizedBox(
                                width: 260,
                                child: Text(
                                  _previousPickupLabel(option),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                        selectedItemBuilder: (context) {
                          return [
                            const Text(
                              'Use New Picker',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            ...options.map(
                              (option) => Text(
                                _previousPickupLabel(option),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ];
                        },
                        onChanged: _controller.applyPreviousPickupInfoByKey,
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }),
                TextField(
                  controller: _controller.pickupRequesterNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Requester name',
                    hintText: 'Enter full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller.pickupRequestCommentController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Additional comments',
                    hintText: 'Any specific instructions?',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final attached = _controller.pickupRequestFile.value != null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _controller.selectPickupFile,
                        icon: Icon(attached
                            ? Icons.check_circle_rounded
                            : Icons.cloud_upload_outlined),
                        label: Text(attached
                            ? _controller.pickupFileName.text
                            : 'Upload supporting document'),
                      ),
                      if (_controller.selectedPreviousPickupInfo.value !=
                          null) ...[
                        const SizedBox(height: 8),
                        _PreviousDocumentNotice(
                          option: _controller.selectedPreviousPickupInfo.value!,
                          hasNewFile: attached,
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 14),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: _controller.kSendingPickupRequestLoading.isTrue
                        ? null
                        : () async {
                            final sent = await _controller.sendPickupRequest();
                            if (sent && sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                              await _controller.getPickupHistory(
                                resetPage: true,
                              );
                            }
                          },
                    icon: _controller.kSendingPickupRequestLoading.isTrue
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 19),
                    label: Text(
                      _controller.kSendingPickupRequestLoading.isTrue
                          ? 'Sending request...'
                          : 'Send pickup request',
                    ),
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
        title: const Text('Pickup History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _controller.getPickupHistory(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _controller.getPickupHistory(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              FilledButton.icon(
                onPressed: _showAddPickupSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add new pickup'),
              ),
              const SizedBox(height: 14),
              Obx(() {
                final counts = _controller.pickupHistoryCounts;
                return _PickupStatsPanel(
                  waiting: counts['waiting'] ?? 0,
                  approve: counts['approve'] ?? 0,
                  unapprove: counts['unapprove'] ?? 0,
                  selected: _controller.pickupHistoryStatus.value,
                  onSelected: (status) {
                    _controller.pickupHistoryStatus.value = status;
                    _controller.getPickupHistory(resetPage: true);
                  },
                );
              }),
              const SizedBox(height: 14),
              _FilterCard(controller: _controller, onApply: _applyFilters),
              const SizedBox(height: 18),
              Obx(() {
                final records =
                    _controller.pickupHistoryList.toList(growable: false);
                return AppSectionHeader(
                  title: 'Your pickup records',
                  subtitle: '${records.length} records',
                );
              }),
              const SizedBox(height: 12),
              Obx(() {
                if (_controller.kPickupHistoryLoading.isTrue) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final records =
                    _controller.pickupHistoryList.toList(growable: false);
                if (records.isEmpty) {
                  return const _EmptyPickupHistory();
                }

                return Column(
                  children: [
                    ...records.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PickupHistorySimpleCard(
                          request: request,
                          documentUrl: _assetUrl(request.file),
                          onPreview: _controller.saveNetworkImage,
                          onDownload: _controller.saveNetworkImage,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickupHistorySimpleCard extends StatelessWidget {
  const _PickupHistorySimpleCard({
    required this.request,
    required this.documentUrl,
    required this.onPreview,
    required this.onDownload,
  });

  final PickupRequest request;
  final String documentUrl;
  final ValueChanged<String> onPreview;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    final vehicle = request.vehicle;
    final date = request.createdAt == null
        ? 'Not available'
        : DateFormat('MMM d, yyyy').format(request.createdAt!);
    final status = request.status?.toString().toUpperCase() ?? 'N/A';
    final statusColor = _statusColor(request.status?.toString() ?? '');
    final items = <_PickupInfoItem>[
      _PickupInfoItem(
        icon: Icons.fingerprint_rounded,
        label: 'VIN',
        value: vehicle?.vin?.toString() ?? '',
        color: const Color(0xFF0D9488),
      ),
      _PickupInfoItem(
        icon: Icons.description_outlined,
        label: 'Type',
        value: request.type?.toString() ?? '',
        color: const Color(0xFF2563EB),
      ),
      _PickupInfoItem(
        icon: Icons.person_outline_rounded,
        label: 'Picker',
        value: request.pickerName?.toString() ?? '',
        color: const Color(0xFF7C3AED),
      ),
      _PickupInfoItem(
        icon: Icons.place_outlined,
        label: 'Destination',
        value: vehicle?.destinationPort?.name?.toString() ??
            vehicle?.destinationManual?.toString() ??
            '',
        color: const Color(0xFFD97706),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Request #${request.id}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.22)),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PickupInfoGrid(items: items),
          if ((request.comments ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.comments!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.muted,
                    height: 1.35,
                  ),
            ),
          ],
          if (documentUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onPreview(documentUrl),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onDownload(documentUrl),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approve':
        return const Color(0xFF059669);
      case 'unapprove':
        return const Color(0xFFDC2626);
      case 'waiting':
        return const Color(0xFFD97706);
      default:
        return AppTheme.muted;
    }
  }
}

class _PreviousDocumentNotice extends StatelessWidget {
  const _PreviousDocumentNotice({
    required this.option,
    required this.hasNewFile,
  });

  final Map<String, dynamic> option;
  final bool hasNewFile;

  @override
  Widget build(BuildContext context) {
    final document = option['document']?.toString().trim() ?? '';
    final documentName = option['document_name']?.toString().trim() ?? '';
    final hasDocument = document.isNotEmpty;
    final color = hasNewFile
        ? AppTheme.primary
        : hasDocument
            ? AppTheme.success
            : const Color(0xFFD97706);
    final title = hasNewFile
        ? 'New document selected'
        : hasDocument
            ? (documentName.isNotEmpty
                ? documentName
                : document.split('/').last)
            : 'No document saved for this info';
    final subtitle = hasNewFile
        ? 'The uploaded file will be used for this pickup.'
        : hasDocument
            ? 'This previous document will be reused unless you upload a new one.'
            : 'Upload a document if this pickup needs one.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument || hasNewFile
                ? Icons.description_outlined
                : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.muted,
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

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.controller, required this.onApply});

  final VehicleController controller;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_alt_rounded,
                      size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Filters & Search',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.resetPickupHistoryFilters,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: const Text('Search'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: controller.pickupHistorySearchController,
                  onSubmitted: (_) => onApply(),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'VIN, description, picker, date...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: controller.pickupHistoryStatus.value,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Statuses')),
                      DropdownMenuItem(
                          value: 'waiting', child: Text('Waiting')),
                      DropdownMenuItem(
                          value: 'approve', child: Text('Approved')),
                      DropdownMenuItem(
                          value: 'unapprove', child: Text('Unapproved')),
                    ],
                    onChanged: (value) {
                      controller.pickupHistoryStatus.value = value ?? 'all';
                    },
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  final destinations =
                      controller.destinationPortList.toList(growable: false);
                  return DropdownButtonFormField<DestinationPort?>(
                    value: controller.pickupHistoryDestination.value,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: Icon(Icons.place_rounded),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<DestinationPort?>(
                        value: null,
                        child: Text('All Destinations'),
                      ),
                      ...destinations.map(
                        (destination) => DropdownMenuItem<DestinationPort?>(
                          value: destination,
                          child: Text(destination.name?.toString() ?? ''),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      controller.pickupHistoryDestination.value = value;
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupInfoItem {
  const _PickupInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _PickupInfoGrid extends StatelessWidget {
  const _PickupInfoGrid({required this.items});

  final List<_PickupInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  height: 60,
                  child: _PickupInfoTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PickupInfoTile extends StatelessWidget {
  const _PickupInfoTile({required this.item});

  final _PickupInfoItem item;

  @override
  Widget build(BuildContext context) {
    final value = item.value.trim().isEmpty ? '-' : item.value.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 14, color: item.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
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

class _PickupStatsPanel extends StatelessWidget {
  const _PickupStatsPanel({
    required this.waiting,
    required this.approve,
    required this.unapprove,
    required this.selected,
    required this.onSelected,
  });

  final int waiting;
  final int approve;
  final int unapprove;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final total = waiting + approve + unapprove;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Overview',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                      Text(
                        '$total Total Requests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                      ),
                    ],
                  ),
                ),
                if (selected != 'all')
                  TextButton.icon(
                    onPressed: () => onSelected('all'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 15),
                    label: const Text('All', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 86,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PickupMetric(
                      label: 'Waiting',
                      value: waiting,
                      color: const Color(0xFFD97706),
                      selected: selected == 'waiting',
                      onTap: () => onSelected('waiting'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PickupMetric(
                      label: 'Approved',
                      value: approve,
                      color: const Color(0xFF059669),
                      selected: selected == 'approve',
                      onTap: () => onSelected('approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PickupMetric(
                      label: 'Rejected',
                      value: unapprove,
                      color: const Color(0xFFDC2626),
                      selected: selected == 'unapprove',
                      onTap: () => onSelected('unapprove'),
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

class _PickupMetric extends StatelessWidget {
  const _PickupMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.25),
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: selected ? color : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? color.withOpacity(0.8) : Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPickupHistory extends StatelessWidget {
  const _EmptyPickupHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.08),
                  AppTheme.primary.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 38,
              color: AppTheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No pickup records found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters or add a new pickup request.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.muted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

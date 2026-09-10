import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/login_response.dart';
import 'package:cargo/models/pickup_request_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PickupRequestsScreen extends StatefulWidget {
  const PickupRequestsScreen({super.key});

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  final OperatorController _operatorController = Get.find();
  final VehicleController _vehicleController = Get.find();
  final UserController _userController = Get.find();
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _vehicleController.getAllPickupRequest();
    _userController.getAllOperatorUsersList();
  }

  bool get _canManageRequests {
    final level = _authController.loginResponse.value?.data.user.operatorLevel;
    return level != null && level.access != 'View only';
  }

  int get _activeFilterCount {
    var count = 0;
    if (_operatorController.startDateController.text.trim().isNotEmpty) {
      count++;
    }
    if (_operatorController.endDateController.text.trim().isNotEmpty) {
      count++;
    }
    if (_userController.selectedOperatorUser.value != null) count++;
    if ((_operatorController.selectedStatus ?? '').trim().isNotEmpty) count++;
    return count;
  }

  bool _applyFilters() {
    final startDate = _operatorController.startDateController.text.trim();
    final endDate = _operatorController.endDateController.text.trim();
    if (startDate.isEmpty != endDate.isEmpty) {
      showMightySnackBar(message: 'Select both a start and an end date');
      return false;
    }

    final parsedStart = DateTime.tryParse(startDate);
    final parsedEnd = DateTime.tryParse(endDate);
    if (parsedStart != null &&
        parsedEnd != null &&
        parsedStart.isAfter(parsedEnd)) {
      showMightySnackBar(message: 'Start date must be before the end date');
      return false;
    }

    _vehicleController.filterPickupRequest(
      startDate: startDate,
      endDate: endDate,
      clientName: _userController.selectedOperatorUser.value?.name,
      status: _operatorController.selectedStatus == null ||
              _operatorController.selectedStatus!.isEmpty
          ? null
          : _operatorController.selectedStatus,
    );
    return true;
  }

  void _resetFilters() {
    _operatorController.startDateController.clear();
    _operatorController.endDateController.clear();
    _operatorController.selectedStatus = null;
    _userController.selectedOperatorUser.value = null;
    _userController.selectedOperatorUser.refresh();
    _vehicleController.getAllPickupRequest();
  }

  Future<void> _openFilters() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;
        final keyboardInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        final availableHeight = screenHeight - keyboardInset;
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: SizedBox(
            height: availableHeight * .86,
            child: Material(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Filter requests',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close filters',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: _FilterFields(
                        operatorController: _operatorController,
                        userController: _userController,
                        onApply: () {
                          if (_applyFilters()) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        onReset: () {
                          _resetFilters();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh requests',
            onPressed: _vehicleController.getAllPickupRequest,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilterPanel(
                activeFilterCount: _activeFilterCount,
                onTap: _openFilters,
              ),
              const SizedBox(height: 18),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Request queue',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_vehicleController.pickupRequestList.length} requests',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (_vehicleController.kPickupRequestLoading.isTrue) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_vehicleController.pickupRequestList.isEmpty) {
                    return const _EmptyRequests();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await _vehicleController.getAllPickupRequest();
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _vehicleController.pickupRequestList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _PickupRequestCard(
                          request: _vehicleController.pickupRequestList[index],
                          canManage: _canManageRequests,
                          onApprove: () {
                            _operatorController.changeStatusRequest(
                              _vehicleController.pickupRequestList[index].id,
                              'approve',
                            );
                          },
                          onReject: () {
                            _operatorController.changeStatusRequest(
                              _vehicleController.pickupRequestList[index].id,
                              'reject',
                            );
                          },
                          onDownload: (path) {
                            _operatorController.downloadAndOpenFile(
                              '$vehicleImageBaseUrl$path',
                            );
                          },
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
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.activeFilterCount,
    required this.onTap,
  });

  final int activeFilterCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter requests',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      activeFilterCount == 0
                          ? 'Date, client, and request status'
                          : '$activeFilterCount active '
                              '${activeFilterCount == 1 ? 'filter' : 'filters'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: activeFilterCount == 0
                                ? AppTheme.muted
                                : AppTheme.primary,
                            fontWeight: activeFilterCount == 0
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterFields extends StatelessWidget {
  const _FilterFields({
    required this.operatorController,
    required this.userController,
    required this.onApply,
    required this.onReset,
  });

  final OperatorController operatorController;
  final UserController userController;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose any combination of filters, then apply.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 520;
            final startField = _DateField(
              controller: operatorController.startDateController,
              label: 'Start date',
              onTap: () => operatorController.showStartDate(context),
            );
            final endField = _DateField(
              controller: operatorController.endDateController,
              label: 'End date',
              onTap: () => operatorController.showEndDate(context),
            );

            if (stacked) {
              return Column(
                children: [
                  startField,
                  const SizedBox(height: 12),
                  endField,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: startField),
                const SizedBox(width: 12),
                Expanded(child: endField),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Obx(
          () => DropdownSearch<AppUser>(
            items: userController.filterOperatorUserList,
            selectedItem: userController.selectedOperatorUser.value,
            itemAsString: (user) {
              final name = user.name?.toString().trim() ?? '';
              final email = user.email?.toString().trim() ?? '';
              if (name.isNotEmpty && email.isNotEmpty) return '$name ($email)';
              if (name.isNotEmpty) return name;
              return email.isEmpty ? 'User #${user.id}' : email;
            },
            compareFn: (a, b) => a.id == b.id,
            clearButtonProps: const ClearButtonProps(isVisible: true),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search clients',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: 'Client',
                hintText: 'All clients',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            onChanged: (value) {
              userController.selectedOperatorUser.value = value;
              userController.selectedOperatorUser.refresh();
            },
          ),
        ),
        const SizedBox(height: 12),
        DropdownSearch<String>(
          items: operatorController.pickupStatusList
              .where((status) => status.trim().isNotEmpty)
              .toList(),
          selectedItem: operatorController.selectedStatus?.isEmpty == true
              ? null
              : operatorController.selectedStatus,
          clearButtonProps: const ClearButtonProps(isVisible: true),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Status',
              hintText: 'All statuses',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
          ),
          onChanged: (value) {
            operatorController.selectedStatus = value ?? '';
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 360;
            final resetButton = OutlinedButton(
              onPressed: onReset,
              child: const Text('Reset'),
            );
            final applyButton = ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Apply filters'),
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  applyButton,
                  const SizedBox(height: 10),
                  resetButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: resetButton),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: applyButton),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.label,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select date',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }
}

class _PickupRequestCard extends StatelessWidget {
  const _PickupRequestCard({
    required this.request,
    required this.canManage,
    required this.onApprove,
    required this.onReject,
    required this.onDownload,
  });

  final PickupRequest request;
  final bool canManage;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final ValueChanged<String> onDownload;

  String _value(dynamic value, [String fallback = 'Not provided']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Color get _statusColor {
    final status = _value(request.status, '').toLowerCase();
    if (status.contains('approv')) return AppTheme.success;
    if (status.contains('reject')) return AppTheme.danger;
    return AppTheme.warning;
  }

  String get _statusLabel {
    final status = _value(request.status, 'Waiting');
    if (status.toLowerCase() == 'approve') return 'Approved';
    if (status.toLowerCase() == 'reject') return 'Rejected';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final created = request.createdAt == null
        ? 'No date'
        : DateFormat('MMM d, y').format(request.createdAt!.toLocal());
    final file = request.file?.trim() ?? '';

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(15, 8, 12, 8),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.local_shipping_outlined, color: _statusColor),
        ),
        title: Text(
          _value(request.user?.name, 'Unknown client'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              Flexible(
                  child: _StatusChip(label: _statusLabel, color: _statusColor)),
              const SizedBox(width: 8),
              Text(created, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.pin_outlined,
            label: 'VIN',
            value: _value(request.vehicle?.vin),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.person_pin_outlined,
            label: 'Picker',
            value: _value(request.pickerName),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Payment',
            value: _value(request.paymentStatus, 'Unpaid'),
          ),
          if (_value(request.comments, '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Comments',
              value: _value(request.comments),
            ),
          ],
          if (file.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onDownload(file),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Open attachment'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
          if (canManage) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: const BorderSide(color: AppTheme.danger),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.muted),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No pickup requests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'New requests will appear here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

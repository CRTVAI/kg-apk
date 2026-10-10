import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/destination_port_response.dart';
import '../../models/login_response.dart';
import '../../models/vehicle_list_response.dart';
import '../styles/app_theme.dart';
import 'car_images_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key, required this.vehicleList});

  final VehicleList vehicleList;

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final VehicleController _vehicleController = Get.find<VehicleController>();
  final UserController _userController = Get.find<UserController>();
  final PageController _imagePageController = PageController();

  final bool _showUnloading = false;
  int _visibleImageIndex = 0;

  Vehicle get _vehicle =>
      _vehicleController.selectedPickupVehicle.value?.vehicle ??
      widget.vehicleList.vehicle!;

  List<VehicleImage> get _warehouseImages {
    final images = (_vehicle.vehicleImages ?? <VehicleImage>[]).where((image) {
      final type = image.type?.toString().toLowerCase() ?? '';
      return type != 'unloading';
    }).toList();
    final pending = _vehicle.pendingImages?.images ?? <String>[];
    for (var index = 0; index < pending.length; index++) {
      images.add(
        VehicleImage(
          id: -1000 - index,
          filename: pending[index],
          type: 'warehouse',
        ),
      );
    }
    return images;
  }

  List<VehicleImage> get _unloadingImages {
    return (_vehicle.vehicleImages ?? <VehicleImage>[]).where((image) {
      return image.type?.toString().toLowerCase() == 'unloading';
    }).toList();
  }

  List<VehicleImage> get _visibleImages =>
      _showUnloading ? _unloadingImages : _warehouseImages;

  List<VehicleSubUserAssignment> get _assignedSubUsers {
    final selected = _vehicleController.selectedPickupVehicle.value?.subUsers;
    if (selected != null) return selected;
    return widget.vehicleList.subUsers ?? <VehicleSubUserAssignment>[];
  }

  String _text(dynamic value, [String fallback = '-']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? fallback : result;
  }

  String get _vehicleName {
    final values = <dynamic>[
      _vehicle.modal,
      _vehicle.companyName,
      _vehicle.name,
    ].map((value) => _text(value, '')).where((value) => value.isNotEmpty);
    return values.isEmpty ? 'Vehicle details' : values.join(' ');
  }

  String _assetUrl(dynamic filepath, dynamic filename) {
    final file = _text(filename, '');
    if (file.startsWith('http://') || file.startsWith('https://')) return file;
    final path = _text(filepath, '');
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$path$file';
  }

  String _imageUrl(VehicleImage image) {
    return _assetUrl(image.filepath, image.filename);
  }

  String _documentUrl(VehicleDocument document) {
    return _assetUrl(document.filepath, document.filename);
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final date = value is DateTime ? value : DateTime.parse(value.toString());
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return _text(value);
    }
  }

  bool _isAvailable(dynamic value) {
    final normalized = _text(value, '').toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'no' &&
        normalized != '0' &&
        normalized != 'false';
  }

  bool get _canUpdateDestination {
    final status = _text(_vehicle.status?.name, '').toLowerCase();
    return _vehicle.updateDestination == 0 && status != 'delivered';
  }

  bool get _needsUmmQasrCustomerName {
    final destination = _text(
      _vehicleController.selectedDestinationPort.value?.name ??
          _vehicle.destinationManual ??
          _vehicle.destinationPort?.name ??
          widget.vehicleList.container?.destinationPort?.name,
      '',
    ).toUpperCase();
    final updateCustomer = _text(_vehicle.updateCustomer, '0');
    return destination.contains('UMM QASR') &&
        (updateCustomer == '0' || updateCustomer.toLowerCase() == 'null');
  }

  void _openImagesPage() {
    Get.to(
      () => CarImagesScreen(
        vehicle: _vehicle,
        initialShowUnloading: _showUnloading,
      ),
    );
  }

  void _moveImage(int direction) {
    if (_visibleImages.isEmpty) return;
    final lastIndex = _visibleImages.length - 1;
    final nextIndex = (_visibleImageIndex + direction).clamp(0, lastIndex);
    if (nextIndex == _visibleImageIndex) return;
    setState(() => _visibleImageIndex = nextIndex);
    _imagePageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _vehicleController.emailController.clear();
    _vehicleController.selectedPickupVehicle.value = widget.vehicleList;
    _vehicleController.vehicleImageList.assignAll(
      _vehicle.vehicleImages ?? <VehicleImage>[],
    );
    _vehicleController.filterVehicleImageList();
    _vehicleController.getVehicleFilterList(
      _vehicle.vehicleImages ?? <VehicleImage>[],
    );
    _vehicleController.notesController.text = _text(_vehicle.notesUser, '');
    _vehicleController.generalNotesController.text =
        _text(_vehicle.notesUser, '');
    _vehicleController.documentNotesController.text =
        _text(_vehicle.notesDocument, '');
    _vehicleController.customerNameEnglishController.text =
        _text(_vehicle.customerName, '');
    _userController.getAllOperatorUsersList();
    _userController.getAllUsersList();
    _vehicleController.getDestinationPortList();
    _vehicleController.getVehicleDetail(widget.vehicleList).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _vehicleController.emailController.clear();
    _vehicleController.clearPickupField();
    _vehicleController.wareHouseImageList.clear();
    _vehicleController.unloadingImageList.clear();
    _vehicleController.clearPickupVehicle();
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _copy(String label, dynamic value) async {
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

  Future<void> _sendVehicleEmail() async {
    if (_vehicleController.sendingEmail.isTrue) return;
    await _vehicleController.sendEmail(_vehicle.id);
    await _vehicleController.getVehicleDetail(widget.vehicleList);
    if (mounted) setState(() {});
  }

  void _showUsersSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: .82,
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
                        Icons.person_add_alt_1_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assign vehicle',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Choose a sub-user for this vehicle',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _userController.searchStringController,
                  onChanged: (value) {
                    _userController.onChangeHandler(value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search sub-users',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: Builder(builder: (_) {
                  final assignedUserIds = _assignedSubUsers
                      .map((assignment) => assignment.userId?.toString())
                      .where((id) => id != null && id.isNotEmpty)
                      .toSet();
                  final users = _userController.filterSubUserList
                      .where((user) =>
                          !assignedUserIds.contains(user.id.toString()))
                      .toList(growable: false);
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        _userController.filterSubUserList.isEmpty
                            ? 'No sub-users found'
                            : 'All matching sub-users are already assigned',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.muted,
                            ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final AppUser user = users[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(.1),
                            foregroundColor: AppTheme.primary,
                            child: Text(
                              _text(user.name, 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(
                            _text(user.name, 'Unnamed user'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 15),
                          ),
                          subtitle: Text(_text(user.email)),
                          trailing: IconButton.filledTonal(
                            tooltip: 'Assign vehicle',
                            onPressed: () async {
                              final added =
                                  await _userController.addUserToVehicle(
                                user.id,
                                _vehicle.id,
                              );
                              if (!added) return;
                              await _vehicleController
                                  .getVehicleDetail(widget.vehicleList);
                              if (mounted) setState(() {});
                            },
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
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

  void _removeAssignedUserLocally(int assignmentId) {
    widget.vehicleList.subUsers?.removeWhere(
      (assignment) => assignment.id == assignmentId,
    );
    _vehicleController.selectedPickupVehicle.value?.subUsers?.removeWhere(
      (assignment) => assignment.id == assignmentId,
    );
    _vehicleController.selectedPickupVehicle.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final container = widget.vehicleList.container;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle details'),
        actions: [
          IconButton(
            tooltip: 'Assign to sub-user',
            onPressed: _showUsersSheet,
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageGallery(
              images: _visibleImages,
              currentIndex: _visibleImageIndex,
              unloading: _showUnloading,
              warehouseCount: _warehouseImages.length,
              unloadingCount: _unloadingImages.length,
              pageController: _imagePageController,
              imageUrl: _imageUrl,
              onPageChanged: (index) =>
                  setState(() => _visibleImageIndex = index),
              onOpenImage: _openImagesPage,
              onPrevious: () => _moveImage(-1),
              onNext: () => _moveImage(1),
              onSelectWarehouse: () => Get.to(
                () => CarImagesScreen(
                  vehicle: _vehicle,
                  initialShowUnloading: false,
                ),
              ),
              onSelectUnloading: () => Get.to(
                () => CarImagesScreen(
                  vehicle: _vehicle,
                  initialShowUnloading: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _vehicleName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Vehicle ID #${_vehicle.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Vehicle information',
              icon: Icons.directions_car_outlined,
            ),
            _InfoCard(
              children: [
                if (_text(_vehicle.notes, '').isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 10),
                    child: _ReadonlyNote(
                      title: 'OFFICIAL REMARKS',
                      value: _text(_vehicle.notes),
                      isDanger: true,
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                ],
                _InfoRow(
                  label: 'Status',
                  value: _text(_vehicle.status?.name),
                  valueColor: AppTheme.primary,
                  leading: Icons.track_changes_rounded,
                ),
                _InfoRow(
                  label: 'Client',
                  value: _text(_vehicle.clientName),
                  leading: Icons.person_outline_rounded,
                ),
                _InfoRow(
                  label: 'LOT number',
                  value: _text(_vehicle.lotnumber),
                  leading: Icons.tag_rounded,
                  onCopy: () => _copy('LOT number', _vehicle.lotnumber),
                ),
                _InfoRow(
                  label: 'VIN',
                  value: _text(_vehicle.vin),
                  leading: Icons.fingerprint_rounded,
                  onCopy: () => _copy('VIN', _vehicle.vin),
                ),
                _InfoRow(
                  label: 'Title',
                  value: _isAvailable(_vehicle.title)
                      ? 'Available'
                      : 'Not available',
                  leading: Icons.description_outlined,
                  valueColor: _isAvailable(_vehicle.title)
                      ? AppTheme.success
                      : AppTheme.danger,
                ),
                _InfoRow(
                  label: 'Keys',
                  value: _isAvailable(_vehicle.keys)
                      ? 'Available'
                      : 'Not available',
                  leading: Icons.key_rounded,
                  valueColor: _isAvailable(_vehicle.keys)
                      ? AppTheme.success
                      : AppTheme.danger,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Assigned users',
              icon: Icons.group_outlined,
            ),
            _AssignedUsersCard(
              assignments: _assignedSubUsers,
              text: _text,
              onRemove: (assignment) async {
                final user = assignment.user;
                final name = _text(
                  user?.surname,
                  _text(user?.name, 'this user'),
                );
                final confirmed = await _confirmRemoveAssignedUser(name);
                if (!confirmed) return;
                final removed = await _userController.removeUserFromVehicle(
                  assignment.id,
                );
                if (!removed) return;
                _removeAssignedUserLocally(assignment.id);
                if (mounted) setState(() {});
                await _vehicleController.getVehicleDetail(widget.vehicleList);
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Additional details',
              icon: Icons.info_outline_rounded,
            ),
            _InfoCard(
              children: [
                _InfoRow(
                  label: 'Terminal',
                  value: _text(_vehicle.terminal?.name),
                  leading: Icons.warehouse_outlined,
                ),
                _InfoRow(
                  label: 'Auction',
                  value: _text(_vehicle.auction?.name),
                  leading: Icons.gavel_rounded,
                ),
                _InfoRow(
                  label: 'Auction buyer',
                  value: _text(_vehicle.auctionBuyer),
                  leading: Icons.badge_outlined,
                ),
                _InfoRow(
                  label: 'Fuel type',
                  value: _text(_vehicle.fuelType),
                  leading: Icons.local_gas_station_outlined,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Container & destination',
              icon: Icons.inventory_2_outlined,
            ),
            if (container == null)
              const _NoContainerCard()
            else
              _InfoCard(
                children: [
                  _InfoRow(
                    label: 'Booking',
                    value: _text(container.bookingNo),
                    leading: Icons.confirmation_number_outlined,
                    onCopy: () => _copy('Booking number', container.bookingNo),
                  ),
                  _InfoRow(
                    label: 'Container',
                    value: _text(container.containerNo),
                    leading: Icons.inventory_2_outlined,
                    onCopy: () =>
                        _copy('Container number', container.containerNo),
                  ),
                  _InfoRow(
                    label: 'Departure',
                    value: _formatDate(container.departure),
                    leading: Icons.flight_takeoff_rounded,
                  ),
                  _InfoRow(
                    label: 'Arrival',
                    value: _formatDate(container.arrival),
                    leading: Icons.flight_land_rounded,
                  ),
                  _InfoRow(
                    label: 'Shipping line',
                    value: _text(
                      container.shippingLine?.name ??
                          container.shippingLineName,
                    ),
                    leading: Icons.local_shipping_outlined,
                    isLast: true,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            _DestinationCard(
              controller: _vehicleController,
              vehicleList: widget.vehicleList,
              canEdit: _canUpdateDestination,
              showCustomerName: _needsUmmQasrCustomerName,
              currentDestination: _text(
                _vehicleController.selectedDestinationPort.value?.name ??
                    _vehicle.destinationManual ??
                    _vehicle.destinationPort?.name ??
                    container?.destinationPort?.name,
              ),
              onUpdated: () => setState(() {}),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Vehicle Records & Notes',
              icon: Icons.sticky_note_2_outlined,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _vehicleController.generalNotesController,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'User General Notes',
                        hintText: 'Your general observation...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vehicleController.documentNotesController,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Personal Tracking Notes',
                        hintText: 'Private internal notes...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: _vehicleController.savingNotes.isTrue
                            ? null
                            : _vehicleController.saveVehicleNotes,
                        icon: _vehicleController.savingNotes.isTrue
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save My Notes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _DocumentsSection(
              documents: _vehicle.vehicleDocuments ?? <VehicleDocument>[],
              documentUrl: _documentUrl,
              onPreview: _vehicleController.saveNetworkImage,
              onDownload: _vehicleController.saveNetworkImage,
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
              title: 'Share vehicle',
              icon: Icons.forward_to_inbox_outlined,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send this vehicle’s information to an email address.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.muted,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vehicleController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onSubmitted: (_) async {
                        await _sendVehicleEmail();
                      },
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: _vehicleController.sendingEmail.isTrue
                            ? null
                            : _sendVehicleEmail,
                        icon: _vehicleController.sendingEmail.isTrue
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Send by email'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _EmailHistorySection(controller: _vehicleController),
          ],
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.currentIndex,
    required this.unloading,
    required this.warehouseCount,
    required this.unloadingCount,
    required this.pageController,
    required this.imageUrl,
    required this.onPageChanged,
    required this.onOpenImage,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectWarehouse,
    required this.onSelectUnloading,
  });

  final List<VehicleImage> images;
  final int currentIndex;
  final bool unloading;
  final int warehouseCount;
  final int unloadingCount;
  final PageController pageController;
  final String Function(VehicleImage) imageUrl;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenImage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelectWarehouse;
  final VoidCallback onSelectUnloading;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (images.isEmpty)
                  const _NoPhotoPlaceholder()
                else
                  InkWell(
                    onTap: onOpenImage,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (_, index) => CachedNetworkImage(
                        imageUrl: imageUrl(images[index]),
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (_, __, progress) =>
                            Container(
                          color: const Color(0xFFE7EEF7),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            const _NoPhotoPlaceholder(unavailable: true),
                      ),
                    ),
                  ),
                if (images.isNotEmpty)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC102A43),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${currentIndex + 1} / ${images.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                if (images.length > 1) ...[
                  Positioned(
                    left: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton.filledTonal(
                        tooltip: 'Previous photo',
                        onPressed: currentIndex == 0 ? null : onPrevious,
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton.filledTonal(
                        tooltip: 'Next photo',
                        onPressed:
                            currentIndex >= images.length - 1 ? null : onNext,
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ImageGroupButton(
                        label: 'Warehouse',
                        icon: Icons.warehouse_outlined,
                        count: warehouseCount,
                        selected: !unloading,
                        onTap: onSelectWarehouse,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ImageGroupButton(
                        label: 'Unloading',
                        icon: Icons.local_shipping_outlined,
                        count: unloadingCount,
                        selected: unloading,
                        onTap: onSelectUnloading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPhotoPlaceholder extends StatelessWidget {
  const _NoPhotoPlaceholder({this.unavailable = false});

  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE7EEF7),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_car_filled_rounded,
            color: AppTheme.primary,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            unavailable ? 'Photo unavailable' : 'No photos in this category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ImageGroupButton extends StatelessWidget {
  const _ImageGroupButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primary.withOpacity(.1) : AppTheme.canvas,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppTheme.primary : AppTheme.muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected ? AppTheme.primary : AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? AppTheme.primary : AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 9),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: children),
      ),
    );
  }
}

class _AssignedUsersCard extends StatelessWidget {
  const _AssignedUsersCard({
    required this.assignments,
    required this.text,
    required this.onRemove,
  });

  final List<VehicleSubUserAssignment> assignments;
  final String Function(dynamic value, [String fallback]) text;
  final Future<void> Function(VehicleSubUserAssignment assignment) onRemove;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  color: AppTheme.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No sub-users assigned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Assigned access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${assignments.length} user${assignments.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < assignments.length; index++) ...[
              if (index > 0) const Divider(height: 18),
              _AssignedUserTile(
                assignment: assignments[index],
                text: text,
                onRemove: onRemove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssignedUserTile extends StatelessWidget {
  const _AssignedUserTile({
    required this.assignment,
    required this.text,
    required this.onRemove,
  });

  final VehicleSubUserAssignment assignment;
  final String Function(dynamic value, [String fallback]) text;
  final Future<void> Function(VehicleSubUserAssignment assignment) onRemove;

  @override
  Widget build(BuildContext context) {
    final user = assignment.user;
    final name = text(user?.surname, text(user?.name, 'Unnamed user'));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primarySoft,
          foregroundColor: AppTheme.primary,
          child: Text(name.substring(0, 1).toUpperCase()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Remove assigned user',
          onPressed: () => onRemove(assignment),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.leading,
    this.valueColor,
    this.onCopy,
    this.isLast = false,
  });

  final String label;
  final String value;
  final IconData leading;
  final Color? valueColor;
  final VoidCallback? onCopy;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(leading, size: 17, color: AppTheme.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? AppTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (onCopy != null) ...[
            const SizedBox(width: 5),
            IconButton(
              tooltip: 'Copy $label',
              visualDensity: VisualDensity.compact,
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppTheme.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoContainerCard extends StatelessWidget {
  const _NoContainerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not assigned to a container',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Container information will appear here once assigned.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
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

class _ReadonlyNote extends StatelessWidget {
  const _ReadonlyNote({
    required this.title,
    required this.value,
    this.isDanger = false,
  });

  final String title;
  final String value;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final accent = isDanger ? AppTheme.danger : AppTheme.muted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xFFFFF1F2) : AppTheme.canvas,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDanger ? const Color(0xFFFCA5A5) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isDanger) ...[
                Icon(Icons.warning_amber_rounded, color: accent, size: 18),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDanger ? const Color(0xFF991B1B) : null,
                  fontWeight: isDanger ? FontWeight.w700 : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.documents,
    required this.documentUrl,
    required this.onPreview,
    required this.onDownload,
  });

  final List<VehicleDocument> documents;
  final String Function(VehicleDocument) documentUrl;
  final ValueChanged<String> onPreview;
  final ValueChanged<String> onDownload;

  String _documentName(VehicleDocument document) {
    final rawName = document.filename?.toString().trim() ?? '';
    if (rawName.isEmpty) return 'Document';
    return rawName;
  }

  String _documentMeta(VehicleDocument document) {
    final type = document.type?.toString().trim() ?? '';
    if (type.isEmpty || type.toLowerCase() == 'null' || type == '0') {
      return '';
    }
    return type;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Attached Documents',
          icon: Icons.picture_as_pdf_outlined,
        ),
        Card(
          child: documents.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No documents attached.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppTheme.border),
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final url = documentUrl(document);
                    final title = _documentName(document);
                    final meta = _documentMeta(document);
                    return ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: meta.isEmpty
                          ? null
                          : Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Preview',
                            onPressed: () => onPreview(url),
                            icon: const Icon(Icons.visibility_outlined),
                          ),
                          IconButton(
                            tooltip: 'Download',
                            onPressed: () => onDownload(url),
                            icon: const Icon(Icons.download_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmailHistorySection extends StatelessWidget {
  const _EmailHistorySection({required this.controller});

  final VehicleController controller;

  String _text(dynamic value, [String fallback = '—']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? fallback : result;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '—';
    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (_) {
      return _text(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Email history',
          icon: Icons.history_rounded,
        ),
        Card(
          child: Obx(
            () {
              final history = controller.emailHistoryList;
              return history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No email history found.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.muted,
                            ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppTheme.border),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.mark_email_read_outlined,
                            color: AppTheme.primary,
                          ),
                          title: Text(_text(item.sentTo)),
                          subtitle: Text(_formatDate(item.createdAt)),
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.controller,
    required this.vehicleList,
    required this.canEdit,
    required this.showCustomerName,
    required this.currentDestination,
    required this.onUpdated,
  });

  final VehicleController controller;
  final VehicleList vehicleList;
  final bool canEdit;
  final bool showCustomerName;
  final String currentDestination;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destination',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (!canEdit)
                        Text(
                          currentDestination,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 15,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (canEdit) ...[
              const SizedBox(height: 12),
              Obx(
                () => DropdownButtonFormField<DestinationPort>(
                  isExpanded: true,
                  value: controller.selectedDestinationPort.value,
                  items: controller.destinationPortList
                      .map(
                        (destination) => DropdownMenuItem<DestinationPort>(
                          value: destination,
                          child: Text(
                            destination.name?.toString() ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedDestinationPort.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Select destination port',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
              ),
              Obx(() {
                final selectedName = controller
                        .selectedDestinationPort.value?.name
                        ?.toString()
                        .toUpperCase() ??
                    '';
                final needsName =
                    showCustomerName || selectedName.contains('UMM QASR');
                if (!needsName) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: controller.customerNameEnglishController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (English)',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                );
              }),
              Obx(
                () => controller.selectedDestinationPort.value == null &&
                        !showCustomerName
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await controller.updateVehicleInfo();
                              await controller.getVehicleDetail(vehicleList);
                              onUpdated();
                            },
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Update destination'),
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

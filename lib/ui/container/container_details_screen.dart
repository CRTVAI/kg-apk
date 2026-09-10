import 'package:cargo/controllers/container_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/container_list_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class ContainerDetailsScreen extends StatefulWidget {
  final Containers con;

  const ContainerDetailsScreen({super.key, required this.con});

  @override
  State<ContainerDetailsScreen> createState() => _ContainerDetailsScreenState();
}

class _ContainerDetailsScreenState extends State<ContainerDetailsScreen> {
  final ContainerController containerController = Get.find();
  final VehicleController _vehicleController = Get.find();

  Containers get container =>
      containerController.selectedContainer.value ?? widget.con;

  @override
  void initState() {
    super.initState();
    containerController.getContainerDetail(widget.con).then((_) {
      if (mounted) setState(() {});
    });
    _vehicleController.getDestinationPortList();
  }

  String _value(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? '—' : result;
  }

  String _date(dynamic value) {
    if (value == null) return '—';
    if (value is DateTime) return intl.DateFormat('MMM dd, yyyy').format(value);
    final parsed = DateTime.tryParse(value.toString());
    return parsed == null
        ? _value(value)
        : intl.DateFormat('MMM dd, yyyy').format(parsed);
  }

  String _relationName(dynamic relationValue, dynamic fallbackValue) {
    final relation = _value(relationValue);
    return relation == '-' ? _value(fallbackValue) : relation;
  }

  bool _isPaid(dynamic value) {
    final normalized = value?.toString().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'paid';
  }

  bool _isEmptyAssetValue(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'null' ||
        normalized == '-' ||
        normalized == '—';
  }

  String _robustAssetUrl(dynamic filepath, dynamic filename) {
    final rawFile = filename?.toString().trim() ?? '';
    final rawPath = filepath?.toString().trim() ?? '';

    if (rawFile.startsWith('http://') || rawFile.startsWith('https://')) {
      return rawFile;
    }

    if (_isEmptyAssetValue(rawFile)) {
      if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
        return rawPath;
      }
      if (_isEmptyAssetValue(rawPath)) return '';
      return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$rawPath'
          .replaceAll('\\', '/');
    }

    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      final separator = rawPath.endsWith('/') ? '' : '/';
      return '$rawPath$separator$rawFile'.replaceAll('\\', '/');
    }

    final path = _isEmptyAssetValue(rawPath) ? '' : rawPath;
    final separator = path.isEmpty || path.endsWith('/') ? '' : '/';
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$path$separator$rawFile'
        .replaceAll('\\', '/');
  }

  String _assetUrl(dynamic filepath, dynamic filename) {
    final robustUrl = _robustAssetUrl(filepath, filename);
    if (robustUrl.isNotEmpty) return robustUrl;

    final file = _value(filename);
    if (file == 'â€”') return '';
    if (file.startsWith('http://') || file.startsWith('https://')) {
      return file;
    }
    var path = _value(filepath);
    path = path == 'â€”' ? '' : path;
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$path$file'
        .replaceAll('\\', '/');
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

  void _trackContainer() {
    final shippingLine = _relationName(
      container.shippingLine?.name,
      container.shippingLineName,
    );
    final containerNumber = _value(container.containerNo);
    if (shippingLine == '—' || containerNumber == '—') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tracking is unavailable because the shipping information is incomplete.',
          ),
        ),
      );
      return;
    }
    containerController.trackContainer(shippingLine, containerNumber);
  }

  @override
  Widget build(BuildContext context) {
    final status = _relationName(container.status?.name, container.statusName);
    final shippingLine = _relationName(
      container.shippingLine?.name,
      container.shippingLineName,
    );
    final consigneeName = _relationName(
      container.consignee?.companyName,
      container.consigneeName,
    );
    final consigneeAddress = _relationName(
      container.consignee?.address,
      container.consigneeAddress,
    );
    final loadingPort = _relationName(
      container.loadingPort?.name,
      container.loadingPortName,
    );
    final destinationPort = _relationName(
      container.destinationPort?.name,
      container.destinationPortName,
    );
    final dischargePort = _relationName(
      container.dischargePort?.name,
      container.dischargePortName,
    );
    final vehicles = container.vehicles ?? <VehicleElement>[];
    final isPaid = _isPaid(container.allPaid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Container details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OverviewCard(
                containerNumber: _value(container.containerNo),
                bookingNumber: _value(container.bookingNo),
                status: status,
                shippingLine: shippingLine,
              ),
              const SizedBox(height: 24),
              const _SectionTitle(
                icon: Icons.inventory_2_outlined,
                title: 'Container information',
              ),
              const SizedBox(height: 10),
              _InfoCard(
                children: [
                  _InfoRow(
                    label: 'Booking number',
                    value: _value(container.bookingNo),
                    onCopy: () => _copyValue(
                      _value(container.bookingNo),
                      'Booking number',
                    ),
                  ),
                  _InfoRow(
                    label: 'Container number',
                    value: _value(container.containerNo),
                    onCopy: () => _copyValue(
                      _value(container.containerNo),
                      'Container number',
                    ),
                  ),
                  _InfoRow(
                    label: 'Status',
                    value: status,
                    valueColor: AppTheme.primary,
                    valueIcon: Icons.schedule_rounded,
                  ),
                  _InfoRow(
                    label: 'Vessel name',
                    value: _value(container.vesselName),
                  ),
                  _InfoRow(
                    label: 'Departure',
                    value: _date(container.departure),
                  ),
                  _InfoRow(
                    label: 'Arrival',
                    value: _date(container.arrival),
                  ),
                  _InfoRow(
                    label: 'Payment',
                    value: isPaid ? 'Paid' : 'Unpaid',
                    valueColor: isPaid ? AppTheme.success : AppTheme.warning,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping information',
              ),
              const SizedBox(height: 10),
              _InfoCard(
                children: [
                  _InfoRow(
                    label: 'Shipping line',
                    value: shippingLine,
                  ),
                  _InfoRow(
                    label: 'Consignee',
                    value: consigneeName,
                  ),
                  _InfoRow(
                    label: 'Address',
                    value: consigneeAddress,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle(
                icon: Icons.anchor_rounded,
                title: 'Route',
              ),
              const SizedBox(height: 10),
              _RouteCard(
                loadingPort: loadingPort,
                dischargePort: dischargePort,
                destinationPort: destinationPort,
              ),
              const SizedBox(height: 24),
              _DocumentsSection(
                documents:
                    container.containerDocuments ?? <ContainerDocument>[],
                documentUrl: _assetUrl,
                onPreview: containerController.saveNetworkFile,
                onDownload: containerController.saveNetworkFile,
              ),
              const SizedBox(height: 24),
              _ShareInformationSection(controller: containerController),
              const SizedBox(height: 24),
              _SectionTitle(
                icon: Icons.directions_car_outlined,
                title: 'Vehicles',
                trailing: '${vehicles.length}',
              ),
              const SizedBox(height: 10),
              if (vehicles.isEmpty)
                const _NoVehiclesCard()
              else
                ...vehicles.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key == vehicles.length - 1 ? 0 : 10,
                        ),
                        child: _VehicleCard(
                          index: entry.key + 1,
                          vehicle: entry.value,
                          displayValue: _value,
                          onCopy: _copyValue,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: ElevatedButton.icon(
            onPressed: _trackContainer,
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Track container'),
          ),
        ),
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

  final List<ContainerDocument> documents;
  final String Function(dynamic filepath, dynamic filename) documentUrl;
  final ValueChanged<String> onPreview;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    final visibleDocuments = documents
        .where((document) => document.title?.toString() != 'images')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.folder_copy_outlined,
          title: 'Documents',
          trailing: '${visibleDocuments.length}',
        ),
        const SizedBox(height: 10),
        Card(
          child: visibleDocuments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No documents available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleDocuments.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppTheme.border),
                  itemBuilder: (context, index) {
                    final document = visibleDocuments[index];
                    final url =
                        documentUrl(document.filepath, document.filename);
                    return ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        document.filename?.toString() ?? 'Document',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        document.filesize?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 96,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: 'Preview',
                              onPressed:
                                  url.isEmpty ? null : () => onPreview(url),
                              icon: const Icon(Icons.visibility_outlined),
                            ),
                            IconButton(
                              tooltip: 'Download',
                              onPressed:
                                  url.isEmpty ? null : () => onDownload(url),
                              icon: const Icon(Icons.download_rounded),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShareInformationSection extends StatelessWidget {
  const _ShareInformationSection({required this.controller});

  final ContainerController controller;

  String _value(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result.toLowerCase() == 'null' ? '-' : result;
  }

  String _date(dynamic value) {
    if (value == null) return '-';
    final parsed = DateTime.tryParse(value.toString());
    return parsed == null
        ? _value(value)
        : intl.DateFormat('MMM dd, yyyy hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.send_outlined,
          title: 'Share Information',
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: 'Enter recipient email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onSubmitted: (_) async => controller.sendContainerEmail(),
                ),
                const SizedBox(height: 8),
                Text(
                  'All attached documents will be included in the email',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.muted,
                      ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.sendingEmail.isTrue
                        ? null
                        : () async => controller.sendContainerEmail(),
                    icon: controller.sendingEmail.isTrue
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Email History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => controller.emailHistoryList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No email history available',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.muted,
                                ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.emailHistoryList.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppTheme.border),
                          itemBuilder: (context, index) {
                            final item = controller.emailHistoryList[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.mark_email_read_outlined,
                                color: AppTheme.primary,
                              ),
                              title: Text(_value(item.sentTo)),
                              subtitle: Text(_date(item.createdAt)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String containerNumber;
  final String bookingNumber;
  final String status;
  final String shippingLine;

  const _OverviewCard({
    required this.containerNumber,
    required this.bookingNumber,
    required this.status,
    required this.shippingLine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTAINER',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(.75),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        containerNumber,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _OverviewChip(
                icon: Icons.confirmation_number_outlined,
                label: bookingNumber,
              ),
              _OverviewChip(
                icon: Icons.schedule_rounded,
                label: status,
              ),
              _OverviewChip(
                icon: Icons.local_shipping_outlined,
                label: shippingLine,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OverviewChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 56;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(120.0, 420.0)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Color? valueColor;
  final IconData? valueIcon;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.valueColor,
    this.valueIcon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 330;
        final labelWidget = Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
        );
        final valueWidget = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (valueIcon != null) ...[
              Icon(
                valueIcon,
                size: 18,
                color: valueColor ?? AppTheme.ink,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ],
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: tight
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labelWidget,
                    const SizedBox(height: 6),
                    valueWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 112, child: labelWidget),
                    const SizedBox(width: 12),
                    Expanded(child: valueWidget),
                  ],
                ),
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String loadingPort;
  final String dischargePort;
  final String destinationPort;

  const _RouteCard({
    required this.loadingPort,
    required this.dischargePort,
    required this.destinationPort,
  });

  @override
  Widget build(BuildContext context) {
    final stops = <_RouteStop>[
      _RouteStop(label: 'Loading port', value: loadingPort),
      if (dischargePort != '—')
        _RouteStop(label: 'Discharge port', value: dischargePort),
      _RouteStop(label: 'Destination port', value: destinationPort),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: stops.asMap().entries.map((entry) {
            final isLast = entry.key == stops.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isLast ? AppTheme.primary : Colors.white,
                        shape: BoxShape.circle,
                        border:
                            isLast ? null : Border.all(color: AppTheme.border),
                      ),
                      child: Icon(
                        isLast
                            ? Icons.location_on_rounded
                            : Icons.radio_button_checked_rounded,
                        size: 17,
                        color: isLast ? Colors.white : AppTheme.primary,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: AppTheme.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.muted,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value.value,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RouteStop {
  final String label;
  final String value;

  const _RouteStop({required this.label, required this.value});
}

class _VehicleCard extends StatelessWidget {
  final int index;
  final VehicleElement vehicle;
  final String Function(dynamic value) displayValue;
  final Future<void> Function(String value, String label) onCopy;

  const _VehicleCard({
    required this.index,
    required this.vehicle,
    required this.displayValue,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final data = vehicle.vehicle;
    final descriptionParts = [
      displayValue(data?.modal),
      displayValue(data?.companyName),
      displayValue(data?.name),
    ].where((value) => value != '—').toList();
    final description = descriptionParts.isEmpty
        ? 'Vehicle information unavailable'
        : descriptionParts.join(' ');
    final vin = displayValue(data?.vin);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle $index',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'VIN  $vin',
                          softWrap: true,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Copy VIN',
                        onPressed: () => onCopy(vin, 'VIN'),
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
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

class _NoVehiclesCard extends StatelessWidget {
  const _NoVehiclesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.directions_car_outlined,
              color: AppTheme.muted,
            ),
            const SizedBox(width: 12),
            Text(
              'No vehicles are assigned to this container.',
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle_list_response.dart';
import '../styles/app_theme.dart';

class CarImagesScreen extends StatefulWidget {
  const CarImagesScreen({
    super.key,
    required this.vehicle,
    this.initialShowUnloading = false,
  });

  final Vehicle vehicle;
  final bool initialShowUnloading;

  @override
  State<CarImagesScreen> createState() => _CarImagesScreenState();
}

class _CarImagesScreenState extends State<CarImagesScreen> {
  final VehicleController _controller = Get.find<VehicleController>();
  bool _showUnloading = false;

  @override
  void initState() {
    super.initState();
    _showUnloading = widget.initialShowUnloading;
  }

  List<VehicleImage> get _warehouseImages {
    final images =
        (widget.vehicle.vehicleImages ?? <VehicleImage>[]).where((image) {
      final type = image.type?.toString().toLowerCase() ?? '';
      return type != 'unloading';
    }).toList();
    final pending = widget.vehicle.pendingImages?.images ?? <String>[];
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
    return (widget.vehicle.vehicleImages ?? <VehicleImage>[]).where((image) {
      return image.type?.toString().toLowerCase() == 'unloading';
    }).toList();
  }

  List<VehicleImage> get _visibleImages =>
      _showUnloading ? _unloadingImages : _warehouseImages;

  String _url(VehicleImage image) {
    final filename = image.filename?.toString().trim() ?? '';
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    final filepath = image.filepath?.toString().trim() ?? '';
    return 'https://s3.eu-north-1.amazonaws.com/kgautoexport/$filepath$filename';
  }

  String get _vehicleName {
    final values = [
      widget.vehicle.modal,
      widget.vehicle.companyName,
      widget.vehicle.name,
    ]
        .map((value) => value?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty && value.toLowerCase() != 'null');
    return values.isEmpty ? 'Vehicle photos' : values.join(' ');
  }

  Future<void> _downloadVisibleImages() {
    return _controller.saveNetworkImagesToGallery(
      _visibleImages.map(_url).toList(),
      albumName: 'KG Auto ${_showUnloading ? 'Unloading' : 'Warehouse'}',
    );
  }

  Future<void> _shareVisibleImages() {
    return _controller.shareNetworkImages(
      _visibleImages.map(_url).toList(),
      subject: 'KG Auto ${_showUnloading ? 'unloading' : 'warehouse'} photos',
    );
  }

  void _preview(VehicleImage image) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xE6000000),
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: .8,
                maxScale: 4,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: _url(image),
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (_, __, progress) =>
                        CircularProgressIndicator(
                      value: progress.progress,
                      color: Colors.white,
                    ),
                    errorWidget: (_, __, ___) => const _GalleryError(
                      dark: true,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton.filled(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: 'Download photo',
                  onPressed: () => _controller.saveNetworkImage(_url(image)),
                  icon: const Icon(Icons.download_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle photos'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _vehicleName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_visibleImages.length} '
                    '${_visibleImages.length == 1 ? 'photo' : 'photos'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EEF7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _GalleryTab(
                            icon: Icons.warehouse_outlined,
                            label: 'Warehouse',
                            count: _warehouseImages.length,
                            selected: !_showUnloading,
                            onTap: () => setState(() => _showUnloading = false),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _GalleryTab(
                            icon: Icons.local_shipping_outlined,
                            label: 'Unloading',
                            count: _unloadingImages.length,
                            selected: _showUnloading,
                            onTap: () => setState(() => _showUnloading = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_visibleImages.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Obx(() {
                      final downloading =
                          _controller.kDownloadingVehiclePhotos.isTrue;
                      final sharing = _controller.kSharingVehiclePhotos.isTrue;
                      final busy = downloading || sharing;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: busy ? null : _downloadVisibleImages,
                          icon: downloading
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 19),
                          label: Text(
                            downloading
                                ? 'Downloading photos...'
                                : 'Download all ${_showUnloading ? 'unloading' : 'warehouse'} photos',
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Obx(() {
                      final downloading =
                          _controller.kDownloadingVehiclePhotos.isTrue;
                      final sharing = _controller.kSharingVehiclePhotos.isTrue;
                      final busy = downloading || sharing;
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: busy ? null : _shareVisibleImages,
                          icon: sharing
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.share_rounded, size: 19),
                          label: Text(
                            sharing
                                ? 'Preparing photos...'
                                : 'Share all ${_showUnloading ? 'unloading' : 'warehouse'} photos',
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          if (_visibleImages.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyGallery(unloading: _showUnloading),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    final image = _visibleImages[index];
                    return _GalleryTile(
                      imageUrl: _url(image),
                      onOpen: () => _preview(image),
                      onDownload: () =>
                          _controller.saveNetworkImage(_url(image)),
                    );
                  },
                  childCount: _visibleImages.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.primary : AppTheme.muted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected ? AppTheme.primary : AppTheme.muted,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary.withOpacity(.1)
                      : AppTheme.border,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected ? AppTheme.primary : AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.imageUrl,
    required this.onOpen,
    required this.onDownload,
  });

  final String imageUrl;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (_, __, progress) => Center(
                child: CircularProgressIndicator(
                  value: progress.progress,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (_, __, ___) => const _GalleryError(),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Material(
                color: const Color(0xCC102A43),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Download photo',
                  onPressed: onDownload,
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryError extends StatelessWidget {
  const _GalleryError({this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark ? Colors.black : const Color(0xFFE7EEF7),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: dark ? Colors.white70 : AppTheme.muted,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            'Photo unavailable',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? Colors.white70 : AppTheme.muted,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.unloading});

  final bool unloading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EEF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 34,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No ${unloading ? 'unloading' : 'warehouse'} photos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Photos will appear here once they are uploaded.',
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

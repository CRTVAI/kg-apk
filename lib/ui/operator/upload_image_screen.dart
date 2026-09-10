import 'dart:io';
import 'dart:typed_data';

import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/models/image_file_model.dart';
import 'package:cargo/models/operator_container_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/ui/users/profile_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final AuthController _authController = Get.find();
  final UserController _userController = Get.find();
  final OperatorController _operatorController = Get.find();

  @override
  void dispose() {
    _operatorController.selectedFileList.clear();
    super.dispose();
  }

  bool get _isViewOnly {
    final level = _authController.loginResponse.value?.data.user.operatorLevel;
    return level == null || level.access == 'View only';
  }

  String get _operatorName {
    final value =
        _authController.loginResponse.value?.data.user.name?.toString().trim();
    return value == null || value.isEmpty ? 'Operator' : value;
  }

  String get _initials {
    final words = _operatorName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  void _openProfile() {
    final user = _authController.loginResponse.value?.data.user;
    if (user == null) return;
    _userController.selectedSubUser.value = user;
    _userController.populateUserData();
    Get.to(() => const ProfileScreen());
  }

  void _showCameraOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use camera',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a clear photo of the vehicle or container document.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.muted,
                      ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _operatorController.takePhotoFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take photo'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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
        title: const Text('Upload media'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Tooltip(
              message: 'Open profile',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _openProfile,
                child: CircleAvatar(
                  radius: 19,
                  backgroundColor: AppTheme.primary.withOpacity(.1),
                  child: Text(
                    _initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UploadHeader(name: _operatorName),
                  if (_isViewOnly) ...[
                    const SizedBox(height: 12),
                    const _ViewOnlyNotice(),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    '1. Select container',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(
                        () => DropdownSearch<OperatorContainer>(
                          items: _operatorController.containerList,
                          selectedItem:
                              _operatorController.selectedContainer.value,
                          enabled: !_isViewOnly,
                          itemAsString: (container) {
                            final number =
                                container.containerNo?.toString().trim() ?? '';
                            final booking =
                                container.bookingNo?.toString().trim() ?? '';
                            if (number.isNotEmpty) return number;
                            if (booking.isNotEmpty) return 'Booking $booking';
                            return 'Container #${container.id}';
                          },
                          compareFn: (a, b) => a.id == b.id,
                          clearButtonProps:
                              const ClearButtonProps(isVisible: true),
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search container number',
                                prefixIcon: Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Container',
                              hintText: 'Choose a container',
                              prefixIcon: Icon(
                                Icons.inventory_2_outlined,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            _operatorController.selectedContainer.value = value;
                            _operatorController.selectedContainer.refresh();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '2. Add photos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${_operatorController.selectedFileList.length} selected',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.muted,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Obx(() {
                        if (_operatorController.selectedFileList.isEmpty) {
                          return const _EmptyMediaSelection();
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth >= 620
                                ? 5
                                : constraints.maxWidth >= 420
                                    ? 4
                                    : 3;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  _operatorController.selectedFileList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                return _MediaTile(
                                  media: _operatorController
                                      .selectedFileList[index],
                                  onRemove: () {
                                    _operatorController.selectedFileList
                                        .removeAt(index);
                                  },
                                  thumbnailBuilder: _operatorController
                                      .generateThumbnailFromVideo,
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isViewOnly
                              ? null
                              : _operatorController.pickupFile,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isViewOnly ? null : _showCameraOptions,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _operatorController.showSuccessMessages.isTrue
                          ? const Padding(
                              key: ValueKey('upload-success'),
                              padding: EdgeInsets.only(top: 14),
                              child: _UploadSuccess(),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('upload-no-success'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final hasFiles =
                        _operatorController.selectedFileList.isNotEmpty;
                    if (_isViewOnly || !hasFiles) {
                      return const SizedBox.shrink();
                    }

                    return ElevatedButton.icon(
                      onPressed: _operatorController.kUploadingImage.isTrue
                          ? null
                          : _operatorController.uploadFileToContainer,
                      icon: _operatorController.kUploadingImage.isTrue
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        _operatorController.kUploadingImage.isTrue
                            ? 'Uploading...'
                            : 'Upload ${_operatorController.selectedFileList.length} ${_operatorController.selectedFileList.length == 1 ? 'photo' : 'photos'}',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(.75),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Attach vehicle photos to the correct container.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(.82),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewOnlyNotice extends StatelessWidget {
  const _ViewOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withOpacity(.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your account has view-only access. Upload controls are disabled.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMediaSelection extends StatelessWidget {
  const _EmptyMediaSelection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No photos selected',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose clear JPG or PNG images from the gallery or camera.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.media,
    required this.onRemove,
    required this.thumbnailBuilder,
  });

  final ImageFileModel media;
  final VoidCallback onRemove;
  final Future<Uint8List?> Function(File file) thumbnailBuilder;

  bool get _isVideo => p.extension(media.file.path).toLowerCase() == '.mp4';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: AppTheme.canvas,
            child: _isVideo
                ? FutureBuilder<Uint8List?>(
                    initialData: media.uint8list,
                    future: media.uint8list == null
                        ? thumbnailBuilder(media.file)
                        : null,
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      if (bytes == null) {
                        return const Icon(
                          Icons.videocam_outlined,
                          size: 34,
                          color: AppTheme.muted,
                        );
                      }
                      return Image.memory(bytes, fit: BoxFit.cover);
                    },
                  )
                : Image.file(
                    media.file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: AppTheme.muted,
                    ),
                  ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: AppTheme.ink.withOpacity(.78),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (_isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadSuccess extends StatelessWidget {
  const _UploadSuccess();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.success.withOpacity(.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload completed successfully.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/controllers/home_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:cargo/models/announcement_response.dart';
import 'package:cargo/ui/search/global_search_screen.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/ui/users/profile_screen.dart';
import 'package:cargo/ui/users/users_screen.dart';
import 'package:cargo/ui/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({
    super.key,
    this.searchTourKey,
    this.profileTourKey,
  });

  final GlobalKey? searchTourKey;
  final GlobalKey? profileTourKey;

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final AuthController _authController = Get.find();
  final VehicleController _vehicleController = Get.find();
  final UserController _userController = Get.find();
  final HomeController _homeController = Get.find();

  @override
  void initState() {
    super.initState();
    _refresh();
    _userController.getAllUsersList();
  }

  @override
  void dispose() {
    _vehicleController.clearPickupField();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait<void>([
      _homeController.getAnnouncements(),
      _vehicleController.getAllPickupRequest(),
      _homeController.loadShipmentOverview(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                12,
                AppTheme.pagePadding,
                28,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _buildTopBar(context),
                  const SizedBox(height: 10),
                  _buildWelcomeCard(context),
                  const SizedBox(height: 18),
                  _buildAnnouncementsCenter(context),
                  const SizedBox(height: 18),
                  const AppSectionHeader(
                    title: 'Shipment overview',
                    subtitle: 'Live status across your vehicle inventory',
                  ),
                  const SizedBox(height: 10),
                  _buildStatusSummary(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 56,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KG Auto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Logistics workspace',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          key: widget.searchTourKey,
          tooltip: 'Global search',
          onPressed: _openGlobalSearch,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: 'Refresh dashboard',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 2),
        PopupMenuButton<String>(
          tooltip: 'Account menu',
          onSelected: (value) {
            if (value == 'profile') _openProfile();
            if (value == 'subusers') Get.to(() => const UsersScreen());
            if (value == 'signout') _confirmSignOut(context);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'profile',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline_rounded),
                title: Text('Profile'),
              ),
            ),
            PopupMenuItem(
              value: 'subusers',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.group_outlined),
                title: Text('Sub-users'),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'signout',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout_rounded, color: AppTheme.danger),
                title: Text('Sign out'),
              ),
            ),
          ],
          child: Container(
            key: widget.profileTourKey,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primary.withOpacity(.12)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  void _openProfile() {
    final user = _authController.loginResponse.value!.data.user;
    _userController.selectedSubUser.value = user;
    _userController.populateUserData();
    Get.to(() => const ProfileScreen());
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to log in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _userController.signout();
    }
  }

  void _openGlobalSearch() {
    Get.to(() => const GlobalSearchScreen());
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final user = _authController.loginResponse.value!.data.user;
    final displayName = '${user.name}'.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -44,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      displayName.isEmpty ? 'KG Auto user' : displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 15,
                          color: Colors.white.withOpacity(.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Secure logistics dashboard',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withOpacity(.88),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.14),
                  border: Border.all(color: Colors.white.withOpacity(.25)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.white,
                  size: 31,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(BuildContext context) {
    return Obx(() {
      final loading = _homeController.kShipmentOverviewLoading.isTrue;
      return Row(
        children: [
          Expanded(
            child: _StatusCard(
              label: 'At terminal',
              count: _homeController.terminalOverviewCount.value,
              loading: loading,
              icon: Icons.warehouse_outlined,
              color: AppTheme.primary,
              onTap: () => _openVehicles(1),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _StatusCard(
              label: 'Shipped',
              count: _homeController.shippedOverviewCount.value,
              loading: loading,
              icon: Icons.directions_boat_outlined,
              color: AppTheme.accent,
              onTap: () => _openVehicles(5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _StatusCard(
              label: 'Delivered',
              count: _homeController.deliveredOverviewCount.value,
              loading: loading,
              icon: Icons.task_alt_rounded,
              color: AppTheme.success,
              onTap: () => _openVehicles(6),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAnnouncementsCenter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => Row(
              children: [
                const AppIconTile(
                  icon: Icons.campaign_outlined,
                  size: 38,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'News & Updates',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _homeController.announcements.isEmpty
                            ? 'Website announcements'
                            : '${_homeController.announcements.length} active updates',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh announcements',
                  onPressed: _homeController.getAnnouncements,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_homeController.kAnnouncementsLoading.isTrue &&
                _homeController.announcements.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(22),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (_homeController.announcements.isEmpty) {
              return const AppEmptyState(
                icon: Icons.campaign_outlined,
                title: 'All caught up',
                message: 'No active announcements are waiting for you.',
              );
            }

            return Column(
              children: _homeController.announcements
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AnnouncementCard(
                        item: item,
                        onOpen: () => _showAnnouncement(item),
                        onRead: () =>
                            _homeController.markAnnouncementAsRead(item),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  void _showAnnouncement(AnnouncementItem item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppIconTile(icon: Icons.campaign_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _plainText(item.description),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    _homeController.markAnnouncementAsRead(item);
                  },
                  icon: const Icon(Icons.done_rounded),
                  label: const Text('Mark as read'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openVehicles(int tabIndex) {
    _homeController.selectedIndex.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vehicleController.openVehicleStatusFromDashboard(tabIndex);
    });
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.count,
    required this.loading,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool loading;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored accent top bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(height: 10),
                    loading
                        ? SizedBox(
                            width: 24,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: color,
                            ),
                          )
                        : Text(
                            '$count',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 26,
                                  height: 1,
                                ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.onOpen,
    required this.onRead,
  });

  final AnnouncementItem item;
  final VoidCallback onOpen;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent stripe
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                size: 16,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _plainText(item.description),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.muted,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: onOpen,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon:
                                  const Icon(Icons.article_outlined, size: 15),
                              label: const Text('Read more'),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: onRead,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.done_rounded, size: 15),
                              label: const Text('Mark read'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _plainText(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

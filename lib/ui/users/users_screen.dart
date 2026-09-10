import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/models/login_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/ui/users/add_user_screen.dart';
import 'package:cargo/ui/widgets/app_widgets.dart';
import 'package:cargo/utils/global_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserController _userController = Get.find();

  @override
  void initState() {
    super.initState();
    _userController.getAllUsersList();
  }

  void _openAddUser() {
    _userController.clearField();
    Get.to(() => const AddUserScreen(isEdit: false));
  }

  void _openUserProfile(AppUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _UserProfileSheet(user: user),
    );
  }

  Future<void> _confirmDelete(AppUser user) async {
    final name = user.surname?.toString().trim().isNotEmpty == true
        ? user.surname.toString()
        : user.name?.toString() ?? 'this sub-user';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete sub-user?'),
          content: Text(
            'Are you sure you want to delete "$name"? This will also remove their vehicle assignments.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            Obx(
              () => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                ),
                onPressed: _userController.kDeletingSubUser.isTrue
                    ? null
                    : () => Navigator.of(dialogContext).pop(true),
                icon: _userController.kDeletingSubUser.isTrue
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await _userController.deleteSubUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub-users'),
        actions: [
          IconButton(
            tooltip: 'Refresh users',
            onPressed: _userController.getAllUsersList,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(controller: _userController),
              const SizedBox(height: 20),
              Obx(
                () => Row(
                  children: [
                    Text(
                      'Team members',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    _CountBadge(
                        count: _userController.filterSubUserList.length),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _openAddUser,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add user'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (_userController.kIsLoading.isTrue) {
                    return getLoading();
                  }

                  if (_userController.filterSubUserList.isEmpty) {
                    return _EmptyUsers(onAddUser: _openAddUser);
                  }

                  return RefreshIndicator(
                    onRefresh: _userController.getAllUsersList,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _userController.filterSubUserList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _UserCard(
                          user: _userController.filterSubUserList[index],
                          onViewProfile: () => _openUserProfile(
                            _userController.filterSubUserList[index],
                          ),
                          onDelete: () => _confirmDelete(
                            _userController.filterSubUserList[index],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddUser,
        tooltip: 'Add user',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final UserController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchStringController,
      onChanged: controller.onChangeHandler,
      onSubmitted: (_) => controller.searchByUserName(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by username',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Search',
          onPressed: controller.searchByUserName,
          icon: const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count ${count == 1 ? 'user' : 'users'}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onViewProfile,
    required this.onDelete,
  });

  final AppUser user;
  final VoidCallback onViewProfile;
  final VoidCallback onDelete;

  String get _initials {
    final words = '${user.name ?? ''}'
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  String _display(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewProfile,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primary.withOpacity(.1),
                child: Text(
                  _initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _display(user.name, 'Unnamed user'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          size: 16,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _display(user.email, 'No email address'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.muted,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (_display(user.company, '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 16,
                            color: AppTheme.muted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _display(user.company, ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    tooltip: 'View profile',
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  IconButton(
                    tooltip: 'Delete sub-user',
                    onPressed: onDelete,
                    color: AppTheme.danger,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileSheet extends StatelessWidget {
  const _UserProfileSheet({required this.user});

  final AppUser user;

  String _value(dynamic value) => value?.toString().trim() ?? '';

  String get _initials {
    final words = _value(user.name)
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      minChildSize: .45,
      maxChildSize: .92,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close profile',
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primarySoft,
                        child: Text(
                          _initials,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primary,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _value(user.name).isEmpty
                                  ? 'Unnamed user'
                                  : _value(user.name),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Sub-user profile',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      const AppStatusBadge(
                        label: 'Team',
                        color: AppTheme.success,
                        icon: Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Account details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          AppInfoRow(
                            label: 'Username',
                            value: _value(user.surname),
                            icon: Icons.alternate_email_rounded,
                            copyable: true,
                          ),
                          const Divider(height: 1),
                          AppInfoRow(
                            label: 'Email',
                            value: _value(user.email),
                            icon: Icons.mail_outline_rounded,
                            copyable: true,
                          ),
                          const Divider(height: 1),
                          AppInfoRow(
                            label: 'Company',
                            value: _value(user.company),
                            icon: Icons.business_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Contact details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          AppInfoRow(
                            label: 'Phone',
                            value: _value(user.phone),
                            icon: Icons.phone_outlined,
                            copyable: true,
                          ),
                          const Divider(height: 1),
                          AppInfoRow(
                            label: 'Country',
                            value: _value(user.country),
                            icon: Icons.public_rounded,
                          ),
                          if (_value(user.address).isNotEmpty) ...[
                            const Divider(height: 1),
                            AppInfoRow(
                              label: 'Address',
                              value: _value(user.address),
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Profile details are read-only in the current account API.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyUsers extends StatelessWidget {
  const _EmptyUsers({required this.onAddUser});

  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_outlined,
                  size: 34,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No sub-users found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Try another search or add a team member.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.muted,
                    ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onAddUser,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Add sub-user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

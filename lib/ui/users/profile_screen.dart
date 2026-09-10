import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = Get.find();
  final AuthController _authController = Get.find();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _userController.populateUserProfile();
    final country =
        _authController.loginResponse.value?.data.user.country?.toString();
    if (country != null && country.trim().isNotEmpty) {
      _userController.countryString.value = country;
    }
  }

  @override
  void dispose() {
    _userController.clearUserProfile();
    super.dispose();
  }

  bool get _canEditProfile =>
      _authController.loginResponse.value?.data.user.userLevel != null;

  String get _displayName {
    final value =
        _authController.loginResponse.value?.data.user.name?.toString().trim();
    return value == null || value.isEmpty ? 'KG Auto user' : value;
  }

  String get _email {
    final value =
        _authController.loginResponse.value?.data.user.email?.toString().trim();
    return value == null || value.isEmpty ? 'No email address' : value;
  }

  String get _initials {
    final words = _displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  void _showCountrySelector() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (country) {
        _userController.countryString.value = country.name;
        _userController.phoneCodeString.value = '+${country.phoneCode}';
        _userController.initialCountry.value = country.countryCode;
      },
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          labelText: 'Search country',
          hintText: 'Start typing a country name',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: AppTheme.danger,
          size: 30,
        ),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need your account credentials to sign in again.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      _userController.signout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(
                      initials: _initials,
                      name: _displayName,
                      email: _email,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Account information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _ProfileSection(
                      children: [
                        _ProfileField(
                          controller: _userController.usernameController,
                          label: 'Username',
                          icon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.next,
                          enabled: _canEditProfile,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _userController.nameController,
                          label: 'Full name',
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          enabled: _canEditProfile,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _userController.emailController,
                          label: 'Email address',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: _canEditProfile,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _userController.companyController,
                          label: 'Company',
                          icon: Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          enabled: _canEditProfile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Contact information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _ProfileSection(
                      children: [
                        Obx(
                          () => InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap:
                                _canEditProfile ? _showCountrySelector : null,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Country',
                                prefixIcon: const Icon(Icons.public_rounded),
                                suffixIcon: _canEditProfile
                                    ? const Icon(Icons.expand_more_rounded)
                                    : null,
                                enabled: _canEditProfile,
                              ),
                              child: Text(
                                _userController.countryString.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 116,
                              child: Obx(
                                () => CountryCodePicker(
                                  key: ValueKey(
                                    _userController.initialCountry.value,
                                  ),
                                  enabled: _canEditProfile,
                                  onChanged: (value) {
                                    _userController.phoneCodeString.value =
                                        value.dialCode ?? '';
                                  },
                                  onInit: (value) {
                                    if (_userController
                                        .phoneCodeString.value.isEmpty) {
                                      _userController.phoneCodeString.value =
                                          value?.dialCode ?? '';
                                    }
                                  },
                                  initialSelection:
                                      _userController.initialCountry.value,
                                  favorite: const ['+962', 'JO', '+1', 'US'],
                                  padding: EdgeInsets.zero,
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: true,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileField(
                                controller: _userController.phoneController,
                                label: 'Phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                enabled: _canEditProfile,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_canEditProfile) ...[
                      const SizedBox(height: 22),
                      Text(
                        'Security',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      _ProfileSection(
                        children: [
                          _ProfileField(
                            controller: _userController.oldPasswordController,
                            label: 'Current password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureCurrentPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ProfileField(
                            controller: _userController.passwordController,
                            label: 'New password',
                            icon: Icons.password_rounded,
                            obscureText: _obscureNewPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave the new password empty if you do not want to change it.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.muted,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => ElevatedButton.icon(
                          onPressed: _userController.kUpdateProfileInfo.isTrue
                              ? null
                              : _userController.updateUserInfo,
                          icon: _userController.kUpdateProfileInfo.isTrue
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _userController.kUpdateProfileInfo.isTrue
                                ? 'Saving changes...'
                                : 'Save changes',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _confirmSignOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppTheme.danger,
                        side: const BorderSide(color: AppTheme.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
  });

  final String initials;
  final String name;
  final String email;

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
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(.8),
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

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

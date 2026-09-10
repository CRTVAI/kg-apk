import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key, required this.isEdit});

  final bool isEdit;

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final UserController _userController = Get.find();
  bool _obscurePassword = true;

  void _showCountrySelector() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (country) {
        _userController.countryString.value = country.name;
        _userController.phoneCodeString.value = '+${country.phoneCode}';
        _userController.initialCountry.value = country.countryCode;
      },
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.of(context).size.height * .72,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: const InputDecoration(
          labelText: 'Search country',
          hintText: 'Start typing a country name',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Update user' : 'Add sub-user'),
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntroBanner(isEdit: widget.isEdit),
                    const SizedBox(height: 20),
                    Text(
                      'Account details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      children: [
                        _AppTextField(
                          controller: _userController.usernameController,
                          label: 'Username',
                          hint: 'Enter a unique username',
                          icon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _AppTextField(
                          controller: _userController.passwordController,
                          label: 'Password',
                          hint: 'Create a secure password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AppTextField(
                          controller: _userController.emailController,
                          label: 'Email address',
                          hint: 'name@company.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _AppTextField(
                          controller: _userController.nameController,
                          label: 'Full name',
                          hint: 'Enter the user’s full name',
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Contact details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _SectionCard(
                      children: [
                        Obx(
                          () => InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _showCountrySelector,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                prefixIcon: Icon(Icons.public_rounded),
                                suffixIcon: Icon(Icons.expand_more_rounded),
                              ),
                              child: Text(
                                _userController.countryString.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 118,
                              child: Obx(
                                () => CountryCodePicker(
                                  key: ValueKey(
                                    _userController.initialCountry.value,
                                  ),
                                  onChanged: (value) {
                                    _userController.phoneCodeString.value =
                                        value.dialCode ?? '';
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
                              child: _AppTextField(
                                controller: _userController.phoneController,
                                label: 'Phone number',
                                hint: 'Phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _AppTextField(
                          controller: _userController.companyController,
                          label: 'Company',
                          hint: 'Company name (optional)',
                          icon: Icons.business_outlined,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: _userController.kIsAddingUser.isTrue
                            ? null
                            : _userController.addUser,
                        icon: _userController.kIsAddingUser.isTrue
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.isEdit
                                    ? Icons.save_outlined
                                    : Icons.person_add_alt_1_rounded,
                              ),
                        label: Text(
                          _userController.kIsAddingUser.isTrue
                              ? 'Saving user...'
                              : widget.isEdit
                                  ? 'Update user'
                                  : 'Add sub-user',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                        ),
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

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEdit
                  ? Icons.manage_accounts_outlined
                  : Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Update account access' : 'Invite a team member',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEdit
                      ? 'Keep the user’s access and contact details current.'
                      : 'Create secure access to vehicles and shipments.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(.82),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

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

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

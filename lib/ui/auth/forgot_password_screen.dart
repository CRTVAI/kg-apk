import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _authController.kForgotPasswordSubmitted(false);
    final currentUsername = _authController.emailController.text.trim();
    if (currentUsername.contains('@') &&
        _authController.forgotPasswordEmailController.text.trim().isEmpty) {
      _authController.forgotPasswordEmailController.text = currentUsername;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('forgot_password_title'.tr),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFD), AppTheme.canvas],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 44,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Obx(
                            () => _authController
                                    .kForgotPasswordSubmitted.isTrue
                                ? _buildSuccessState()
                                : _buildRequestForm(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm() {
    final isLoading = _authController.kForgotPasswordLoading.isTrue;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            icon: Icons.mark_email_unread_outlined,
            title: 'reset_your_password'.tr,
            subtitle: 'forgot_password_help'.tr,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _authController.forgotPasswordEmailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _authController.forgotPassword(),
            decoration: InputDecoration(
              labelText: 'email_address'.tr,
              hintText: 'email_address_hint'.tr,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: isLoading ? null : _authController.forgotPassword,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              isLoading ? 'sending_reset_link'.tr : 'send_reset_link'.tr,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: isLoading ? null : () => Get.back(),
            icon: const Icon(Icons.login_rounded),
            label: Text('back_to_sign_in'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          icon: Icons.check_circle_outline_rounded,
          title: 'check_your_email'.tr,
          subtitle: 'reset_link_sent_help'.tr,
          iconColor: AppTheme.success,
          iconBackground: AppTheme.successSoft,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.login_rounded),
          label: Text('back_to_sign_in'.tr),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _authController.forgotPassword,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('resend_reset_link'.tr),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppTheme.primary,
    this.iconBackground = AppTheme.primarySoft,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
              ),
        ),
      ],
    );
  }
}

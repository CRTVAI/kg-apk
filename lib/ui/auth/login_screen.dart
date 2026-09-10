import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/ui/auth/forgot_password_screen.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFD), AppTheme.canvas],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandHeader(context),
                          const SizedBox(height: 24),
                          _buildLoginCard(context),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: AppTheme.muted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Secure access to your logistics workspace',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildBrandHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue to KG Auto',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
              ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Obx(() {
          if (_authController.kLoginComplete.isTrue) {
            return const SizedBox(
              height: 260,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Signing you in...'),
                ],
              ),
            );
          }

          return AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4EDFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure access',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Use your KG Auto account',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _authController.emailController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(
                    labelText: 'user_name'.tr,
                    hintText: 'user_name_hint'.tr,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authController.passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  obscureText: !_authController.kIsPasswordVisible.value,
                  onFieldSubmitted: (_) => _authController.loginForm(),
                  decoration: InputDecoration(
                    labelText: 'password'.tr,
                    hintText: 'password_hint'.tr,
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      tooltip: _authController.kIsPasswordVisible.isTrue
                          ? 'Hide password'
                          : 'Show password',
                      onPressed: _authController.kIsPasswordVisible.toggle,
                      icon: Icon(
                        _authController.kIsPasswordVisible.isTrue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Get.to(
                      () => const ForgotPasswordScreen(),
                    ),
                    child: Text(
                      'forgot_password'.tr,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _authController.loginForm,
                  icon: const Icon(Icons.login_rounded),
                  label: Text('sign_in'.tr),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

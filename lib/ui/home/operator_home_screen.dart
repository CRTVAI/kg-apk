import 'dart:async';

import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/ui/operator/pickup_requests_screen.dart';
import 'package:cargo/ui/operator/upload_image_screen.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:cargo/utils/local_push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final OperatorController _operatorController = Get.find();
  final List<Widget> _screens = const [
    UploadImageScreen(),
    PickupRequestsScreen(),
  ];

  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    _messageSubscription = FirebaseMessaging.onMessage.listen(
      LocalNotificationService.display,
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_operatorController.selectedNavigationIndex.value == 0) return true;
    _operatorController.showUploads();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(
        () {
          final selectedIndex =
              _operatorController.selectedNavigationIndex.value.clamp(0, 1);
          return Scaffold(
            body: IndexedStack(
              index: selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.border)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x120F2F50),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  height: 70,
                  selectedIndex: selectedIndex,
                  backgroundColor: AppTheme.surface,
                  indicatorColor: AppTheme.accent.withOpacity(.12),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) {
                    _operatorController.selectedNavigationIndex.value = index;
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.cloud_upload_outlined),
                      selectedIcon: Icon(
                        Icons.cloud_upload_rounded,
                        color: AppTheme.primary,
                      ),
                      label: 'Upload',
                      tooltip: 'Upload container photos',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.local_shipping_outlined),
                      selectedIcon: Icon(
                        Icons.local_shipping_rounded,
                        color: AppTheme.primary,
                      ),
                      label: 'Pickup requests',
                      tooltip: 'Manage pickup requests',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

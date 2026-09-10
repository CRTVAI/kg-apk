import 'dart:async';

import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/controllers/home_controller.dart';
import 'package:cargo/ui/car/car_screen.dart';
import 'package:cargo/ui/car/my_car_screen.dart';
import 'package:cargo/ui/container/container_screen.dart';
import 'package:cargo/ui/pickup/pickup_history_screen.dart';
import 'package:cargo/ui/transactions/transactions_screen.dart';
import 'package:cargo/utils/local_push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController = Get.find();
  final AuthController _authController = Get.find();
  StreamSubscription<RemoteMessage>? _messageSubscription;
  final GlobalKey _searchTourKey = GlobalKey();
  final GlobalKey _profileTourKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();
  int _tourStep = -1;
  Rect? _tourTarget;
  bool _tourReady = false;

  static const List<NavigationDestination> _allDestinations = [
    NavigationDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car_rounded),
        label: 'Vehicles'),
    NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2_rounded),
        label: 'Containers'),
    NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Home'),
    NavigationDestination(
        icon: Icon(Icons.history_rounded),
        selectedIcon: Icon(Icons.manage_history_rounded),
        label: 'Pickup'),
    NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet_rounded),
        label: 'Finance'),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();
    _messageSubscription =
        FirebaseMessaging.onMessage.listen(LocalNotificationService.display);
    _maybeStartTour();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _maybeStartTour() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authController.loginResponse.value?.data.user.id ?? 'user';
    final key = 'kg_auto_mobile_tour_seen_$userId';
    if (prefs.getBool(key) == true) return;
    homeController.selectedIndex.value = 2;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _tourReady = true;
        _tourStep = 0;
        _tourTarget = _targetRect(_searchTourKey);
      });
    });
  }

  Rect? _targetRect(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Rect? _pickupTargetRect() {
    final context = _bottomNavKey.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    final hasFinance =
        _authController.loginResponse.value!.data.user.role == '2';
    final destinationCount = hasFinance ? 5 : 4;
    final width = box.size.width / destinationCount;
    return Rect.fromLTWH(
      origin.dx + width * 3,
      origin.dy,
      width,
      box.size.height,
    );
  }

  Future<void> _finishTour() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _authController.loginResponse.value?.data.user.id ?? 'user';
    await prefs.setBool('kg_auto_mobile_tour_seen_$userId', true);
    if (!mounted) return;
    setState(() {
      _tourStep = -1;
      _tourTarget = null;
    });
  }

  void _nextTourStep() {
    if (_tourStep == 0) {
      setState(() {
        _tourStep = 1;
        _tourTarget = _targetRect(_profileTourKey);
      });
      return;
    }
    if (_tourStep == 1) {
      setState(() {
        _tourStep = 2;
        _tourTarget = _pickupTargetRect();
      });
      return;
    }
    _finishTour();
  }

  Future<bool> _onWillPop() async {
    if (homeController.selectedIndex.value == 2) return true;
    homeController.selectedIndex.value = 2;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hasFinance =
        _authController.loginResponse.value!.data.user.role == '2';
    final destinations =
        hasFinance ? _allDestinations : _allDestinations.take(4).toList();

    return Obx(() {
      final allScreens = <Widget>[
        const MyCarScreen(),
        const ContainerScreen(),
        CarScreen(
          searchTourKey: _searchTourKey,
          profileTourKey: _profileTourKey,
        ),
        const PickupHistoryScreen(),
        const TransactionsScreen(),
      ];
      final screens = hasFinance ? allScreens : allScreens.take(4).toList();
      final selected = homeController.selectedIndex.value < screens.length
          ? homeController.selectedIndex.value
          : 2;
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Scaffold(
              body: IndexedStack(index: selected, children: screens),
              bottomNavigationBar: DecoratedBox(
                key: _bottomNavKey,
                decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(top: BorderSide(color: AppTheme.border))),
                child: NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) =>
                      homeController.selectedIndex.value = index,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: destinations,
                ),
              ),
            ),
            if (_tourReady && _tourStep >= 0)
              _AppTourOverlay(
                target: _tourTarget,
                step: _tourStep,
                onNext: _nextTourStep,
                onSkip: _finishTour,
              ),
          ],
        ),
      );
    });
  }
}

class _AppTourOverlay extends StatelessWidget {
  const _AppTourOverlay({
    required this.target,
    required this.step,
    required this.onNext,
    required this.onSkip,
  });

  final Rect? target;
  final int step;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  static const _titles = [
    'Search everything',
    'Account menu',
    'Pickup history',
  ];

  static const _descriptions = [
    'Use Global Search to quickly find vehicles, containers, and pickup requests by VIN, container number, booking number, status, or related details.',
    'Open your account menu here to view your profile, manage sub-users, and sign out securely when needed.',
    'The Pickup menu shows your pickup request history, filters, document actions, and the button to create a new pickup request.',
  ];

  @override
  Widget build(BuildContext context) {
    final targetRect = target;
    final screen = MediaQuery.of(context).size;
    final cardTop = targetRect == null
        ? screen.height * .22
        : targetRect.center.dy < screen.height * .55
            ? (targetRect.bottom + 18).clamp(24.0, screen.height - 260)
            : (targetRect.top - 214).clamp(24.0, screen.height - 260);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TourScrimPainter(targetRect),
            ),
          ),
          if (targetRect != null)
            Positioned.fromRect(
              rect: targetRect.inflate(8),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(.38),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 18,
            right: 18,
            top: cardTop,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.22),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primarySoft,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          step == 0
                              ? Icons.search_rounded
                              : step == 1
                                  ? Icons.person_outline_rounded
                                  : Icons.manage_history_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _titles[step],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${step + 1}/3',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.muted,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _descriptions[step],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onSkip,
                        child: const Text('Skip tour'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: onNext,
                        icon: Icon(
                          step == 2
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: Text(step == 2 ? 'Finish' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourScrimPainter extends CustomPainter {
  const _TourScrimPainter(this.target);

  final Rect? target;

  @override
  void paint(Canvas canvas, Size size) {
    final screenPath = Path()..addRect(Offset.zero & size);
    final targetRect = target;
    final paint = Paint()..color = Colors.black.withOpacity(.68);

    if (targetRect == null) {
      canvas.drawPath(screenPath, paint);
      return;
    }

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(10),
          const Radius.circular(18),
        ),
      );
    final path = Path.combine(PathOperation.difference, screenPath, hole);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TourScrimPainter oldDelegate) {
    return oldDelegate.target != target;
  }
}

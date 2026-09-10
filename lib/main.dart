import 'dart:async';

import 'package:cargo/controllers/container_controller.dart';
import 'package:cargo/controllers/home_controller.dart';
import 'package:cargo/controllers/operator_controller.dart';
import 'package:cargo/controllers/transaction_controller.dart';
import 'package:cargo/controllers/user_controller.dart';
import 'package:cargo/controllers/vehicle_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'controllers/auth_controller.dart';
import 'firebase_options.dart';
import 'localizations/languages.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/styles/app_theme.dart';
import 'utils/push_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// On click listner
  // navigateToDetailsPage(message);
}
navigateToDetailsPage(RemoteMessage message) {
  PushNotificationService().navigateToDetailsPage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppTheme.canvas,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService().setupInteractedMessage();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
  await Permission.notification.isDenied.then(
    (bool value) {
      if (value) {
        Permission.notification.request();
      }
    },
  );
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
    Timer(Duration(seconds: 3), () {
      navigateToDetailsPage(initialMessage);
    });

    // print(initialMessage.data);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(HomeController());
    Get.put(UserController());
    Get.put(VehicleController());
    Get.put(ContainerController());
    Get.put(TransactionController());
    Get.put(OperatorController());

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          locale: Locale('en', 'US'),
          translations: Languages(),
          fallbackLocale: Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          title: "appname".tr,
          theme: AppTheme.light(),
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}

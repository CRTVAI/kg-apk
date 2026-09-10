import 'package:cargo/controllers/auth_controller.dart';
import 'package:cargo/localizations/languages.dart';
import 'package:cargo/ui/auth/login_screen.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _compactPhoneSizes = <Size>[
  Size(320, 568),
  Size(360, 640),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  for (final size in _compactPhoneSizes) {
    testWidgets(
      'login screen has no overflow at ${size.width.toInt()}px',
      (tester) async {
        _setLogicalScreenSize(tester, size);
        Get.put<AuthController>(AuthController());

        await _pumpOfflineApp(
          tester,
          home: const LoginScreen(),
        );

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Secure access'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Sign in'), findsOneWidget);
        _expectNoFlutterException(tester);
      },
    );
  }
}

void _setLogicalScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = 1;

  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Future<void> _pumpOfflineApp(
  WidgetTester tester, {
  required Widget home,
}) async {
  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Languages(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: _offlineTheme(),
      home: home,
    ),
  );
  await tester.pump();
}

void _expectNoFlutterException(WidgetTester tester) {
  expect(
    tester.takeException(),
    isNull,
    reason: 'The compact layout must not report overflow or build errors.',
  );
}

ThemeData _offlineTheme() {
  final textTheme = ThemeData.light().textTheme.copyWith(
        headlineSmall: const TextStyle(
          color: AppTheme.ink,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: const TextStyle(
          color: AppTheme.ink,
          fontSize: 18,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: const TextStyle(
          color: AppTheme.ink,
          fontSize: 15,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: const TextStyle(
          color: AppTheme.ink,
          fontSize: 13.5,
          height: 1.45,
        ),
        bodySmall: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11.5,
          height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontSize: 13.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: const TextStyle(
          fontSize: 11.5,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
      );

  OutlineInputBorder inputBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppTheme.canvas,
    colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
    textTheme: textTheme,
    cardTheme: CardTheme(
      color: AppTheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: const BorderSide(color: AppTheme.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTheme.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: inputBorder(AppTheme.border),
      enabledBorder: inputBorder(AppTheme.border),
      focusedBorder: inputBorder(AppTheme.primary, 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

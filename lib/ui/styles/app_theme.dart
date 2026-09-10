import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0B4F9C);
  static const Color primaryDark = Color(0xFF073B78);
  static const Color accent = Color(0xFF315FE9);
  static const Color canvas = Color(0xFFF3F6FA);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF8FAFD);
  static const Color ink = Color(0xFF102A43);
  static const Color muted = Color(0xFF6B7C93);
  static const Color border = Color(0xFFE0E7F0);
  static const Color primarySoft = Color(0xFFEAF1FC);
  static const Color success = Color(0xFF07845F);
  static const Color successSoft = Color(0xFFE5F6F0);
  static const Color warning = Color(0xFFA66500);
  static const Color warningSoft = Color(0xFFFFF4DB);
  static const Color danger = Color(0xFFCA3C4A);
  static const Color dangerSoft = Color(0xFFFDEBED);

  static const double pagePadding = 16;
  static const double cardRadius = 16;

  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final textTheme = baseTextTheme.copyWith(
      displaySmall: GoogleFonts.inter(
        color: ink,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      headlineSmall: GoogleFonts.inter(
        color: ink,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.inter(
        color: ink,
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.inter(
        color: ink,
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: GoogleFonts.inter(
        color: ink,
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(
        color: ink,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: ink,
        fontSize: 13.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: muted,
        fontSize: 11.5,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13.5,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: GoogleFonts.inter(
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

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: ink,
      error: danger,
      onError: Colors.white,
      outline: border,
      outlineVariant: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      textTheme: textTheme,
      dividerColor: border,
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        titleSpacing: pagePadding,
        toolbarHeight: 60,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: ink, size: 22),
        actionsIconTheme: const IconThemeData(color: ink, size: 22),
      ),
      cardTheme: CardTheme(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: muted,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 1.5),
        errorBorder: inputBorder(danger),
        focusedErrorBorder: inputBorder(danger, 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: border,
          disabledForegroundColor: muted,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        disabledColor: surfaceAlt,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        labelStyle: textTheme.labelMedium?.copyWith(color: ink),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(MaterialState.selected) ? primary : muted,
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(MaterialState.selected) ? primary : muted,
            fontWeight: states.contains(MaterialState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: muted,
        textColor: ink,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        minLeadingWidth: 22,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        insetPadding: const EdgeInsets.all(pagePadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}

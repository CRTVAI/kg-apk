import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

Color kcPrimaryGradient = AppTheme.primary;
Color kcSecondaryGradient = AppTheme.accent;
Color kcBackGroundGradient = AppTheme.canvas;
Color kcSecondaryColor = AppTheme.muted;
LinearGradient kcVerticalGradient = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
  colors: [
    AppTheme.primary,
    AppTheme.accent,
  ],
);

const kdPadding = AppTheme.pagePadding;
const kdBorderRadius = AppTheme.cardRadius;

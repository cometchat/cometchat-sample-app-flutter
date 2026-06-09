import 'package:flutter/material.dart';

/// Breakpoints for responsive layout.
///
/// On web/desktop (width >= [kDesktopBreakpoint]), the app shows a split-pane
/// layout: left panel (list) + right panel (detail).
/// On mobile (width < [kDesktopBreakpoint]), the app uses full-screen push
/// navigation as before.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Width at which we switch from mobile (full-screen) to desktop (split-pane).
  static const double kDesktopBreakpoint = 700;

  /// Fixed width of the left panel in desktop mode.
  static const double kLeftPanelWidth = 380;

  /// Fixed width of the right panel (search, etc.) in desktop mode.
  static const double kRightPanelWidth = 320;
}

/// Returns true if the current screen width qualifies as desktop/web layout.
bool isDesktopLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.kDesktopBreakpoint;
}

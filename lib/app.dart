import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'state/app_state_scope.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class Back2MeApp extends StatelessWidget {
  final AppState appState;
  const Back2MeApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        title: 'Back2me',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: (context, child) {
          final content = _MaxWidthWrapper(child: child ?? const SizedBox.shrink());
          return DevicePreview.appBuilder(context, content);
        },
        home: const LoginScreen(),
      ),
    );
  }
}

/// Keeps the mobile-first layout centered with a sensible max width on
/// wider (tablet/desktop) browser windows, per the responsive requirements,
/// without changing the visual identity of any screen.
class _MaxWidthWrapper extends StatelessWidget {
  final Widget child;
  const _MaxWidthWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child),
      ),
    );
  }
}

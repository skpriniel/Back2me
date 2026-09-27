import 'package:flutter/widgets.dart';
import 'app_state.dart';

/// Makes [AppState] available to the widget tree and triggers a rebuild
/// of any dependent widget whenever the state notifies listeners. This is
/// the app's single, simple state-management mechanism (no external
/// package required).
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  final appState = AppState();
  await appState.load();

  runApp(
    DevicePreview(
      // Set to false to hide the device-preview frame in production.
      enabled: true,
      builder: (context) => Back2MeApp(appState: appState),
    ),
  );
}

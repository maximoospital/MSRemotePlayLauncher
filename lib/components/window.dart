import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void WindowSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    title: "Maxi's Remote Play Launcher",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.show();
    await windowManager.focus();
  });
}

import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:flutter/material.dart';
import 'app/models.dart';
import 'app/window_content.dart';
import 'app/main_window.dart';
import 'package:flutter/src/widgets/_window.dart';

class MainControllerWindowDelegate with RegularWindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    exit(0);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final now = DateTime.now();
    final diff2022 = now.difference(DateTime(2022, 2, 24));
    final diff2014 = now.difference(DateTime(2014, 4, 14));
    
    await HomeWidget.saveWidgetData('text_2022', '${diff2022.inDays}д. ${diff2022.inHours % 24}г.');
    await HomeWidget.saveWidgetData('text_2014', '${diff2014.inDays}д. ${diff2014.inHours % 24}г.');
    
    await HomeWidget.updateWidget(name: 'TimeOfWarWidgetProvider', iOSName: 'TimeOfWarWidget');
    return Future.value(true);
  });
}

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "time_of_war_update",
    "updateWidgetTask",
    frequency: const Duration(hours: 1),
    existingWorkPolicy: ExistingWorkPolicy.replace
  );
  runWidget(MultiWindowApp());
}

class MultiWindowApp extends StatefulWidget {
  const MultiWindowApp({super.key});

  @override
  State<MultiWindowApp> createState() => _MultiWindowAppState();
}

class _MultiWindowAppState extends State<MultiWindowApp> {
  final RegularWindowController controller = RegularWindowController(
    preferredSize: const Size(800, 600),
    title: 'Multi-Window Reference Application',
    delegate: MainControllerWindowDelegate(),
  );
  final WindowSettings settings = WindowSettings();
  late final WindowManager windowManager;

  @override
  void initState() {
    super.initState();
    windowManager = WindowManager(
      initialWindows: <KeyedWindow>[
        KeyedWindow(
          isMainWindow: true,
          key: UniqueKey(),
          controller: controller,
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget mainWindowWidget = RegularWindow(
      controller: controller,
      child: MaterialApp(home: MainWindow()),
    );
    return WindowManagerAccessor(
      windowManager: windowManager,
      child: WindowSettingsAccessor(
        windowSettings: settings,
        child: ListenableBuilder(
          listenable: windowManager,
          builder: (BuildContext context, Widget? child) {
            final List<Widget> childViews = <Widget>[mainWindowWidget];
            for (final KeyedWindow window in windowManager.windows) {
              // This check renders windows that are not nested below another window as
              // a child window (e.g. a popup as a child of another window) in addition
              // to the main window, which is special as it is the one that is currently
              // being rendered.
              if (window.parent == null && !window.isMainWindow) {
                childViews.add(
                  WindowContent(
                    controller: window.controller,
                    windowKey: window.key,
                    onDestroyed: () => windowManager.remove(window.key),
                    onError: () => windowManager.remove(window.key),
                  ),
                );
              }
            }

            return ViewCollection(views: childViews);
          },
        ),
      ),
    );
  }
}

import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'motion_events_page.dart';
import 'page.dart';
import 'wm_integrations.dart';

final List<PageWidget> _allPages = <PageWidget>[
  const MotionEventsPage(),
  const WindowManagerIntegrationsPage(),
];

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
  enableFlutterDriverExtension(handler: driverDataHandler.handleMessage);
  runApp(
    MaterialApp(
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: const Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: _allPages.map((PageWidget p) => _buildPageListTile(context, p)).toList(),
      ),
    );
  }

  Widget _buildPageListTile(BuildContext context, PageWidget page) {
    return ListTile(
      title: Text(page.title),
      key: page.tileKey,
      onTap: () {
        _pushPage(context, page);
      },
    );
  }

  void _pushPage(BuildContext context, PageWidget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(body: page)));
  }
}

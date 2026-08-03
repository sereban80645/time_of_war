import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';

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
  runApp(const MyApp());
}

final class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final List<DisplayFeature> displayFeatures = MediaQuery.of(context).displayFeatures;
    displayFeatures.retainWhere(
      (DisplayFeature feature) => feature.type == DisplayFeatureType.cutout,
    );
    String text;
    // None of this complexity is required for the test but it helps when
    // visually debugging or watching a video of a remote device.
    if (displayFeatures.isEmpty) {
      text = 'CutoutNone';
    } else if (displayFeatures.length > 1) {
      text = 'CutoutMany';
    } else {
      final Rect cutout = displayFeatures[0].bounds;
      if (cutout.top == 0) {
        text = 'CutoutTop';
      } else if (cutout.left == 0) {
        text = 'CutoutLeft';
      } else {
        text = 'CutoutNeither';
      }
    }
    // Tests assume there is some text element displayed.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Text('Cutout status: $text', key: Key(text)),
    );
  }
}

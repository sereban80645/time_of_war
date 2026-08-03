import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

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
  enableFlutterDriverExtension();

  runApp(
    MaterialApp(
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            return TextButton(
              child: const Text('flutter drive lib/xxx.dart', textDirection: TextDirection.ltr),
              onPressed: () {
                Navigator.push<Object?>(
                  context,
                  MaterialPageRoute<Object?>(
                    builder: (BuildContext context) {
                      return const Material(
                        child: Center(
                          child: Text('navigated here', textDirection: TextDirection.ltr),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

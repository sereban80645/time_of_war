import 'package:workmanager/workmanager.dart';
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:ui';

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
  final Paint paint = Paint()..color = Color(0xFFFFFFFF);
  print(jsonEncode(<String, String>{
    'Paint.toString': paint.toString(),
    'Brightness.toString': Brightness.dark.toString(),
    'Foo.toString': Foo().toString(),
    'Keep.toString': Keep().toString(),
  }));
}

class Foo {
  @override
  String toString() => 'I am a Foo';
}

class Keep {
  @keepToString
  @override
  String toString() => 'I am a Keep';
}

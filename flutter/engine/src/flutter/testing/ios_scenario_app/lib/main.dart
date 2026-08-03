import 'package:workmanager/workmanager.dart';
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'src/scenarios.dart';

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
  // TODO(goderbauer): Create a window if embedder doesn't provide an implicit
  //   view to draw into once we have a windowing API and set the window's
  //   FlutterView to the _view property.
  assert(PlatformDispatcher.instance.implicitView != null);
  PlatformDispatcher.instance
    ..onBeginFrame = _onBeginFrame
    ..onDrawFrame = _onDrawFrame
    ..onMetricsChanged = _onMetricsChanged
    ..onPointerDataPacket = _onPointerDataPacket
    ..scheduleFrame();
  channelBuffers.setListener('driver', _handleDriverMessage);

  final FlutterView view = PlatformDispatcher.instance.implicitView!;
  // Asserting that this is greater than zero since this app runs on different
  // platforms with different sizes. If it is greater than zero, it has been
  // initialized to some meaningful value at least.
  assert(view.display.size > Offset.zero, 'Expected ${view.display} to be initialized.');

  final data = ByteData(1);
  data.setUint8(0, 1);
  PlatformDispatcher.instance.sendPlatformMessage('waiting_for_status', data, null);
}

/// The FlutterView into which the [Scenario]s will be rendered.
FlutterView get _view => PlatformDispatcher.instance.implicitView!;

void _handleDriverMessage(ByteData? data, PlatformMessageResponseCallback? callback) {
  final call = json.decode(utf8.decode(data!.buffer.asUint8List())) as Map<String, dynamic>;
  final methodName = call['method'] as String?;
  switch (methodName) {
    case 'set_scenario':
      assert(call['args'] != null);
      loadScenario(call['args'] as Map<String, dynamic>, _view);
    default:
      throw 'Unimplemented method: $methodName.';
  }
}

void _onBeginFrame(Duration duration) {
  // Render an empty frame to signal first frame in the platform side.
  if (currentScenario == null) {
    final builder = SceneBuilder();
    final Scene scene = builder.build();
    _view.render(scene);
    scene.dispose();
    return;
  }
  currentScenario!.onBeginFrame(duration);
}

void _onDrawFrame() {
  currentScenario?.onDrawFrame();
}

void _onMetricsChanged() {
  currentScenario?.onMetricsChanged();
}

void _onPointerDataPacket(PointerDataPacket packet) {
  currentScenario?.onPointerDataPacket(packet);
}

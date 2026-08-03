import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  runApp(InfiniteScrollApp());
}

class InfiniteScrollApp extends StatelessWidget {
  const InfiniteScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Scrolling Flutter',
      home: InfiniteScrollList(),
    );
  }
}

class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  InfiniteScrollListState createState() => InfiniteScrollListState();
}

class InfiniteScrollListState extends State<InfiniteScrollList> {
  final List<String> items = [];
  final int itemsPerPage = 20;
  final List<String> staticData = [
    "Hello Flutter",
    "Hello Flutter",
    "Hello Flutter",
    "Hello Flutter",
    "Hello Flutter",
  ];

  @override
  void initState() {
    super.initState();
    _loadMoreData(); // Load initial data
  }

  void _loadMoreData() {
    setState(() {
      final newItems = List.generate(itemsPerPage, (i) {
        return staticData[i % staticData.length];
      });
      items.addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Infinite Scrolling ListView (Static Data)"),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 50) {
              _loadMoreData();
              return true;
            }
            return false;
          },
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index]));
            },
          ),
        ),
      ),
    );
  }
}

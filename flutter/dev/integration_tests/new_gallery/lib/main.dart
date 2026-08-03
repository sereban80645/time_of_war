import 'package:workmanager/workmanager.dart';
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'data/gallery_options.dart';
import 'gallery_localizations.dart';
import 'layout/adaptive.dart';
import 'pages/backdrop.dart';
import 'pages/splash.dart';
import 'routes.dart';
import 'themes/gallery_theme_data.dart';

export 'package:gallery/data/demos.dart' show pumpDeferredLibraries;

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

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key, this.initialRoute, this.isTestMode = false});

  final String? initialRoute;
  final bool isTestMode;

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: GalleryOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
        isTestMode: isTestMode,
      ),
      child: Builder(
        builder: (BuildContext context) {
          final GalleryOptions options = GalleryOptions.of(context);
          return MaterialApp(
            restorationScopeId: 'rootGallery',
            title: 'Flutter Gallery',
            debugShowCheckedModeBanner: false,
            themeMode: options.themeMode,
            theme: GalleryThemeData.lightThemeData.copyWith(platform: options.platform),
            darkTheme: GalleryThemeData.darkThemeData.copyWith(platform: options.platform),
            localizationsDelegates: const <LocalizationsDelegate<Object?>>[
              ...GalleryLocalizations.localizationsDelegates,
              LocaleNamesLocalizationsDelegate(),
            ],
            initialRoute: initialRoute,
            supportedLocales: GalleryLocalizations.supportedLocales,
            locale: options.locale,
            localeListResolutionCallback:
                (List<Locale>? locales, Iterable<Locale> supportedLocales) {
                  deviceLocale = locales?.first;
                  return basicLocaleListResolution(locales, supportedLocales);
                },
            onGenerateRoute: (RouteSettings settings) =>
                RouteConfiguration.onGenerateRoute(settings),
          );
        },
      ),
    );
  }
}

// ignore: unreachable_from_main
class RootPage extends StatelessWidget {
  // ignore: unreachable_from_main
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ApplyTextOptions(
      child: SplashPage(child: Backdrop(isDesktop: isDisplayDesktop(context))),
    );
  }
}

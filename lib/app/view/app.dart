// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:auth_demo/auth_view/auth_code_platform_view.dart';
import 'package:auth_demo/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oauth2/oauth2.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final grant = AuthorizationCodeGrant(
    'CLIENTID',
    Uri.parse('https://idp.test/authorize'),
    Uri.parse('https://idp.test/token'),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AuthCodePlatformView(
          authorizationEndpoint: grant.getAuthorizationUrl(
              Uri.parse(
                'http://localhost:4200/callback.html',
              ),
              scopes: ['openid', 'offline_access']),
          callbackHandler: (callback) {
            if (callback.path == '/callback.html') {
              grant.handleAuthorizationResponse(callback.queryParameters).then(
                    (value) => print(value.credentials.accessToken),
                  );
            }
            return true;
          },
          onCancelled: () {
            print('cancelled');
          },
          onError: () {
            print('errpr');
          },
          child: ColoredBox(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

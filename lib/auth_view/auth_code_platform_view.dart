// ignore_for_file: public_member_api_docs

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:auth_demo/auth_view/auth_code_view_implementation.dart';
import 'package:flutter/material.dart';

class AuthCodePlatformView extends StatefulWidget
    implements AuthCodePlatformViewImplementaion {
  const AuthCodePlatformView({
    Key? key,
    required this.authorizationEndpoint,
    required this.callbackHandler,
    required this.onCancelled,
    required this.onError,
    this.child,
  }) : super(key: key);
  @override
  final Uri authorizationEndpoint;

  @override
  final AuthCodeCallbackHandler callbackHandler;

  @override
  final Widget? child;

  @override
  final AuthCodeVoidCallback onCancelled;

  @override
  final AuthCodeVoidCallback onError;

  @override
  AuthCodePlatformViewState createState() => AuthCodePlatformViewState();
}

class AuthCodePlatformViewState extends State<AuthCodePlatformView> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    try {
      _ExternalBrowserWindow.open(
        url: widget.authorizationEndpoint,
        title: 'Auth Code Simplified',
        onClosed: widget.onCancelled,
        onMessage: (event, close) {
          final data = event.data as Map<dynamic, dynamic>;
          if (data.containsKey('type')) {
            if (data['type'] == 'callback') {
              widget.callbackHandler(Uri.parse(data['url'] as String));
              close();
            }
          }
        },
      );
    } catch (_) {
      widget.onError();
    }
  }
}

class _ExternalBrowserWindow {
  const _ExternalBrowserWindow({
    this.hasScrollbars = false,
    this.isResizable = false,
    this.hasStatusBar = false,
    this.hasLocationbar = false,
    this.hasToolbar = false,
    this.hasMenubar = false,
    this.left = 300,
    this.top = 300,
    this.width = 420,
    this.height = 700,
    this.onMessage,
    // ignore: unused_element
    this.center = true,
    required this.onClosed,
    required this.url,
    required this.title,
  });

  factory _ExternalBrowserWindow.open({
    bool hasScrollbars = false,
    bool isResizable = false,
    bool hasStatusBar = false,
    bool hasLocationbar = false,
    bool hasToolbar = false,
    bool hasMenubar = false,
    int left = 300,
    int top = 300,
    int width = 360,
    int height = 600,
    void Function(html.MessageEvent event, void Function() close)? onMessage,
    required void Function() onClosed,
    required Uri url,
    required String title,
  }) =>
      _ExternalBrowserWindow(
        hasScrollbars: hasScrollbars,
        isResizable: isResizable,
        hasStatusBar: hasStatusBar,
        hasLocationbar: hasLocationbar,
        hasToolbar: hasToolbar,
        hasMenubar: hasMenubar,
        left: left,
        top: top,
        width: width,
        height: height,
        onClosed: onClosed,
        url: url,
        title: title,
        onMessage: onMessage,
      )..open();

  final bool hasScrollbars;
  final bool isResizable;
  final bool hasStatusBar;
  final bool hasLocationbar;
  final bool hasToolbar;
  final bool hasMenubar;
  final int left;
  final int top;
  final int width;
  final int height;
  final void Function() onClosed;
  final Uri url;
  final String title;
  final bool center;
  final void Function(
    html.MessageEvent event,
    void Function() close,
  )? onMessage;

  Future<void> open() async {
    final window = html.window.open(url.toString(), title, options);
    StreamSubscription<html.MessageEvent>? subscription;
    var skipEvent = false;
    if (onMessage != null) {
      subscription = html.window.onMessage.listen((event) {
        onMessage?.call(event, () {
          skipEvent = true;
          window.close();
        });
      });
    }
    await waitForClose(window);
    await subscription?.cancel();
    if (!skipEvent) {
      onClosed();
    }
  }

  Future<void> waitForClose(html.WindowBase window) async {
    while (window.closed != null && !window.closed!) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  math.Point<int> getPoint() {
    if (center) {
      final screenLeft = html.window.screenLeft ?? html.window.screenX;
      final screenTop = html.window.screenTop ?? html.window.screenY;
      final screenWidth = html.window.innerWidth ??
          html.document.documentElement?.clientWidth ??
          html.window.screen?.width;
      final screenHeight = html.window.innerHeight ??
          html.document.documentElement?.clientHeight ??
          html.window.screen?.height;

      if (screenLeft != null &&
          screenTop != null &&
          screenWidth != null &&
          screenHeight != null) {
        final left = (screenWidth - width) / 2;
        final top = (screenHeight - height) / 2;
        return math.Point<int>(left.toInt(), top.toInt());
      }
    }
    return math.Point(left, top);
  }

  String _buildOptions(int left, int top) =>
      'scrollbars=${boolToYesOrNo(yes: hasScrollbars)},resizable='
      '${boolToYesOrNo(yes: isResizable)},'
      'status=${boolToYesOrNo(yes: hasStatusBar)},'
      'location=${boolToYesOrNo(yes: hasLocationbar)},'
      'toolbar=${boolToYesOrNo(yes: hasToolbar)},'
      'menubar=${boolToYesOrNo(yes: hasMenubar)},'
      'width=$width,height=$height,left=$left,top=$top';

  String get options {
    final point = getPoint();
    return _buildOptions(point.x, point.y);
  }

  String boolToYesOrNo({required bool yes}) => yes ? 'yes' : 'no';
}

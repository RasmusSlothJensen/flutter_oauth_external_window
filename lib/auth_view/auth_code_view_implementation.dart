import 'package:flutter/widgets.dart';

/// When the callback endpoint i called this function
/// is responsible for handling it.
typedef AuthCodeCallbackHandler = bool Function(Uri uri);

/// When an error occures or when the user cancelles the request.
typedef AuthCodeVoidCallback = void Function();

/// Base implementation of the auth code view.
abstract class AuthCodePlatformViewImplementaion {
  /// [callbackHandler] is used to match agains the
  /// registered callback uri.
  AuthCodeCallbackHandler get callbackHandler;

  /// [onError] is called if an unexpected error occures.
  AuthCodeVoidCallback get onError;

  /// [onCancelled] is called when the user cancels the flow or closes
  /// the view.
  AuthCodeVoidCallback get onCancelled;

  /// The [authorizationEndpoint] is the oauth authorization endpoint
  /// where the client will be redirected to.
  Uri get authorizationEndpoint;

  /// The [child] widget of view.
  Widget? get child;
}

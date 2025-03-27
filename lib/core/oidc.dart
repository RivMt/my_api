import 'dart:js_interop';

import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';
import 'package:oidc/oidc.dart';

const String _tag = "OIDC";

class OpenIDConnect {

  static final _instance = OpenIDConnect._();

  factory OpenIDConnect() => _instance;

  OpenIDConnect._();

  late OidcUserManager _manager;

  String _idToken = "";

  String get idToken => _idToken;

  Future<void> init({
    required String serverUri,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    final redirect = Uri.parse(redirectUri);
    redirect.replace(
        queryParameters: {
          ...redirect.queryParameters,
          'requestType': 'front-channel-logout'
        }
    );
    _manager = OidcUserManager.lazy(
      discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
        Uri.parse(serverUri),
      ),
      clientCredentials: OidcClientAuthentication.clientSecretBasic(
        clientId: clientId,
        clientSecret: clientSecret,
      ),
      store: OidcMemoryStore(),
      settings: OidcUserManagerSettings(
        redirectUri: redirect,
        scope: [
          "openid",
          "email"
        ]
      ),
    );
    await _manager.init();
    if (!_manager.didInit) {
      Log.e(_tag, "Unable to initialize OIDC manager");
    }
  }

  Future<User> login() async {
    final user = await _manager.loginAuthorizationCodeFlow(
      extraTokenParameters: {
        "client_secret": _manager.clientCredentials.clientSecret
      }
    );
    if (user == null) {
      throw NullRejectionException(true);
    }
    _idToken = user.token.idToken!;
    return User.fromOidc(user);
  }

  Future<void> logout() async {
    _idToken = "";
    await _manager.logout();
  }

}
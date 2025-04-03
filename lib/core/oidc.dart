import 'dart:js_interop';

import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';
import 'package:oidc/oidc.dart';

const String _tag = "OIDC";

class OpenIDConnect {

  static final _instance = OpenIDConnect._();

  factory OpenIDConnect() => _instance;

  OpenIDConnect._();

  late OidcUserManager manager;

  String get idToken => manager.currentUser?.idToken ?? "";

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
    manager = OidcUserManager.lazy(
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
          "profile",
          "email",
          "groups",
        ]
      ),
    );
    await manager.init();
    if (!manager.didInit) {
      Log.e(_tag, "Unable to initialize OIDC manager");
    } else {
      Log.i(_tag, "OIDC user manager initialized");
    }
  }

  Future<User> login() async {
    final user = await manager.loginAuthorizationCodeFlow(
      extraTokenParameters: {
        "client_secret": manager.clientCredentials.clientSecret
      },
      options: const OidcPlatformSpecificOptions(
        web: OidcPlatformSpecificOptions_Web(
          navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode.popup,
          popupWidth: 405,
          popupHeight: 720,
        )
      )
    );
    if (user == null) {
      Log.e(_tag, "Failed to authenticate");
      return User.unknown;
    }
    return User.fromOidc(user);
  }

  Future<void> logout() async {
    await manager.logout();
  }

}
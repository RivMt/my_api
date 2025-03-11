import 'dart:js_interop';

import 'package:my_api/core/model/user.dart';
import 'package:oidc/oidc.dart';

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
    _manager = OidcUserManager.lazy(
      discoveryDocumentUri: Uri.parse(serverUri),
      clientCredentials: OidcClientAuthentication.clientSecretJwt(
        clientId: clientId,
        clientAssertion: clientSecret,
      ),
      store: OidcMemoryStore(),
      settings: OidcUserManagerSettings(redirectUri: Uri.parse(redirectUri)),
    );
    await _manager.init();
  }

  Future<User> login() async {
    final user = await _manager.loginAuthorizationCodeFlow();
    if (user == null) {
      throw NullRejectionException(true);
    }
    _idToken = user.idToken;
    return User.fromOidc(user);
  }

  Future<void> logout() async {
    _idToken = "";
    await _manager.logout();
  }

}
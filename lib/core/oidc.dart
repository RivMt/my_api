import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';
import 'package:oidc/oidc.dart';

const String _tag = "OIDC";

/// A OIDC management class
class OpenIDConnect {

  /// Static instance for factory pattern
  static final _instance = OpenIDConnect._();

  /// Factory constructor
  factory OpenIDConnect() => _instance;

  /// Private constructor for factory pattern
  OpenIDConnect._();

  /// [OidcUserManager] instance
  late OidcUserManager manager;

  /// ID token of current user
  ///
  /// The value is `null` when any user logged in currently
  String get idToken => manager.currentUser?.idToken ?? "";

  /// Init instance
  ///
  /// [serverUri] is URI of API server. [clientId] and [clientSecret] is issued
  /// by OIDC server. [redirectUri] is URI of redirection receiving. This URI is
  /// registered in OIDC server.
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

  /// Login via OIDC
  ///
  /// Popup windows will be opened to login. Returns [User] after logged in.
  ///
  /// If the platform is iOS, user should allow popup window to login. Because
  /// iOS webkit block popup basically.
  Future<User> login() async {
    OidcUser? user;
    try {
      user = await manager.loginAuthorizationCodeFlow(
        extraTokenParameters: {
          "client_secret": manager.clientCredentials.clientSecret
        },
        options: const OidcPlatformSpecificOptions(
          web: OidcPlatformSpecificOptions_Web(
            navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode
                .popup,
            popupWidth: 600,
            popupHeight: 600,
          ),
        ),
      );
    } catch (e, s) {
      Log.e(_tag, "Login failed due to error", e, s);
    }
    if (user == null) {
      Log.w(_tag, "Failed to authenticate");
      return User.unknown;
    }
    return User.fromOidc(user);
  }

  /// Logout current user
  Future<void> logout() async {
    await manager.logout();
  }

}
import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

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

  /// Access token of current user
  ///
  /// The value is `null` when any user logged in currently
  String get accessToken => manager.currentUser?.token.accessToken ?? "";

  /// Init instance
  ///
  /// [serverUri] is the URI of the OIDC server. [clientId] identifies a public
  /// client registered by the OIDC server. [redirectUri] receives the
  /// authorization response and must be registered by the OIDC server.
  ///
  /// Authentication uses Authorization Code Flow with PKCE. Public clients do
  /// not use a client secret because an application binary cannot keep one
  /// confidential.
  Future<void> init({
    required String serverUri,
    required String clientId,
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
      clientCredentials: OidcClientAuthentication.none(
        clientId: clientId,
      ),
      store: OidcDefaultStore(),
      settings: OidcUserManagerSettings(
        redirectUri: redirect,
        scope: [
          "profile",
          "email",
          "groups",
        ],
        refreshBefore: (token) => const Duration(days: 1),
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

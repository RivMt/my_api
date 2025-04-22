import 'package:my_api/src/core/model/model.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:oidc/oidc.dart';

/// An user
///
/// All properties are read-only because user info only can be changed by server-side.
class User extends Model {

  /// An unknown user
  static final User unknown = User();

  /// Initialize from [map]
  User([super.map]);

  /// Initialize from [OidcUser]
  ///
  /// If [user] is `null`, initialize as [unknown].
  User.fromOidc(OidcUser? user) {
    if (user == null) {
      map.clear();
      map.addAll(unknown.map);
      return;
    }
    map[ModelKeys.keyUserId] = user.uid ?? "";
    map[ModelKeys.keyEmail] = user.userInfo[ModelKeys.keyEmail] ?? "";
    map[ModelKeys.keyEmailVerified] = user.userInfo[ModelKeys.keyEmailVerified] ?? false;
    map[ModelKeys.keyName] = user.userInfo[ModelKeys.keyName] ?? "";
    map[ModelKeys.keyPreferredUserName] = user.userInfo[ModelKeys.keyPreferredUserName] ?? "";
    map[ModelKeys.keyFamilyName] = user.userInfo[ModelKeys.keyFamilyName] ?? "";
    map[ModelKeys.keyGivenName] = user.userInfo[ModelKeys.keyGivenName] ?? "";
    map[ModelKeys.keyPicture] = user.userInfo[ModelKeys.keyPicture] ?? "";
    map[ModelKeys.keyGroups] = user.userInfo[ModelKeys.keyGroups].join(",") ?? "";
  }

  /// Whether this is valid user
  bool get isValid => userId.isNotEmpty;

  /// Unique identification code of this (Read-only)
  String get userId => getString(ModelKeys.keyUserId, "");

  /// Email address
  String get email => getString(ModelKeys.keyEmail, "");

  /// Whether [email] is verified or not
  bool get isEmailVerified => getBool(ModelKeys.keyEmailVerified, false);

  /// Full name
  String get name => getString(ModelKeys.keyName, "");

  /// Preferred name
  String get preferredName => getString(ModelKeys.keyPreferredUserName, "");

  /// Family name
  String get familyName => getString(ModelKeys.keyFamilyName, "");

  /// Given name
  String get givenName => getString(ModelKeys.keyGivenName, "");

  /// Display name
  ///
  /// The order of select is [name], [preferredName], and [email].
  /// Next order of value will be selected if former is empty string.
  String get displayName {
    if (name.isNotEmpty) return name;
    if (preferredName.isNotEmpty) return preferredName;
    return email;
  }

  /// Url of profile picture
  String get picture => getString(ModelKeys.keyPicture, "");

  /// List of groups
  List<String> get groups => getList(ModelKeys.keyGroups, [], ",");

  @override
  bool isEquivalent(Model other) {
    if (other is User) {
      return userId == other.userId;
    }
    return this==other;
  }

  @override
  int get representativeCode => userId.hashCode;

  @override
  String toString() => "$name ($email)";

}
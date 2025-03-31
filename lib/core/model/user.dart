import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:oidc/oidc.dart';

class User extends Model {

  static final User unknown = User();

  User([super.map]);

  User.fromOidc(OidcUser user) {
    map[ModelKeys.keyUserId] = user.uid ?? "";
    map[ModelKeys.keyEmail] = user.userInfo[ModelKeys.keyEmail] ?? "";
    map[ModelKeys.keyName] = user.userInfo[ModelKeys.keyName] ?? "";
  }

  bool get isValid => userId.isNotEmpty;

  /// Unique identification code (Read-only)
  String get userId => getValue(ModelKeys.keyUserId, "");

  /// Email
  String get email => getValue(ModelKeys.keyEmail, "");

  /// Name
  String get name => getValue(ModelKeys.keyName, "");

  @override
  String toString() => "$name ($email)";

}

class UserGender {

  /// Code for Gender OTHER
  static const int codeOther = -1;

  /// Code for Gender MALE
  static const int codeMale = 0;

  /// Code for Gender FEMALE
  static const int codeFemale = 1;

  /// Constant for Gender MALE
  static final UserGender male = UserGender(codeMale, "Male");

  /// Constant for Gender FEMALE
  static final UserGender female = UserGender(codeFemale, "Female");

  /// Users can define gender themself
  UserGender(this.code, this.name);

  /// Name of gender
  final String name;

  /// Code of gender
  final int code;

  /// Find gender using [name]
  static UserGender fromName(String name) {
    switch(name.toLowerCase()) {
      case "male":
        return male;
      case "female":
        return female;
      default:
        return UserGender(codeOther, name);
    }
  }

  /// Find gender using [code]
  ///
  /// If [code] is [codeOther], returns [name] gender.
  static UserGender fromCode(int code, [String name = ""]) {
    switch(code) {
      case codeMale:
        return male;
      case codeFemale:
        return female;
      default:
        return UserGender(codeOther, name);
    }
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is UserGender) {
      if (code == other.code && code == codeOther) {
        return name == other.name;
      }
      return code == other.code;
    }
    return super == other;
  }

  /// Display gender name
  @override
  String toString() => name;
}
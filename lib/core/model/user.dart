import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';

class User extends Model {

  static const int minPasswordLength = 8;

  User([super.map]);

  /// Check password validation
  static bool checkPassword(String password) {
    // Length
    if (password.length < minPasswordLength) {
      return false;
    }
    // Allow letter
    final allow = RegExp(r"[^a-z\d._\-@!~`#$%^&*()=+\[\]{}:;/?]");
    if (allow.hasMatch(password)) {
      return false;
    }
    return true;
  }

  /// Unique identification code (Read-only)
  String get userId => getValue(ModelKeys.keyUserId, "");

  /// Email
  String get email => getValue(ModelKeys.keyEmail, "");

  set email(String value) => map[ModelKeys.keyEmail] = value;

  /// First name
  String get firstName => getValue(ModelKeys.keyFirstName, "");

  set firstName(String name) => map[ModelKeys.keyFirstName] = name;

  /// Last name
  String get lastName => getValue(ModelKeys.keyLastName, "");

  set lastName(String name) => map[ModelKeys.keyLastName] = name;

  /// Birthday
  DateTime get birthday => DateTime.fromMillisecondsSinceEpoch(getValue(ModelKeys.keyBirthday, 0));

  set birthday(DateTime date) => map[ModelKeys.keyBirthday] = date.millisecondsSinceEpoch;

  /// Gender
  UserGender get gender => UserGender.fromName(getValue(ModelKeys.keyGender, ""));

  set gender(UserGender gender) => map[ModelKeys.keyGender] = gender.name;

  /// Validation (Read-only)
  DateTime get validation => DateTime.fromMillisecondsSinceEpoch(getValue(ModelKeys.keyValidation, 0));

  /// User secret
  String get userSecret => getValue(ModelKeys.keyUserSecret, "");

  /// Valid
  bool get isValid => (userId != "" && userSecret != "");

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
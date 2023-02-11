import 'package:my_api/core/model/model.dart';

class User extends Model {

  static const String keyUserId = "user_id";
  static const String keyEmail = "email";
  static const String keyFirstName = "name_first";
  static const String keyLastName = "name_second";
  static const String keyBirthday = "birthday";
  static const String keyGender = "gender";
  static const String keyValidation = "validation";
  static const String keyUserSecret = "user_secret";
  static const String keyPassword = "user_password";

  static const int minPasswordLength = 8;

  User(super.map);

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
  String get userId => getValue(keyUserId, "");

  /// Email
  String get email => getValue(keyEmail, "");

  set email(String value) => map[keyEmail] = value;

  /// First name
  String get firstName => getValue(keyFirstName, "");

  set firstName(String name) => map[keyFirstName] = name;

  /// Last name
  String get lastName => getValue(keyLastName, "");

  set lastName(String name) => map[keyLastName] = name;

  /// Birthday
  DateTime get birthday => DateTime.fromMillisecondsSinceEpoch(getValue(keyBirthday, 0));

  set birthday(DateTime date) => map[keyBirthday] = date.millisecondsSinceEpoch;

  /// Gender
  UserGender get gender => UserGender.fromName(getValue(keyGender, ""));

  set gender(UserGender gender) => map[keyGender] = gender.name;

  /// Validation (Read-only)
  DateTime get validation => DateTime.fromMillisecondsSinceEpoch(getValue(keyValidation, 0));

  /// User secret
  String get userSecret => getValue(keyUserSecret, "");

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
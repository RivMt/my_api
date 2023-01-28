import 'package:my_api/src/model/model.dart';

class User extends Model {

  static const String keyUserId = "user_id";
  static const String keyEmail = "email";
  static const String keyFirstName = "name_first";
  static const String keyLastName = "name_second";
  static const String keyBirthday = "birthday";
  static const String keyGender = "gender";
  static const String keyValidation = "validation";
  static const String keyUserSecret = "user_secret";

  User(super.map);

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
  UserGender get gender => UserGender.find(getValue(keyGender, ""));

  set gender(UserGender gender) => map[keyGender] = gender.name;

  /// Validation (Read-only)
  DateTime get validation => DateTime.fromMillisecondsSinceEpoch(getValue(keyValidation, 0));

  /// User secret
  String get userSecret => getValue(keyUserSecret, "");

  /// Valid
  bool get valid => (userId != "" && userSecret != "");

}

class UserGender {

  /// Constant for Gender MALE
  static final UserGender male = UserGender("male");

  /// Constant for Gender FEMALE
  static final UserGender female = UserGender("female");

  /// Users can define gender themself
  UserGender(this.name);

  /// Name of gender
  final String name;

  /// Find gender using [name]
  static UserGender find(String name) {
    switch(name.toLowerCase()) {
      case "male":
        return male;
      case "female":
        return female;
      default:
        return UserGender(name);
    }
  }

  /// Display gender name
  @override
  String toString() => name;
}
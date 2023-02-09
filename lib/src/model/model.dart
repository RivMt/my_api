library my_api;

abstract class Model {

  static final maxDate = DateTime(2200, 12, 31);

  /// Raw data of this object
  Map<String, dynamic> map = {};

  /// Constructor
  Model(this.map);

  /// Get value of [map] using [key]
  ///
  /// **DO NOT** call this directly. Use several properties variables to access.
  /// When [key] is not included in [map], return [defaultValue]. If [defaultValue]
  /// does not set, throws [InvalidModeException].
  getValue(String key, dynamic defaultValue) {
    // Check key is exist
    if (map.containsKey(key)) {
      return map[key];
    }
    // Return default value
    return defaultValue;
  }
}

class FinanceModel extends Model {

  static const String keyId = "id";
  static const String keyPid = "pid";
  static const String keyLastUsed = "last_used";
  static const String keyOwner = "owner_id";
  static const String keyEditors = "editors_id";
  static const String keyDescriptions = "descriptions";
  static const String keyDeleted = "deleted";

  /// Create object using [map]
  FinanceModel(super.map);

  /// ID (Read-only)
  int get id => getValue(keyId, -1);

  /// PID (Read-only)
  int get pid => getValue(keyPid, -1);

  /// [DateTime] of lastly used
  DateTime get lastUsed => DateTime.fromMillisecondsSinceEpoch(getValue(keyLastUsed, 0));

  set lastUsed(DateTime dateTime) => map[keyLastUsed] = dateTime.millisecondsSinceEpoch;

  /// UID of owner
  String get owner => getValue(keyOwner, "");

  set owner(String id) => throw UnimplementedError();

  /// List of editor UID
  List<String> get editors => getValue(keyEditors, []);

  set editors(List<String> list) => map[keyEditors] = list;

  /// Descriptions of this object
  String get descriptions => getValue(keyDescriptions, "");

  set descriptions(String desc) => map[keyDescriptions] = desc;

  /// Is this object deleted or not
  bool get deleted => getValue(keyDeleted, false);

  set deleted(bool value) => map[keyDeleted] = value;

  /// Check two models' [pid] is equal or not
  @override
  bool operator ==(Object other) {
    if (other is FinanceModel) {
      return pid == other.pid;
    }
    return super==(other);
  }

  /// [pid] is similar kind of hash code
  @override
  int get hashCode {
    return pid;
  }


}
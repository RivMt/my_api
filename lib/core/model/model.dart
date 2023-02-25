library my_api;

abstract class Model {

  static final maxDate = DateTime(2200, 12, 31);

  /// Raw data of this object
  Map<String, dynamic> map = {};

  /// Constructor
  Model(this.map);

  /// Get value of [map] using [key]
  ///
  /// **DO NOT** call this directly. Use several property variables to access.
  /// When [key] is not included in [map], return [defaultValue].
  getValue(String key, dynamic defaultValue) {
    // Check key is exist
    if (map.containsKey(key)) {
      return map[key];
    }
    // Return default value
    return defaultValue;
  }

  /// Get date from [key]
  ///
  /// [value] is default value when [key] is not exist in [map].
  DateTime getDate(String key, DateTime value) {
    if (!map.containsKey(key)) {
      return value;
    }
    final utc = DateTime.fromMillisecondsSinceEpoch(map[key], isUtc: true);
    return DateTime(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second, utc.millisecond, utc.microsecond);
  }

  /// Set date [value] to [key]
  void setDate(String key, DateTime value) {
    final local = value.add(value.timeZoneOffset).toUtc();
    map[key] = local.millisecondsSinceEpoch;
  }
}


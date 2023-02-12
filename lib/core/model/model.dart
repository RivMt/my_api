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
}


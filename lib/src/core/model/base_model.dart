library my_api;

import 'package:my_api/src/core/model/model.dart';
import 'package:my_api/src/core/model/model_keys.dart';

/// A superclass of all user editable models
///
/// This class is designed to map each database rows from the API server response.
/// Member variables of this are common columns of all database.
///
/// There are some read-only variables, so it is **STRONGLY** not recommended
/// to change its value.
abstract class BaseModel extends Model {
  /// Unknown UUID
  static const String unknownUuid = "-1";

  /// Maximum date
  static final DateTime maxDate = DateTime(2100, 12, 31);

  /// Minimum date
  static final DateTime minDate = DateTime(1970, 1, 1);

  /// Maximum length of string field
  static const int maxTextLength = 100;

  /// Initialize class from given [map] (Optional)
  BaseModel([Map<String, dynamic>? map]) : super(map);

  /// Whether this instance is valid or not
  ///
  /// The last line of this property must be `super.isValid` when override this.
  bool get isValid => uuid != unknownUuid;

  /// UUID (Read-only)
  ///
  /// UUID only can be changed by API server. It is possible using [map] to change
  /// its value, however, it is **STRONGLY** not recommended.
  /// Unlike other read-only variables, this is used to identify each model on
  /// whole system. So changing this value makes unpredictable and dangerous results.
  String get uuid => getString(ModelKeys.keyUuid, "");

  /// Date and time when this object was created by the server (read-only).
  DateTime get createdAt => getDateTime(
        ModelKeys.keyCreatedAt,
        DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Date and time of the latest server-side modification (read-only).
  DateTime get modifiedAt => getDateTime(
        ModelKeys.keyModifiedAt,
        DateTime.fromMillisecondsSinceEpoch(0),
      );

  @override
  bool isEquivalent(Model other) {
    if (other is BaseModel) {
      return uuid == other.uuid;
    }
    return this == other;
  }

  @override
  int get representativeCode => uuid.hashCode;
}

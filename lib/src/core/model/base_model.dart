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

  /// [DateTime] of lastly used (Read-only)
  ///
  /// There is no problem when edit it manually, however, server will be update
  /// this when request update. Therefore, it is useless editing [lastUsed]
  /// property.
  DateTime get lastUsed => getDateTime(ModelKeys.keyLastUsed, DateTime.fromMillisecondsSinceEpoch(0));

  /// UUID of owner
  String get owner => getString(ModelKeys.keyOwner, "");

  /// List of editors UUID
  List<String> get editors => getList(ModelKeys.keyEditors, []);

  /// List of viewers UUID
  List<String> get viewers => getList(ModelKeys.keyViewers, []);

  /// Name
  ///
  /// If [text] is longer than [maxTextLength], cut first [maxTextLength] characters only,
  /// and discard others.
  String get name => getString(ModelKeys.keyName, "");

  set name(String text) => setString(ModelKeys.keyName, text, maxTextLength);

  /// Descriptions
  String get descriptions => getString(ModelKeys.keyDescription, "");

  set descriptions(String text) => setString(ModelKeys.keyDescription, text, maxTextLength);

  /// Whether this object deleted or not
  bool get deleted => getBool(ModelKeys.keyDeleted, false);

  set deleted(bool value) => setBool(ModelKeys.keyDeleted, value);

  @override
  bool isEquivalent(Model other) {
    if (other is BaseModel) {
      return uuid == other.uuid;
    }
    return this==other;
  }

  @override
  int get representativeCode => uuid.hashCode;
}


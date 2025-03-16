library my_api;

import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';

/// Superclass of all API models.
abstract class BaseModel extends Model {

  /// Maximum date
  static final DateTime maxDate = DateTime(2100, 12, 31);

  /// Minimum date
  static final DateTime minDate = DateTime(1970, 1, 1);

  /// Constructor
  BaseModel([Map<String, dynamic>? map]) {
    if (map != null) {
      this.map = map;
    }
  }

  /// UUID (Read-only)
  String get uuid => getValue(ModelKeys.keyUuid, "");

  /// [DateTime] of lastly used (Read-only)
  ///
  /// There is no problem when edit it manually, however, server will be update
  /// this when request update. Therefore, it is useless editing [lastUsed]
  /// property.
  DateTime get lastUsed => getDateTime(ModelKeys.keyLastUsed, DateTime.fromMillisecondsSinceEpoch(0));

  /// UID of owner
  String get owner => getValue(ModelKeys.keyOwner, "");

  set owner(String id) => throw UnimplementedError();

  /// List of editor UID
  List<String> get editors => getList(ModelKeys.keyEditors, []);

  set editors(List<String> list) => setList(ModelKeys.keyEditors, list);

  /// List of viewers UID
  List<String> get viewers => getList(ModelKeys.keyViewers, []);

  set viewers(List<String> list) => setList(ModelKeys.keyViewers, list);

  /// Name of this object
  String get name => getValue(ModelKeys.keyName, "");

  set name(String name) => map[ModelKeys.keyName] = name;

  /// Descriptions of this object
  String get descriptions => getValue(ModelKeys.keyDescriptions, "");

  set descriptions(String desc) => map[ModelKeys.keyDescriptions] = desc;

  /// Is this object deleted or not
  bool get deleted => getValue(ModelKeys.keyDeleted, false);

  set deleted(bool value) => map[ModelKeys.keyDeleted] = value;

  @override
  bool operator ==(Object other) {
    if (other is BaseModel) {
      return uuid == other.uuid;
    }
    return super==(other);
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }
}


library my_api;

import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';

/// Superclass of all API models.
abstract class BaseModel extends Model {

  /// Unknown UUID
  static const String unknownUuid = "-1";

  /// Maximum date
  static final DateTime maxDate = DateTime(2100, 12, 31);

  /// Minimum date
  static final DateTime minDate = DateTime(1970, 1, 1);

  /// Maximum length of string field
  static const int maxTextLength = 100;

  /// Constructor
  BaseModel([Map<String, dynamic>? map]) : super(map);

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

  set name(String text) {
    if (text.length > maxTextLength) {
      text = text.substring(0, maxTextLength);
    }
    map[ModelKeys.keyName] = text;
  }

  /// Descriptions of this object
  String get descriptions => getValue(ModelKeys.keyDescription, "");

  set descriptions(String text) {
    if (text.length > maxTextLength) {
      text = text.substring(0, maxTextLength);
    }
    map[ModelKeys.keyDescription] = text;
  }

  /// Is this object deleted or not
  bool get deleted => getValue(ModelKeys.keyDeleted, false);

  set deleted(bool value) => map[ModelKeys.keyDeleted] = value;

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


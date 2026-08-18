import 'package:my_api/src/core/model/base_model.dart';
import 'package:my_api/src/core/model/model_keys.dart';

/// Adds a mutable name field to a [BaseModel].
mixin NamableModel on BaseModel {
  /// Name of this resource.
  String get name => getString(ModelKeys.keyName, "");

  set name(String text) =>
      setString(ModelKeys.keyName, text, BaseModel.maxTextLength);
}

/// Adds a mutable description field to a [BaseModel].
mixin DescriptableModel on BaseModel {
  /// Description of this resource.
  String get descriptions => getString(ModelKeys.keyDescription, "");

  set descriptions(String text) =>
      setString(ModelKeys.keyDescription, text, BaseModel.maxTextLength);
}

/// Adds soft-deletion state to a [BaseModel].
mixin DeletableModel on BaseModel {
  /// Whether this resource is marked as deleted.
  bool get deleted => getBool(ModelKeys.keyDeleted, false);

  set deleted(bool value) => setBool(ModelKeys.keyDeleted, value);
}

/// Adds server-managed ownership and sharing information to a [BaseModel].
mixin PermittableModel on BaseModel {
  /// UUID of the owner.
  String get owner => getString(ModelKeys.keyOwner, "");

  /// UUIDs of users who can edit this resource.
  List<String> get editors => getList(ModelKeys.keyEditors, []);

  /// UUIDs of users who can view this resource.
  List<String> get viewers => getList(ModelKeys.keyViewers, []);
}

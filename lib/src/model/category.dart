library my_api;

import 'package:my_api/src/model/model.dart';
import 'package:my_api/src/model/transaction.dart';

class Category extends Model {

  static const String keyType = "type";
  static const String keyCategory = "category";
  static const String keyIcon = "icon";
  static const String keyName = "name";

  Category(super.map);

  /// Type
  ///
  /// Default value is [TransactionType.expense]
  TransactionType get type => TransactionType.fromCode(getValue(keyType, 0));

  set type(TransactionType value) => map[keyType] = value.code;

  /// Category
  ///
  /// Default value is `0`
  int get category => getValue(keyCategory, 0);

  set category(int value) => map[keyCategory] = value;

  /// Icon
  ///
  /// Default value is `0`
  int get icon => getValue(keyIcon, 0);

  set icon(int value) => map[keyIcon] = value;

  /// Name
  String get name => getValue(keyName);

  set name(String value) => map[keyName] = value;


}
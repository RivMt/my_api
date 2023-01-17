library my_api;

import 'dart:ui';

import 'package:my_api/src/model/model.dart';

class Account extends Model {

  static const String keyViewers = "viewers";
  static const String keyIcon = "icon";
  static const String keyPriority = "priority";
  static const String keyLimitation = "limitation";
  static const String keyCurrency = "currency";
  static const String keyBalance = "balance";
  static const String keyIsCash = "is_cash";
  static const String keySerialNumber = "serial_number";
  static const String keyForeground = "foreground";
  static const String keyBackground = "background";

  Account(super.map);

  /// List of viewers id
  List<String> get viewers => getValue(keyViewers);

  set viewers(List<String> list) => map[keyViewers] = list;

  /// Index of icon
  int get icon => getValue(keyIcon);

  set icon(int value) => map[keyIcon] = value;

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(keyPriority);

  set priority(int value) => map[keyPriority] = value;

  /// Limitation of this account
  BigInt get limitation => BigInt.parse(getValue(keyLimitation));

  set limitation(BigInt value) => map[keyLimitation] = value.toString();

  /// ID of currency
  int get currency => getValue(keyCurrency);

  set currency(int value) => map[keyCurrency] = value;

  /// Balance of this account
  BigInt get balance => BigInt.parse(getValue(keyBalance));

  set balance(BigInt value) => map[keyBalance] = value.toString();

  /// Is this account handled as cash or not
  bool get isCash => getValue(keyIsCash);

  set isCash(bool value) => map[keyIsCash] = value;

  /// Serial number
  String get serialNumber => getValue(keySerialNumber);

  set serialNumber(String value) => map[keySerialNumber] = value;

  /// Foreground color
  Color get foreground => Color(getValue(keyForeground));

  set foreground(Color color) => map[keyForeground] = color.value;

  /// Background color
  Color get background => Color(getValue(keyBackground));

  set background(Color color) => map[keyBackground] = color.value;

}
library my_api;

import 'dart:ui';

import 'package:my_api/src/model/model.dart';

const String keyViewers = "viewers";
const String keyIcon = "icon";
const String keyPriority = "priority";
const String keyLimitation = "limitation";
const String keyIsCredit = "is_credit";
const String keySerialNumber = "serial_number";
const String keyForeground = "foreground";
const String keyBackground = "background";
const String keyPayBegin = "keyPayBegin";
const String keyPayEnd = "keyPayEnd";
const String keyPayDate = "keyPayDate";

class Payment extends Model {

  /// Minimum day of payment day
  static const int payDayMin = 1;

  /// Maximum day of payment day
  ///
  /// 31th day is regarded as 30th
  static const int payDayMax = 30;

  Payment(super.map);

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

  /// Is this account handled as cash or not
  bool get isCredit => getValue(keyIsCredit);

  set isCredit(bool value) => map[keyIsCredit] = value;

  /// Serial number
  String get serialNumber => getValue(keySerialNumber);

  set serialNumber(String value) => map[keySerialNumber] = value;

  /// Foreground color
  Color get foreground => Color(getValue(keyForeground));

  set foreground(Color color) => map[keyForeground] = color.value;

  /// Background color
  Color get background => Color(getValue(keyBackground));

  set background(Color color) => map[keyBackground] = color.value;

  /// Beginning day of range when this payment paid
  int get payBegin => getValue(keyPayBegin);

  set payBegin(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayBegin] = list[1];
  }

  /// End day of range when this payment paid
  int get payEnd => getValue(keyPayEnd);

  set payEnd(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayEnd] = list[1];
  }

  /// Date of this payment paid on current month
  int get payDate => getValue(keyPayDate);

  set payDate(int value) {
    final list = [payDayMin, value, payDayMax];
    list.sort();
    map[keyPayDate] = list[1];
  }

}
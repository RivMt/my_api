import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';

class WalletItem extends FinanceModel {

  static const String keyPriority = "priority";
  static const String keyLimitation = "limitation";
  static const String keyCurrency = "currency";
  static const String keySerialNumber = "serial_number";
  static const String keyForeground = "foreground";
  static const String keyBackground = "background";

  WalletItem([super.map]);

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(keyPriority, 0);

  set priority(int value) => map[keyPriority] = value;

  /// Limitation of this account
  Decimal get limitation => getDecimal(keyLimitation, Decimal.zero);

  set limitation(Decimal value) => setDecimal(keyLimitation, value);

  /// ID of currency
  /// TODO: Change default value to unknown
  Currency get currency => getCurrency(keyCurrency, Currency.won);

  set currency(Currency currency) => setCurrency(keyCurrency, currency);

  /// Serial number
  String get serialNumber => getValue(keySerialNumber, "");

  set serialNumber(String value) => map[keySerialNumber] = value;

  /// Foreground color
  Color get foreground => getColor(keyForeground, Colors.white);

  set foreground(Color color) => setColor(keyForeground, color);

  /// Background color
  Color get background => getColor(keyBackground, Colors.black);

  set background(Color color) => setColor(keyBackground, color);

}
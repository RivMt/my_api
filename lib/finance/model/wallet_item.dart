import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';

/// Superclass of [Account] and [Payment]
abstract class WalletItem extends FinanceModel {

  WalletItem([super.map]);

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(ModelKeys.keyPriority, 0);

  set priority(int value) => map[ModelKeys.keyPriority] = value;

  /// Limitation of this account
  Decimal get limitation => getDecimal(ModelKeys.keyLimitation, Decimal.zero);

  set limitation(Decimal value) => setDecimal(ModelKeys.keyLimitation, value);

  /// ID of currency
  Currency get currency => getCurrency(ModelKeys.keyCurrency, Currency.unknown);

  set currency(Currency currency) => setCurrency(ModelKeys.keyCurrency, currency);

  /// Serial number
  String get serialNumber => getValue(ModelKeys.keySerialNumber, "");

  set serialNumber(String value) => map[ModelKeys.keySerialNumber] = value;

  /// Foreground color
  Color get foreground => getColor(ModelKeys.keyForeground, Colors.white);

  set foreground(Color color) => setColor(ModelKeys.keyForeground, color);

  /// Background color
  Color get background => getColor(ModelKeys.keyBackground, Colors.black);

  set background(Color color) => setColor(ModelKeys.keyBackground, color);

}
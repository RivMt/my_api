import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';

/// Superclass of [Account] and [Payment]
abstract class WalletItem extends FinanceModel {

  /// Maximum digits of integer part
  static const int maxIntegerPartDigits = 30;

  /// Maximum digits of decimal part
  static const int maxDecimalPartDigits = 2;

  /// Get amount verification [RegExp] by given [currency]
  static RegExp getAmountRegex(Currency currency) {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalPoint));
  }

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
  String get currencyId => getValue(ModelKeys.keyCurrencyId, Currency.unknownUuid);

  set currencyId(String uuid) => map[ModelKeys.keyCurrencyId] = uuid;

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
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/finance_model.dart';

/// A superclass of [Account] and [Payment]
abstract class WalletItem extends FinanceModel {

  /// Maximum digits of integer part
  static const int maxIntegerPartDigits = 30;

  /// Maximum digits of decimal part
  static const int maxDecimalPartDigits = 2;

  /// Get amount verification [RegExp] from given [currency]
  static RegExp getAmountRegex(Currency currency) {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalPoint));
  }

  /// Initialize instance from given [map]
  WalletItem([super.map]);

  /// Priority of this item
  ///
  /// Default value is `0`.
  int get priority => getInt(ModelKeys.keyPriority, 0);

  set priority(int value) => setInt(ModelKeys.keyPriority, value);

  /// Limitation of this item
  ///
  /// Default value is `0`.
  Decimal get limitation => getDecimal(ModelKeys.keyLimitation, Decimal.zero);

  set limitation(Decimal value) => setDecimal(ModelKeys.keyLimitation, value);

  /// UUID of currency
  ///
  /// Default value is [Currency.unknown].
  String get currencyId => getString(ModelKeys.keyCurrencyId, Currency.unknownUuid);

  set currencyId(String uuid) => setString(ModelKeys.keyCurrencyId, uuid);

  /// Serial number of this item
  ///
  /// Default value is empty string
  String get serialNumber => getString(ModelKeys.keySerialNumber, "");

  set serialNumber(String value) => setString(ModelKeys.keySerialNumber, value);

  /// Foreground color
  ///
  /// Default value is [Colors.white].
  Color get foreground => getColor(ModelKeys.keyForeground, Colors.white);

  set foreground(Color color) => setColor(ModelKeys.keyForeground, color);

  /// Background color
  ///
  /// Default value is [Colors.black].
  Color get background => getColor(ModelKeys.keyBackground, Colors.black);

  set background(Color color) => setColor(ModelKeys.keyBackground, color);

}
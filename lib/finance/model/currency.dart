import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_api/finance/icon/currency_symbol_icons.dart';

enum Currency {
  unknown(-1, "¤", "uKn", 2, CurrencySymbol.sign),
  won(0, "￦", "KRW", 0, CurrencySymbol.krw),
  yen(1, "￥", "JPY", 0, CurrencySymbol.jpy),
  dollar(2, "＄", "USD", 2, CurrencySymbol.usd),
  euro(3, "€", "EUR", 2, CurrencySymbol.eur),
  poundSterling(4, "￡", "GBP", 2, CurrencySymbol.gbp),
  yuanRenminbi(5, "¥", "CNY", 2, CurrencySymbol.cny);

  const Currency(this.value, this.symbol, this.code, this.decimalDigits, this.icon);

  /// Unique value of currency
  final int value;

  /// Single letter symbol of currency
  final String symbol;

  /// 3 letter code of currency
  final String code;

  /// Number of decimal part digits
  final int decimalDigits;

  /// [IconData] of symbol
  final IconData icon;

  /// Find [Currency] using [value]
  factory Currency.fromValue(int? value) {
    switch(value) {
      case 0:
        return Currency.won;
      case 1:
        return Currency.yen;
      case 2:
        return Currency.dollar;
      case 3:
        return Currency.euro;
      case 4:
        return Currency.poundSterling;
      case 5:
        return Currency.yuanRenminbi;
      default:
        return Currency.unknown;
    }
  }

  /// Format [amount] to current currency's
  String format(Decimal amount) {
    final currency = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return currency.format(amount);
  }

  /// Format [amount] to current currency's format without symbol
  String formatWithoutSymbol(Decimal amount) {
    final f = format(amount);
    return f.substring(1, f.length);
  }

  /// Convert currency formatted [str] to [Decimal]
  Decimal convert(String str) {
    final regex = RegExp(r"[^\d.]");
    return Decimal.parse(str.replaceAll(regex, ""));
  }

  /// Key for translation
  String get key {
    return "currencyType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
  }

  /// List of all currencies without [unknown]
  static List<Currency> get validValues => values.sublist(1, values.length);
}
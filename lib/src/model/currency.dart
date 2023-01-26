import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

enum Currency {
  unknown(-1, "", "uKn", 2),
  won(0, "￦", "KRW", 0),
  yen(1, "￥", "JPY", 0),
  dollar(2, "＄", "USD", 2),
  euro(3, "€", "EUR", 2),
  poundSterling(4, "￡", "GBP", 2),
  yuanRenminbi(5, "￥", "CNY", 2);

  const Currency(this.value, this.symbol, this.code, this.digits);

  /// Unique value of currency
  final int value;

  /// Single letter symbol of currency
  final String symbol;

  /// 3 letter code of currency
  final String code;

  /// Number of digits
  final int digits;

  /// Find [Currency] using [value]
  factory Currency.fromValue(int value) {
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
      decimalDigits: digits,
    );
    return currency.format(amount);
  }
}
import 'package:my_api/core/model/model.dart';
import 'package:my_api/finance/model/currency.dart';

/// Superclass of all Finance API related models.
class FinanceModel extends Model {


  /// Regular expression for check [Decimal] number
  ///
  /// [maxIntegerPartDigits] is length of integer part, and [maxDecimalPartDigits]
  /// is length of decimal part.
  /// For example, `123.45`'s length of integer part is `3` and decimal part
  /// is `2`.
  ///
  /// It checks only digits of integer part and decimal part. If string has
  /// other letters such as comma(,) or minus sign(-), or any others except
  /// number(0-9) and dot(.), **MUST** remove before using this regex.
  static RegExp getRegex(int maxIntegerPartDigits, int maxDecimalPartDigits) {
    final decimal = maxDecimalPartDigits > 0
        ? "(\\.\\d{0,$maxDecimalPartDigits})?"
        : "";
    final integer = "\\d{0,$maxIntegerPartDigits}";
    return RegExp("^$integer$decimal\$");
  }

  /// Create object using [map]
  FinanceModel([super.map]);

  /// Get [Currency] from [key]
  Currency getCurrency(String key, Currency value) {
    if (!map.containsKey(key)) {
      return value;
    }
    assert(map[key] is int);
    return Currency.fromValue(map[key]);
  }

  /// Set [Currency] to [key]
  void setCurrency(String key, Currency value) {
    map[key] = value.value;
  }
}
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:my_api/src/core/model/model.dart';
import 'package:my_api/src/core/model/model_keys.dart';

/// A currency class
///
/// A currency is consisted of [uuid], [regionCode], [currencyCode] and [symbol]
/// basically.
/// [uuid] is combination of [regionCode] and [currencyCode] which is listed in
/// [ISO-4217](https://en.wikipedia.org/wiki/ISO_4217).
///
/// Also, [unknown] related constant values are defined by above article. So, it
/// is not be edited until the article have been changed. And, the rule defined
/// `XXX` is for no currency transaction, however, it is named [unknown] for
/// unification with other API classes.
class Currency extends Model {

  /// Path of API server endpoint
  static const String endpoint = "api/finance/currencies";

  /// UUID of unknown currency
  ///
  /// This value must be same as [unknownRegionCode] + [unknownCurrencyCode]
  static const String unknownUuid = "XXX";

  /// Region code of unknown currency
  static const String unknownRegionCode = "XX";

  /// Currency code of unknown currency
  static const String unknownCurrencyCode = "X";

  /// Symbol of unknown currency
  static const String unknownSymbol = "¤";

  /// Default decimal point of each currency
  ///
  /// The value is `2` because it is the most popular digits of currencies.
  static const int defaultDecimalPoint = 2;

  /// A unknown currency
  static final Currency unknown = Currency.instance(
    uuid: unknownUuid,
    symbol: unknownSymbol,
    decimalPoint: defaultDecimalPoint,
  );

  /// Initialize instance from given [map]
  Currency([Map<String, dynamic>? map]) : super(map);

  /// Initialize instance with given parameters
  Currency.instance({
    String uuid = unknownUuid,
    String symbol = unknownSymbol,
    int decimalPoint = defaultDecimalPoint,
  }) {
    map[ModelKeys.keyRegionCode] = uuid.substring(0, 2);
    map[ModelKeys.keyCurrencyCode] = uuid.substring(2, 3);
    map[ModelKeys.keySymbol] = symbol;
    map[ModelKeys.keyDecimalPoint] = decimalPoint;
  }

  /// UUID of this currency
  ///
  /// It is combination of [regionCode] and [currencyCode].
  String get uuid {
    final value = getValue(ModelKeys.keyUuid, unknownUuid);
    final combination = "$regionCode$currencyCode";
    return value == combination ? value : unknownUuid;  // TODO: throw exception
  }

  /// Region code of this currency
  ///
  /// Usually it is country code based on [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
  /// However, it can be a region code (e.g. `EU`) or special letter begins with `X`
  /// such as `XA` (gold and silver), `XD` (IMF special drawing rights).
  ///
  /// Default value is [unknownRegionCode].
  String get regionCode => getValue(ModelKeys.keyRegionCode, unknownRegionCode);

  /// Currency code of this currency
  ///
  /// Usually it is first letter of currency name such as `D` for United States Dollar.
  /// However, it can be an another letter due to [regionCode].
  ///
  /// Default value is [unknownCurrencyCode].
  String get currencyCode => getValue(ModelKeys.keyCurrencyCode, unknownCurrencyCode);

  /// Symbol of this currency
  ///
  /// It is a sign of currency, however, it is named `symbol` for unification.
  ///
  /// Default value is [unknownSymbol].
  String get symbol => getValue(ModelKeys.keySymbol, unknownSymbol);

  /// Url of icon
  ///
  /// Default value is empty string.
  String get iconUrl => getValue(ModelKeys.keyIconUrl, "");

  /// Digits of decimal part
  ///
  /// Default value is [defaultDecimalPoint].
  int get decimalPoint => getValue(ModelKeys.keyDecimalPoint, defaultDecimalPoint);

  /// Key for translation
  String get key => "currencyType$uuid";

  /// Formats [amount] to this currency style text
  String format(Decimal amount) {
    final currency = NumberFormat.currency(
      name: uuid,
      symbol: symbol,
      decimalDigits: decimalPoint,
    );
    return currency.format(amount.toDouble());
  }

  /// Formats [amount] to this currency style without [symbol]
  String formatWithoutSymbol(Decimal amount) {
    final f = format(amount);
    return f.substring(1, f.length);
  }

  /// Converts currency formatted [String] to [Decimal]
  ///
  /// Throws [FormatException] when failed to parse [Decimal]
  Decimal convert(String str) {
    final regex = RegExp(r"[^\d.]");
    return Decimal.parse(str.replaceAll(regex, ""));
  }

  @override
  bool isEquivalent(Model other) {
    if (other is Currency) {
      return uuid == other.uuid;
    }
    return this==other;
  }

  @override
  int get representativeCode => uuid.hashCode;

  @override
  String toString() => uuid;
}
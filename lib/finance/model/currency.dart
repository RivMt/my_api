import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';

class Currency extends Model {

  static const String endpoint = "api/finance/currencies";

  static const String unknownUuid = "XXX";

  static const String unknownRegionCode = "XX";

  static const String unknownCurrencyCode = "X";

  static const String unknownSymbol = "¤";

  static const int defaultDecimalPoint = 2;

  static final Currency unknown = Currency.instance(
    uuid: unknownUuid,
    symbol: unknownSymbol,
    decimalPoint: defaultDecimalPoint,
  );

  Currency([Map<String, dynamic>? map]) : super(map);

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

  String get uuid {
    final value = getValue(ModelKeys.keyUuid, unknownUuid);
    final combination = "$regionCode$currencyCode";
    return value == combination ? value : unknownUuid;
  }

  String get regionCode => getValue(ModelKeys.keyRegionCode, unknownRegionCode);

  String get currencyCode => getValue(ModelKeys.keyCurrencyCode, unknownCurrencyCode);

  String get symbol => getValue(ModelKeys.keySymbol, unknownSymbol);

  String get iconUrl => getValue(ModelKeys.keyIconUrl, "");

  int get decimalPoint => getValue(ModelKeys.keyDecimalPoint, defaultDecimalPoint);

  /// Key for translation
  String get key => "currencyType$uuid";

  /// Format [amount] to current currency's
  String format(Decimal amount) {
    final currency = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPoint,
    );
    return currency.format(amount.toDouble());
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
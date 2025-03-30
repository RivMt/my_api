import 'package:my_api/core.dart';
import 'package:my_api/finance/model/transaction.dart';

class RawTransaction extends Transaction {

  static const List<String> columns = [
    ModelKeys.keyUuid,
    ModelKeys.keyType,
    ModelKeys.keyCategoryName,
    ModelKeys.keyAccountName,
    ModelKeys.keyPaymentName,
    ModelKeys.keyCurrencyId,
    ModelKeys.keyAmount,
    ModelKeys.keyAltCurrencyId,
    ModelKeys.keyAltAmount,
    ModelKeys.keyPaidDate,
    ModelKeys.keyCalculatedDate,
    ModelKeys.keyUtilityEnd,
    ModelKeys.keyDescription,
    ModelKeys.keyIncluded,
  ];

  RawTransaction([super.map]);

  /// Name of account
  String get accountName => map[ModelKeys.keyAccountName] ?? "";

  /// Name of payment
  String get paymentName => map[ModelKeys.keyPaymentName] ?? "";

  /// Name of category
  String get categoryName => map[ModelKeys.keyCategoryName] ?? "";

}
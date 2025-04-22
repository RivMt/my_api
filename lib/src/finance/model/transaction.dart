library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:my_api/src/core/model/base_model.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/account.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/finance_model.dart';
import 'package:my_api/src/finance/model/payment.dart';

/// A transaction class
class Transaction extends FinanceModel {

  /// Path of API server endpoint
  static const String endpoint = "api/finance/transactions";

  /// Maximum digits of integer part of [amount]
  static const int maxIntegerPartDigits = 20;

  /// Maximum digits of decimal part of [amount]
  static const int maxDecimalPartDigits = 2;

  /// Default [DateTime] of [calculatedDate]
  static final DateTime defaultCalculatedDate = DateTime(1970, 1, 1, 0, 0, 0, 0, 0);

  /// Get amount verification [RegExp] from given [currency]
  static RegExp getAmountRegex(Currency currency) {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalPoint));
  }

  /// Initialize instance from given [map]
  Transaction([super.map]);

  /// Initialize base instance
  Transaction.init() : super() {
    paidDate = DateTime.now();
    calculatedDate = paidDate;
  }

  @override
  bool get isValid {
    if (categoryId == BaseModel.unknownUuid) return false;
    if (accountId == BaseModel.unknownUuid) return false;
    if (paymentId == BaseModel.unknownUuid) return false;
    if (currencyId == Currency.unknownUuid) return false;
    if (amount <= Decimal.zero) return false;
    if ((altCurrencyId != null && altAmount == null) ||
        (altCurrencyId == null && altAmount != null) ||
        (altCurrencyId == Currency.unknownUuid) ||
        (altAmount != null && altAmount! <= Decimal.zero)
    ) {
      return false;
    }
    if (utilityDays < 1) return false;
    return super.isValid;
  }

  /// Type of this transaction
  ///
  /// Default value is [TransactionType.expense]
  TransactionType get type => TransactionType.fromCode(getInt(ModelKeys.keyType, TransactionType.expense.code));

  set type(TransactionType value) => setInt(ModelKeys.keyType, value.code);

  /// [Category] of this transaction
  ///
  /// Default value is `0`
  String get categoryId => getString(ModelKeys.keyCategoryId, BaseModel.unknownUuid);

  set categoryId(String value) => setString(ModelKeys.keyCategoryId, value);

  /// [DateTime] of this transaction is paid
  ///
  /// Default value is [DateTime.now].
  DateTime get paidDate => getDate(ModelKeys.keyPaidDate, DateTime.now());

  set paidDate(DateTime date) {
    final days = utilityDays;
    setDate(ModelKeys.keyPaidDate, date);
    utilityDays = days;
  }

  /// UUID of [Account] this transaction occurred
  ///
  /// Default value is [Account.unknown].
  String get accountId => getString(ModelKeys.keyAccountId, BaseModel.unknownUuid);

  set accountId(String uuid) => setString(ModelKeys.keyAccountId, uuid);

  /// Set [accountId] and [currencyId] from given [account]
  void setAccount(Account account) {
    accountId = account.uuid;
    currencyId = account.currencyId;
  }

  /// UUID of [Payment] this transaction is paid
  ///
  /// Default value is [Payment.unknown].
  String get paymentId => getString(ModelKeys.keyPaymentId, BaseModel.unknownUuid);

  set paymentId(String uuid) => setString(ModelKeys.keyPaymentId, uuid);

  /// Set [paymentId], [altCurrencyId], and [altAmount] according to [payment]
  ///
  /// [altCurrencyId] and [altAmount] is only set when [currencyId] and currency
  /// id of [payment] is different.
  void setPayment(Payment payment) {
    paymentId = payment.uuid;
    if (payment.currencyId != Currency.unknownUuid && payment.currencyId != currencyId) {
      altCurrencyId = payment.currencyId;
      altAmount = Decimal.zero;
    } else {
      altCurrencyId = null;
      altAmount = null;
    }
  }

  /// UUID of currency
  ///
  /// Default value is [Currency.unknown].
  String get currencyId => getString(ModelKeys.keyCurrencyId, Currency.unknownUuid);

  set currencyId(String uuid) => setString(ModelKeys.keyCurrencyId, uuid);

  /// Amount of this transaction
  ///
  /// Default value is `0`.
  Decimal get amount => getDecimal(ModelKeys.keyAmount, Decimal.zero);

  set amount(Decimal value) => setDecimal(ModelKeys.keyAmount, value);

  /// UUID of alternative currency
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by Euro, and money withdrew from Dollar
  /// account, [altCurrencyId] is `EUR`, and [currencyId] is `USD`.
  ///
  /// Default value is `null`.
  String? get altCurrencyId => getValue<String>(ModelKeys.keyAltCurrencyId, null);

  set altCurrencyId(String? uuid) => setValue<String>(ModelKeys.keyAltCurrencyId, uuid);

  /// Alternative amount of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by 5 euros, and money withdrew 2 dollars from
  /// account, [altAmount] is `5`, and [amount] is `2`.
  ///
  /// Default value is `null`.
  Decimal? get altAmount {
    final value = getValue<String>(ModelKeys.keyAltAmount, null);
    if (value == null) {
      return null;
    }
    return Decimal.parse(value);
  }

  set altAmount(Decimal? value) {
    if (value != null) {
      map[ModelKeys.keyAltAmount] = value.toString();
    } else {
      map[ModelKeys.keyAltAmount] = null;
    }
  }

  /// Whether this transaction has alternative currency and amount or not
  bool get hasAlt => (altCurrencyId != null) || (altAmount != null);

  /// [DateTime] of this transaction is withdrew
  ///
  /// Default value is [defaultCalculatedDate].
  DateTime get calculatedDate => getDate(ModelKeys.keyCalculatedDate, defaultCalculatedDate);

  set calculatedDate(DateTime date) => setDate(ModelKeys.keyCalculatedDate, date);

  /// Whether of this transaction is included in statics or not
  bool get isIncluded => getBool(ModelKeys.keyIncluded, true);

  set isIncluded(bool value) => setBool(ModelKeys.keyIncluded, value);

  /// Last date of this transaction is effective
  @Deprecated("This property is not useful and will be removed in further release")
  DateTime get utilityEnd => getDate(ModelKeys.keyUtilityEnd, paidDate.add(const Duration(seconds: 1)));

  set utilityEnd(DateTime date) => setDate(ModelKeys.keyUtilityEnd, date);

  /// Number of days between [paidDate] and [utilityEnd].
  ///
  /// It includes starting of day, therefore, if [paidDate] and [utilityEnd] is
  /// same day, it is `1`.
  @Deprecated("This property will be removed due to utilityEnd is deprecated")
  int get utilityDays => utilityEnd.difference(paidDate).inDays + 1;

  set utilityDays(int value) => setDate(ModelKeys.keyUtilityEnd, paidDate.add(Duration(
    days: value-1,
    seconds: 1,
  )));

  /// ID of folder
  @Deprecated("This property does not working and will be removed in further release")
  int get folderId => getInt(ModelKeys.keyFolder, 0);

  set folderId(int value) => setInt(ModelKeys.keyFolder, value);

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.write(descriptions);
    buffer.write(" (");
    if (hasAlt) {
      buffer.write(altCurrencyId);
      buffer.write(" ");
      buffer.write(altAmount);
      buffer.write(", ");
    }
    buffer.write(currencyId);
    buffer.write(" ");
    buffer.write(amount);
    buffer.write(")");
    buffer.write(" [$uuid]");
    return buffer.toString();
  }
}

/// A transaction type
enum TransactionType {
  unknown(-1),
  expense(0),
  income(1);

  /// Construct type
  const TransactionType(this.code);

  /// Code of this type
  final int code;

  /// Find corresponding [TransactionType] from given [code]
  ///
  /// Default value is [TransactionType.unknown].
  factory TransactionType.fromCode(int code) {
    switch(code) {
      case 0:
        return TransactionType.expense;
      case 1:
        return TransactionType.income;
      default:
        return TransactionType.unknown;
    }
  }

  /// Returns list of valid types
  ///
  /// It is distinct to [values] which returns all types.
  static List<TransactionType> get types => const [
    TransactionType.expense,
    TransactionType.income,
  ];

  /// Get localization key
  String get key => "transactionType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
}
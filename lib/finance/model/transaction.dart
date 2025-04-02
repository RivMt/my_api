library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:my_api/core/model/base_model.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/payment.dart';

class Transaction extends FinanceModel {

  static const String endpoint = "api/finance/transactions";

  /// Maximum digits of integer part of [amount]
  static const int maxIntegerPartDigits = 20;

  /// Maximum digits of decimal part of [amount]
  static const int maxDecimalPartDigits = 2;

  /// Default [DateTime] of [calculatedDate]
  static final DateTime defaultCalculatedDate = DateTime(1970, 1, 1, 0, 0, 0, 0, 0);

  /// Get amount verification [RegExp] by given [currency]
  static RegExp getAmountRegex(Currency currency) {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalPoint));
  }

  Transaction([super.map]);

  Transaction.init() : super() {
    paidDate = DateTime.now();
    calculatedDate = paidDate;
  }

  /// Check data is valid
  bool get isValid {
    // PID
    if (uuid == BaseModel.unknownUuid) {
      return false;
    }
    // Category
    if (categoryId == BaseModel.unknownUuid) {
      return false;
    }
    // Account
    if (accountId == BaseModel.unknownUuid) {
      return false;
    }
    // Payment
    if (paymentId == BaseModel.unknownUuid) {
      return false;
    }
    // Currency
    if (currencyId == Currency.unknownUuid) {
      return false;
    }
    // Amount
    if (amount <= Decimal.zero) {
      return false;
    }
    // Alt
    if ((altCurrencyId != null && altAmount == null) ||
        (altCurrencyId == null && altAmount != null) ||
        (altCurrencyId == Currency.unknownUuid) ||
        (altAmount != null && altAmount! <= Decimal.zero)
    ) {
      return false;
    }
    // Utility days
    if (utilityDays < 1) {
      return false;
    }
    // Otherwise
    return true;
  }

  /// Type
  ///
  /// Default value is [TransactionType.expense]
  TransactionType get type => TransactionType.fromCode(getValue(ModelKeys.keyType, 0));

  set type(TransactionType value) => map[ModelKeys.keyType] = value.code;

  /// Category
  ///
  /// Default value is `0`
  String get categoryId => getValue(ModelKeys.keyCategoryId, BaseModel.unknownUuid);

  set categoryId(String value) => map[ModelKeys.keyCategoryId] = value;

  /// [DateTime] of this transaction paid
  DateTime get paidDate => getDate(ModelKeys.keyPaidDate, DateTime.now());

  set paidDate(DateTime date) {
    final days = utilityDays;
    setDate(ModelKeys.keyPaidDate, date);
    utilityDays = days;
  }

  /// PID of [Account] this transaction occurred
  String get accountId => getValue(ModelKeys.keyAccountId, BaseModel.unknownUuid);

  set accountId(String uuid) => map[ModelKeys.keyAccountId] = uuid;

  /// Set [accountId] and [currencyId] according to [account]
  void setAccount(Account account) {
    accountId = account.uuid;
    currencyId = account.currencyId;
  }

  /// PID of [Payment] this transaction handled
  String get paymentId => getValue(ModelKeys.keyPaymentId, BaseModel.unknownUuid);

  set paymentId(String uuid) => map[ModelKeys.keyPaymentId] = uuid;

  /// Set [paymentId], [altCurrencyId], and [altAmount] according to [payment]
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

  /// ID of currency
  String get currencyId => getValue(ModelKeys.keyCurrencyId, Currency.unknownUuid);

  set currencyId(String uuid) => map[ModelKeys.keyCurrencyId] = uuid;

  /// Amount of this transaction
  Decimal get amount => Decimal.parse(getValue(ModelKeys.keyAmount, "0"));

  set amount(Decimal value) => map[ModelKeys.keyAmount] = value.toString();

  /// Alternative currency of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by Euro, and money withdrew (or will withdraw) from Dollar
  /// account, [altCurrencyId] is `EUR`, and [currencyId] is `USD`.
  String? get altCurrencyId => getValue(ModelKeys.keyAltCurrencyId, null);

  set altCurrencyId(String? uuid) {
    if (uuid != null) {
      map[ModelKeys.keyAltCurrencyId] = uuid;
    } else {
      map[ModelKeys.keyAltCurrencyId] = null;
    }
  }

  /// Alternative mount of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by 5 euros, and money withdrew (or will withdraw) from 2 dollars
  /// account, [altAmount] is `5`, and [amount] is `2`.
  Decimal? get altAmount {
    final value = getValue(ModelKeys.keyAltAmount, null);
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

  /// Value of alternative is available or not
  bool get hasAlt => (altCurrencyId != null) || (altAmount != null);

  /// [DateTime] of this transaction calculated in LOCAL
  DateTime get calculatedDate => getDate(ModelKeys.keyCalculatedDate, defaultCalculatedDate);

  set calculatedDate(DateTime date) => setDate(ModelKeys.keyCalculatedDate, date);

  /// Value of this transaction included in statics
  bool get isIncluded => getValue(ModelKeys.keyIncluded, true);

  set isIncluded(bool value) => map[ModelKeys.keyIncluded] = value;

  /// Last date of this transaction is utility in LOCAL
  DateTime get utilityEnd => getDate(ModelKeys.keyUtilityEnd, paidDate.add(const Duration(seconds: 1)));

  set utilityEnd(DateTime date) => setDate(ModelKeys.keyUtilityEnd, date);

  /// Number of days between [paidDate] and [utilityEnd].
  ///
  /// It includes starting of day, therefore, if [paidDate] and [utilityEnd] is
  /// same day, it is `1`.
  int get utilityDays => utilityEnd.difference(paidDate).inDays + 1;

  set utilityDays(int value) => setDate(ModelKeys.keyUtilityEnd, paidDate.add(Duration(
    days: value-1,
    seconds: 1,
  )));

  /// ID of folder
  int get folderId => getValue(ModelKeys.keyFolder, 0);

  set folderId(int value) => map[ModelKeys.keyFolder] = value;

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


enum TransactionType {
  unknown(-1),
  expense(0),
  income(1);

  const TransactionType(this.code);

  /// [int] value of [TransactionType]
  final int code;

  /// Find valid [TransactionType] object by [code]
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

  /// Return list of valid types
  static List<TransactionType> get types => const [
    TransactionType.expense,
    TransactionType.income,
  ];

  /// Get localization key
  String get key => "transactionType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
}
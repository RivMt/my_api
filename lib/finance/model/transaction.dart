library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';

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

class Transaction extends FinanceModel {

  static const String keyType = "type";
  static const String keyCategory = "category";
  static const String keyPaidDate = "paid_date";
  static const String keyAccountID = "account_id";
  static const String keyPaymentID = "payment_id";
  static const String keyCurrency = "currency";
  static const String keyAmount = "amount";
  static const String keyAltCurrency = "alt_currency";
  static const String keyAltAmount = "alt_amount";
  static const String keyCalculatedDate = "calculated_date";
  static const String keyIncluded = "included";
  static const String keyUtilityEnd = "utility_end";

  /// Maximum digits of integer part of [amount]
  static const int maxIntegerPartDigits = 20;

  /// Maximum digits of decimal part of [amount]
  static const int maxDecimalPartDigits = 2;

  Transaction(super.map);

  /// Check data is valid
  bool get isValid {
    // PID
    if (map.containsKey(FinanceModel.keyPid) && pid <= 0) {
      return false;
    }
    // Category
    if (category < 0) {
      return false;
    }
    // Account
    if (accountId <= 0) {
      return false;
    }
    // Payment
    if (paymentId < 0) {
      return false;
    }
    // Currency
    if (currency == Currency.unknown) {
      return false;
    }
    // Amount
    if (amount <= Decimal.zero) {
      return false;
    }
    // Alt
    if ((altCurrency != null && altAmount == null) ||
        (altCurrency == null && altAmount != null) ||
        (altCurrency == Currency.unknown) ||
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
  TransactionType get type => TransactionType.fromCode(getValue(keyType, 0));

  set type(TransactionType value) => map[keyType] = value.code;

  /// Category
  ///
  /// Default value is `0`
  int get category => getValue(keyCategory, 0);

  set category(int value) => map[keyCategory] = value;

  /// [DateTime] of this transaction paid
  DateTime get paidDate => getDate(keyPaidDate, DateTime.now());

  set paidDate(DateTime date) {
    final days = utilityDays;
    setDate(keyPaidDate, date);
    utilityDays = days;
  }

  /// PID of [Account] this transaction occurred
  int get accountId => getValue(keyAccountID, 0);

  set accountId(int pid) => map[keyAccountID] = pid;

  /// PID of [Payment] this transaction handled
  int get paymentId => getValue(keyPaymentID, 0);

  set paymentId(int pid) => map[keyPaymentID] = pid;

  /// Currency of this transaction
  Currency get currency => Currency.fromValue(getValue(keyCurrency, Currency.unknown.value));

  set currency(Currency currency) => map[keyCurrency] = currency.value;

  /// Amount of this transaction
  Decimal get amount => Decimal.parse(getValue(keyAmount, "0"));

  set amount(Decimal value) => map[keyAmount] = value.toString();

  /// Alternative currency of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by Euro, and money withdrew (or will withdraw) from Dollar
  /// account, [altCurrency] is Euro, and [currency] is Dollar.
  Currency? get altCurrency {
    final value = getValue(keyAltCurrency, null);
    if (value == null) {
      return null;
    }
    return Currency.fromValue(value);
  }

  set altCurrency(Currency? currency) {
    if (currency != null) {
      map[keyAltCurrency] = currency.value;
    } else {
      map[keyAltCurrency] = null;
    }
  }

  /// Alternative mount of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by 5 euros, and money withdrew (or will withdraw) from 2 dollars
  /// account, [altAmount] is `5`, and [amount] is `2`.
  Decimal? get altAmount {
    final value = getValue(keyAltAmount, null);
    if (value == null) {
      return null;
    }
    return Decimal.parse(value);
  }

  set altAmount(Decimal? value) {
    if (value != null) {
      map[keyAltAmount] = value.toString();
    } else {
      map[keyAltAmount] = null;
    }
  }

  /// [DateTime] of this transaction calculated in LOCAL
  DateTime get calculatedDate => getDate(keyCalculatedDate, DateTime.fromMillisecondsSinceEpoch(0));

  set calculatedDate(DateTime date) => setDate(keyCalculatedDate, date);

  /// Value of this transaction included in statics
  bool get isIncluded => getValue(keyIncluded, true);

  set isIncluded(bool value) => map[keyIncluded] = value;

  /// Last date of this transaction is utility in LOCAL
  DateTime get utilityEnd => getDate(keyUtilityEnd, paidDate.add(const Duration(seconds: 1)));

  set utilityEnd(DateTime date) => setDate(keyUtilityEnd, date);

  /// Number of days between [paidDate] and [utilityEnd].
  ///
  /// It includes starting of day, therefore, if [paidDate] and [utilityEnd] is
  /// same day, it is `1`.
  int get utilityDays => utilityEnd.difference(paidDate).inDays + 1;

  set utilityDays(int value) => setDate(keyUtilityEnd, paidDate.add(Duration(
    days: value-1,
    seconds: 1,
  )));

  /// [RegExp] for verify [amount] and [altAmount]
  RegExp get regex {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalDigits));
  }
}
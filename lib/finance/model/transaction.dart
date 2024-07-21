library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/payment.dart';

class Transaction extends FinanceModel {

  /// Maximum digits of integer part of [amount]
  static const int maxIntegerPartDigits = 20;

  /// Maximum digits of decimal part of [amount]
  static const int maxDecimalPartDigits = 2;

  /// Default [DateTime] of [calculatedDate]
  static final DateTime defaultCalculatedDate = DateTime(1970, 1, 1, 0, 0, 0, 0, 0);

  Transaction([super.map]);

  Transaction.init() : super() {
    paidDate = DateTime.now();
    calculatedDate = paidDate;
  }

  /// Check data is valid
  bool get isValid {
    // PID
    if (map.containsKey(ModelKeys.keyPid) && pid <= 0) {
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
  TransactionType get type => TransactionType.fromCode(getValue(ModelKeys.keyType, 0));

  set type(TransactionType value) => map[ModelKeys.keyType] = value.code;

  /// Category
  ///
  /// Default value is `0`
  int get category => getValue(ModelKeys.keyCategory, 0);

  set category(int value) => map[ModelKeys.keyCategory] = value;

  /// [DateTime] of this transaction paid
  DateTime get paidDate => getDate(ModelKeys.keyPaidDate, DateTime.now());

  set paidDate(DateTime date) {
    final days = utilityDays;
    setDate(ModelKeys.keyPaidDate, date);
    utilityDays = days;
  }

  /// PID of [Account] this transaction occurred
  int get accountId => getValue(ModelKeys.keyAccountID, 0);

  set accountId(int pid) => map[ModelKeys.keyAccountID] = pid;

  /// Set [accountId] and [currency] according to [account]
  void setAccount(Account account) {
    accountId = account.pid;
    currency = account.currency;
  }

  /// PID of [Payment] this transaction handled
  int get paymentId => getValue(ModelKeys.keyPaymentID, 0);

  set paymentId(int pid) => map[ModelKeys.keyPaymentID] = pid;

  /// Set [paymentId], [altCurrency], and [altAmount] according to [payment]
  void setPayment(Payment payment) {
    paymentId = payment.pid;
    if (payment.currency != Currency.unknown && payment.currency != currency) {
      altCurrency = payment.currency;
      altAmount = Decimal.zero;
    } else {
      altCurrency = null;
      altAmount = null;
    }
  }

  /// ID of currency
  Currency get currency => getCurrency(ModelKeys.keyCurrency, Currency.unknown);

  set currency(Currency currency) => setCurrency(ModelKeys.keyCurrency, currency);

  /// Amount of this transaction
  Decimal get amount => Decimal.parse(getValue(ModelKeys.keyAmount, "0"));

  set amount(Decimal value) => map[ModelKeys.keyAmount] = value.toString();

  /// Alternative currency of this transaction
  ///
  /// This is used for foreign currency transaction. For example, transaction
  /// is paid by Euro, and money withdrew (or will withdraw) from Dollar
  /// account, [altCurrency] is Euro, and [currency] is Dollar.
  Currency? get altCurrency {
    final value = getValue(ModelKeys.keyAltCurrency, null);
    if (value == null) {
      return null;
    }
    return Currency.fromValue(value);
  }

  set altCurrency(Currency? currency) {
    if (currency != null) {
      map[ModelKeys.keyAltCurrency] = currency.value;
    } else {
      map[ModelKeys.keyAltCurrency] = null;
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

  /// [RegExp] for verify [amount] and [altAmount]
  RegExp get regex {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalDigits));
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
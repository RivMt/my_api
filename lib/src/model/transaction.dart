library my_api;

import 'package:decimal/decimal.dart';
import 'package:my_api/src/model/model.dart';

enum TransactionType {
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
        throw RangeError("$code is not valid code");
    }
  }
}

class Transaction extends Model {

  static const String keyType = "type";
  static const String keyCategory = "category";
  static const String keyPaidDate = "paid_date";
  static const String keyAccountID = "account_id";
  static const String keyPaymentID = "payment_id";
  static const String keyAmount = "amount";
  static const String keyCalculatedDate = "calculated_date";
  static const String keyIncluded = "included";
  static const String keyEfficiencyDate = "efficiency_date";

  Transaction(super.map);

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
  DateTime get paidDate => DateTime.fromMillisecondsSinceEpoch(getValue(keyPaidDate));

  set paidDate(DateTime date) => map[keyPaidDate] = date.millisecondsSinceEpoch;

  /// PID of [Account] this transaction occurred
  int get accountId => getValue(keyAccountID);

  set accountId(int pid) => map[keyAccountID] = pid;

  /// PID of [Payment] this transaction handled
  int get paymentId => getValue(keyPaymentID);

  set paymentId(int pid) => map[keyPaymentID] = pid;

  /// Amount of this transaction
  Decimal get amount => Decimal.parse(getValue(keyAmount));

  set amount(Decimal value) => map[keyAmount] = value.toString();

  /// [DateTime] of this transaction calculated
  DateTime get calculatedDate => DateTime.fromMillisecondsSinceEpoch(getValue(keyCalculatedDate));

  set calculatedDate(DateTime date) => map[keyCalculatedDate] = date.millisecondsSinceEpoch;

  /// Value of this transaction included in statics
  bool get included => getValue(keyIncluded);

  set included(bool value) => map[keyIncluded] = value;

  /// Days of this transaction is efficient
  int get efficiencyDate => getValue(keyEfficiencyDate, 1);

  set efficiencyDate(int value) => map[keyEfficiencyDate] = value;


}
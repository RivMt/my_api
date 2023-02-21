import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core.dart';
import 'package:my_api/core/model/model.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

class FinanceSearchResult extends Model {

  static const String keyGroup = "grp";
  static const String keyOwner = "owner_id";
  static const String keyEditors = "editors_id";
  static const String keyViewers = "viewers_id";
  static const String keyPid = "pid";
  static const String keyIcon = "icon";
  static const String keyForeground = "foreground";
  static const String keyBackground = "background";
  static const String keyMainText = "main_text";
  static const String keySubText = "sub_text";
  static const String keyType = "type";
  static const String keyCurrency = "currency";
  static const String keyTags = "tags";

  FinanceSearchResult(super.map);

  FinanceModel convert() {
    switch(group) {
      case Account:
        final Account data = Account(map);
        data.descriptions = mainText;
        data.serialNumber = subText;
        return data;
      case Payment:
        final Payment data = Payment(map);
        data.descriptions = mainText;
        data.serialNumber = subText;
        return data;
      case Transaction:
        final Transaction data = Transaction(map);
        data.amount = Decimal.parse(mainText);
        data.descriptions = subText;
        return data;
    }
    throw InvalidModelException(keyGroup);
  }

  dynamic get group {
    final value = getValue(keyGroup, "");
    switch(value) {
      case "accounts":
        return Account;
      case "payments":
        return Payment;
      case "transactions":
        return Transaction;
      default:
        throw UnsupportedError("$value is not defined class");
    }
  }

  /// Owner ID of this data
  String get owner => getValue(keyOwner, "");

  /// List of editors ID
  List<String> get editors => (getValue(keyEditors, "") as String).split(" ");

  /// List of viewers ID
  List<String> get viewers => (getValue(keyViewers, "") as String).split(" ");

  /// Pid of this data
  int get pid => getValue(keyPid, -1);

  /// Icon index
  int get icon => getValue(keyIcon, 0);

  /// Foreground [Color]
  Color get foreground => Color(getValue(keyForeground, Colors.white.value));

  /// Background [Color]
  Color get background => Color(getValue(keyBackground, Colors.black.value));

  /// Main text
  String get mainText => getValue(keyMainText, "");

  /// Sub text
  String get subText => getValue(keySubText, "");

  /// Type
  int get type => getValue(keyType, 0);

  /// Currency
  Currency get currency => Currency.fromValue(getValue(keyCurrency, -1));

  /// Tag of this data
  String get tags => getValue(keyTags, "");

}
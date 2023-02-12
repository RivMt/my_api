library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';

class Account extends FinanceModel {

  static const String keyViewers = "viewers";
  static const String keyIcon = "icon";
  static const String keyPriority = "priority";
  static const String keyLimitation = "limitation";
  static const String keyCurrency = "currency";
  static const String keyBalance = "balance";
  static const String keyIsCash = "is_cash";
  static const String keySerialNumber = "serial_number";
  static const String keyForeground = "foreground";
  static const String keyBackground = "background";

  /// Maximum digits of integer part
  static const int maxIntegerPartDigits = 30;

  /// Maximum digits of decimal part
  static const int maxDecimalPartDigits = 2;

  static final Account unknown = Account({
    FinanceModel.keyPid: -1,
    FinanceModel.keyDescriptions: "Unknown",
  });

  Account(super.map);

  bool get isValid {
    // Pid
    if (map.containsKey(FinanceModel.keyPid) && pid < 0) {
      return false;
    }
    // Description
    if (descriptions == "") {
      return false;
    }
    // Currency
    if (currency == Currency.unknown) {
      return false;
    }
    // Otherwise
    return true;
  }

  /// [RegExp] for verify [amount] and [altAmount]
  RegExp get regex {
    return FinanceModel.getRegex(maxIntegerPartDigits, min(maxDecimalPartDigits, currency.decimalDigits));
  }

  /// List of viewers id
  List<String> get viewers => getValue(keyViewers, []);

  set viewers(List<String> list) => map[keyViewers] = list;

  /// Index of icon
  AccountSymbol get icon => AccountSymbol.fromId(getValue(keyIcon, AccountSymbol.account.id));

  set icon(AccountSymbol icon) => map[keyIcon] = icon.id;

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(keyPriority, 0);

  set priority(int value) => map[keyPriority] = value;

  /// Limitation of this account
  Decimal get limitation => Decimal.parse(getValue(keyLimitation, "0"));

  set limitation(Decimal value) => map[keyLimitation] = value.toString();

  /// ID of currency
  Currency get currency => Currency.fromValue(getValue(keyCurrency, Currency.won.value));

  set currency(Currency currency) => map[keyCurrency] = currency.value;

  /// Balance of this account
  Decimal get balance => Decimal.parse(getValue(keyBalance, "0"));

  set balance(Decimal value) => map[keyBalance] = value.toString();

  /// Is this account handled as cash or not
  bool get isCash => getValue(keyIsCash, true);

  set isCash(bool value) => map[keyIsCash] = value;

  /// Serial number
  String get serialNumber => getValue(keySerialNumber, "");

  set serialNumber(String value) => map[keySerialNumber] = value;

  /// Foreground color
  Color get foreground => Color(getValue(keyForeground, -1));

  set foreground(Color color) => map[keyForeground] = color.value;

  /// Background color
  Color get background => Color(getValue(keyBackground, 1));

  set background(Color color) => map[keyBackground] = color.value;

}

enum AccountSymbol {
  saving(0, Icons.savings_outlined),
  account(1, Icons.folder_outlined),
  cash(2, Icons.money),
  point(3, Icons.toll_outlined),
  limitedLoan(4, Icons.drive_file_move_outline),
  transportationCard(5, Icons.toys_outlined),
  shared(6, Icons.folder_shared_outlined),
  virtual(7, Icons.snippet_folder_outlined),
  investment(8, Icons.drive_folder_upload),
  prepaid(9, Icons.local_atm),
  mileage(10, Icons.airplane_ticket_outlined);


  const AccountSymbol(this.id, this.icon);

  /// Unique value
  final int id;

  /// [IconData]
  final IconData icon;

  /// Name for translation
  String get key {
    return "accountType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
  }

  /// Find icon using [id]
  factory AccountSymbol.fromId(int id) {
    // Check id value
    if (id < 0 || id >= AccountSymbol.values.length) {
      return AccountSymbol.account;
    }
    return AccountSymbol.values[id];
  }

}
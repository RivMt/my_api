library my_api;

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core/model/model.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/wallet_item.dart';

class Account extends WalletItem {

  static const String keyIcon = "icon";
  static const String keyBalance = "balance";
  static const String keyIsCash = "is_cash";

  /// Maximum digits of integer part
  static const int maxIntegerPartDigits = 30;

  /// Maximum digits of decimal part
  static const int maxDecimalPartDigits = 2;

  /// Unknown account
  static final Account unknown = Account({
    Model.keyPid: -1,
    Model.keyDescriptions: "Unknown",
  });

  Account([super.map]);

  bool get isValid {
    // Pid
    if (map.containsKey(Model.keyPid) && pid < 0) {
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

  /// Index of icon
  AccountSymbol get icon => AccountSymbol.fromId(getValue(keyIcon, AccountSymbol.account.id));

  set icon(AccountSymbol icon) => map[keyIcon] = icon.id;

  /// Balance of this account
  Decimal get balance => Decimal.parse(getValue(keyBalance, "0"));

  set balance(Decimal value) => map[keyBalance] = value.toString();

  /// Is this account handled as cash or not
  bool get isCash => getValue(keyIsCash, true);

  set isCash(bool value) => map[keyIsCash] = value;

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
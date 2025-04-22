library my_api;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/base_model.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/model/wallet_item.dart';

/// A finance account class
class Account extends WalletItem {

  /// Path of API server endpoint
  static const String endpoint = "api/finance/accounts";

  /// Unknown account instance
  static final Account unknown = Account({
    ModelKeys.keyUuid: BaseModel.unknownUuid,
    ModelKeys.keyDescription: "Unknown",
  });

  /// Initialize from given [map]
  Account([super.map]);

  /// Whether this model is valid or not
  bool get isValid {
    // UUID
    if (uuid == BaseModel.unknownUuid) {
      return false;
    }
    // Description
    if (name.isEmpty) {
      return false;
    }
    // Currency
    if (currencyId == Currency.unknownUuid) {
      return false;
    }
    // Otherwise
    return true;
  }

  /// Icon of this account
  ///
  /// Default value is [AccountSymbol.account]
  AccountSymbol get icon => AccountSymbol.fromId(getValue(ModelKeys.keyIcon, AccountSymbol.account.id));

  set icon(AccountSymbol icon) => map[ModelKeys.keyIcon] = icon.id;

  /// Balance of this account
  ///
  /// Default value is `0`
  Decimal get balance => Decimal.parse(getValue(ModelKeys.keyBalance, "0"));

  set balance(Decimal value) => map[ModelKeys.keyBalance] = value.toString();

  /// Whether this account is cash or not
  ///
  /// Default value is `true`
  bool get isCash => getValue(ModelKeys.keyIsCash, true);

  set isCash(bool value) => map[ModelKeys.keyIsCash] = value;

  @override
  String toString() => "$name ($currencyId $balance)";

}

/// A symbol of account
enum AccountSymbol {
  saving(0, Icons.savings_outlined),
  account(1, Icons.folder_outlined),
  cash(2, Icons.money),
  point(3, Icons.toll_outlined),
  limitedLoan(4, Icons.drive_file_move_outline),
  transportationCard(5, Icons.train_outlined),
  shared(6, Icons.folder_shared_outlined),
  virtual(7, Icons.snippet_folder_outlined),
  investment(8, Icons.drive_folder_upload),
  prepaid(9, Icons.local_atm),
  mileage(10, Icons.airplane_ticket_outlined);

  /// Construct a symbol
  const AccountSymbol(this.id, this.icon);

  /// Unique value of this symbol
  final int id;

  /// [IconData] of this symbol
  final IconData icon;

  /// Name for translation
  String get key {
    return "accountType${name.substring(0,1).toUpperCase()}${name.substring(1,name.length)}";
  }

  /// Find corresponding symbol from [id]
  ///
  /// Default value is [AccountSymbol.account].
  factory AccountSymbol.fromId(int id) {
    // Check id value
    if (id < 0 || id >= AccountSymbol.values.length) {
      return AccountSymbol.account;
    }
    return AccountSymbol.values[id];
  }

}
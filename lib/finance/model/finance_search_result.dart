import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:my_api/core/exceptions.dart';
import 'package:my_api/core/model/model.dart';
import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/finance/model/account.dart';
import 'package:my_api/finance/model/currency.dart';
import 'package:my_api/finance/model/finance_model.dart';
import 'package:my_api/finance/model/payment.dart';
import 'package:my_api/finance/model/transaction.dart';

class FinanceSearchResult extends Model {

  FinanceSearchResult([super.map]);

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
    throw InvalidModelException(ModelKeys.keyGroup);
  }

  dynamic get group {
    final value = getValue(ModelKeys.keyGroup, "");
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

  /// Icon index
  int get icon => getValue(ModelKeys.keyIcon, 0);

  /// Foreground [Color]
  Color get foreground => Color(getValue(ModelKeys.keyForeground, Colors.white.value));

  /// Background [Color]
  Color get background => Color(getValue(ModelKeys.keyBackground, Colors.black.value));

  /// Main text
  String get mainText => getValue(ModelKeys.keyMainText, "");

  /// Sub text
  String get subText => getValue(ModelKeys.keySubText, "");

  /// Type
  int get type => getValue(ModelKeys.keyType, 0);

  /// Currency
  Currency get currency => Currency.fromValue(getValue(ModelKeys.keyCurrency, -1));

  /// Tag of this data
  String get tags => getValue(ModelKeys.keyTags, "");

}
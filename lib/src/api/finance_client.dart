library my_api;

import 'package:my_api/src/api/base_client.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/category.dart';
import 'package:my_api/src/model/model.dart';
import 'package:my_api/src/model/payment.dart';
import 'package:my_api/src/model/transaction.dart';

class FinanceClient extends BaseClient {

  /// Private instance for singleton pattern
  static final FinanceClient _instance = FinanceClient._();

  /// Private constructor for singleton pattern
  FinanceClient._();

  /// Factory constructor for singleton pattern
  factory FinanceClient() => _instance;
  
  /// Accounts link
  final String accounts = "accounts";
  
  /// Payments link
  final String payments = "payments";
  
  /// Transactions link
  final String transactions = "transactions";
  
  /// Categories link
  final String categories = "categories";

  /// Home link
  @override
  final String home = "finance/v1";

  @override
  FinanceModel convert<T>(Map<String, dynamic> map, [String key = "data"]) {
    final data = (key == "") ? map : map[key];
    switch(T) {
      case Account:
        return Account(data);
      case Payment:
        return Payment(data);
      case Transaction:
        return Transaction(data);
      case Category:
        return Category(data);
      default:
        throw UnimplementedError();
    }
  }

  @override
  String path<T>() {
    switch(T) {
      case Account:
        return "accounts";
      case Payment:
        return "payments";
      case Transaction:
        return "transactions";
      case Category:
        return "categories";
      default:
        throw UnimplementedError();
    }
  }



}
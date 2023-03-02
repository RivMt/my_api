import 'package:my_api/core/model/model_keys.dart';
import 'package:my_api/core/model/search_result.dart';
import 'package:my_api/finance/model/finance_model.dart';

class FinanceSearchResult extends SearchResult {

  FinanceSearchResult([super.map]);

  /// Name of table
  @override
  dynamic get table {
    final value = getValue(ModelKeys.keyTable, "");
    switch(value) {
      case "accounts":
        return FinanceModelType.account;
      case "payments":
        return FinanceModelType.payment;
      case "transactions":
        return FinanceModelType.transaction;
      case "categories":
        return FinanceModelType.category;
      default:
        throw UnsupportedError("$value is not defined class");
    }
  }

}
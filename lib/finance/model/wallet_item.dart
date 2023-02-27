import 'package:my_api/finance/model/finance_model.dart';

class WalletItem extends FinanceModel {

  static const String keyPriority = "priority";

  WalletItem(super.map);

  /// Priority
  ///
  /// Default value is `0`
  int get priority => getValue(keyPriority, 0);

  set priority(int value) => map[keyPriority] = value;

}
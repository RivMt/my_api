import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/finance/model/account.dart';

void main() {
  group("Property Test", () {
    test('Balance copy identification', () {
      Account a = Account({});
      a.balance = Decimal.parse("1000");
      Account b = Account(a.map);
      expect(b.balance, a.balance);
    });
  });
}

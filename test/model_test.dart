import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/model/account.dart';

void main() {
  group("Account Test", () {
    test('Account BigInt copy identification', () {
      Account a = Account({});
      a.balance = BigInt.from(1000);
      Account b = Account(a.map);
      expect(b.balance, a.balance);
    });
  });
}

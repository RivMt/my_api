import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/api/finance_client.dart';
import 'package:my_api/model/account.dart';

void main() async {
  group('Accounts', () {
    test('Get accounts', () async {
      const int pid = 1672730003701;
      // Generate finance client
      final FinanceClient client = FinanceClient();
      client.set(url: "http://127.0.0.1:20005", id: "none");

      // Get accounts
      final List<dynamic> result = await client.get<Account>({
        "pid": pid,
      });
      final Account a = Account(result[0]);

      // Expect
      expect(pid, a.pid);
    });
  });
}

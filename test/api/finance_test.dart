import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/finance_client.dart';
import 'package:my_api/src/model/account.dart';

void main() async {
  group('Accounts', () {
    test('Get accounts', () async {
      const int pid = 1672730003701;
      // Generate finance client
      final FinanceClient client = FinanceClient();
      client.set(url: "http://127.0.0.1:20005", id: "none");

      // Get accounts
      final ApiResponse response = await client.readAccounts({
        "pid": pid,
      });
      final List result = response.data;
      final Account a = Account(result[0]);

      // Expect
      expect(pid, a.pid);
    });
  });
}

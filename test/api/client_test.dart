import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/api/api_core.dart';
import 'package:my_api/src/api/api_client.dart';
import 'package:my_api/src/model/account.dart';

void main() async {
  group('Type conversion', () {
    test('FinanceClient check', () async {
      final Account account = Account({"pid": 1});
      final Account result = ApiClient().convert<Account>(account.map, "") as Account;
      expect(account.pid, result.pid);
    });
    test('ApiResponse check', () async {
      final List<Account> accounts = [Account({"pid": 1})];
      final response = ApiResponse<Map<String, dynamic>>(
        result: ApiResultCode.success,
        data: accounts[0].map,
      );
      final result = response.converts<Account>(accounts);
      expect(accounts[0].pid, result.data[0].pid);
    });
    test('List conversion check', () async {
      final map = {
        "data": [
          {
            "pid": 1,
          },
          {
            "pid": 2,
          },
          {
            "pid": 3,
          },
        ]
      };
      final result = ApiClient().converts<Account>(map);
      expect(map['data']!.length, result.length);
    });
  });
}

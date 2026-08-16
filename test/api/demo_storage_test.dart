import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _accounts = 'api/finance/accounts';
const _categories = 'api/finance/categories';
const _currencies = 'api/finance/currencies';
const _preferences = 'api/core/preferences';
const _transactions = 'api/finance/transactions';

void main() {
  late DemoStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = DemoStorage();
    await storage.init();
  });

  test('persists CRUD data and applies filters and sorting', () async {
    final first = await storage.create(_categories, {
      'name': 'Food',
      'type': 0,
      'included': true,
    });
    final second = await storage.create(_categories, {
      'name': 'Salary',
      'type': 1,
      'included': true,
    });

    final filtered = await storage.read(_categories, {
      'type': '1',
      'sort_field': 'name',
      'sort_order': 'desc',
    });
    expect(filtered.map((item) => item['name']), ['Salary']);

    await storage.update(_categories, {...second, 'name': 'Income'});
    final reloaded = DemoStorage();
    await reloaded.init();
    expect(
      (await reloaded.read(_categories))
          .firstWhere((item) => item['uuid'] == second['uuid'])['name'],
      'Income',
    );

    await storage.delete('$_categories/${first['uuid']}');
    expect(await storage.read(_categories), hasLength(1));
  });

  test('upserts preferences by section, owner, and key', () async {
    await storage.create(_preferences, {
      'section': 'finance',
      'owner_id': User.demoId,
      'pref_key': 'currency',
      'pref_value': 'sXXX',
    });
    await storage.update(_preferences, {
      'section': 'finance',
      'owner_id': User.demoId,
      'pref_key': 'currency',
      'pref_value': 'sJPY',
    });

    final result = await storage.read(_preferences, {
      'section': 'finance',
    });
    expect(result, hasLength(1));
    expect(result.single['pref_value'], 'sJPY');
  });

  test('persists seeded demo currencies', () async {
    await storage.seed(_currencies, [
      {
        'uuid': 'USD',
        'region_code': 'US',
        'currency_code': 'D',
        'symbol': r'$',
        'icon_url': '',
        'decimal_point': 2,
      },
    ]);
    await storage.seed(_currencies, const []);
    final currencies = await storage.read(_currencies, {
      'sort_field': 'uuid',
      'sort_order': 'asc',
    });

    expect(currencies, hasLength(1));
    expect(currencies.single['uuid'], 'USD');
  });

  test('resets every persisted demo table', () async {
    await storage.seed(_currencies, [
      {'uuid': 'USD'},
    ]);
    await storage.create(_accounts, {'name': 'Cash'});
    await storage.create(_categories, {'name': 'Food'});

    await storage.reset();

    expect(await storage.read(_currencies), isEmpty);
    expect(await storage.read(_accounts), isEmpty);
    expect(await storage.read(_categories), isEmpty);
  });

  test('calculates account balances and transaction statistics', () async {
    final account = await storage.create(_accounts, {'name': 'Cash'});
    await storage.create(_transactions, {
      'name': 'Coffee',
      'account_id': account['uuid'],
      'amount': '12.50',
      'type': 0,
      'calculated_date': '2020-01-01',
    });
    await storage.create(_transactions, {
      'name': 'Refund',
      'account_id': account['uuid'],
      'amount': '2.50',
      'type': 1,
      'calculated_date': '2020-01-02',
    });

    final accounts = await storage.read(_accounts);
    expect(double.parse(accounts.single['balance']), -10);

    final stats = await storage.stats(_transactions);
    expect(double.parse(stats['total']), 15);
    expect(stats['average'], '7.50');
    expect(stats['count'], '2');
  });

  test('searches transaction and related model text', () async {
    final account = await storage.create(_accounts, {'name': 'Daily wallet'});
    await storage.create(_transactions, {
      'name': 'Coffee',
      'account_id': account['uuid'],
      'amount': '4.00',
      'calculated_date': '2020-01-01',
    });
    await storage.create(_transactions, {
      'name': 'Book',
      'amount': '20.00',
      'calculated_date': '2020-01-01',
    });

    expect(
        await storage.search('$_transactions/search', 'coffee'), hasLength(1));
    expect(
      await storage.search('$_transactions/search', 'daily wallet'),
      hasLength(1),
    );
  });
}

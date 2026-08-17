import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/finance/model/currency.dart';
import 'package:my_api/src/finance/widget/currency_symbol.dart';

void main() {
  Currency currency({String iconUrl = ''}) => Currency({
        'uuid': 'USD',
        'region_code': 'US',
        'currency_code': 'D',
        'symbol': r'$',
        'icon_url': iconUrl,
      });

  testWidgets('uses the bundled asset when iconUrl is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CurrencySymbol(currency())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text(r'$'), findsNothing);
  });

  testWidgets('uses the bundled asset when iconUrl cannot be loaded',
      (tester) async {
    late BuildContext context;
    late SvgPicture remotePicture;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            remotePicture = CurrencySymbol(
              currency(iconUrl: 'not-a-valid-icon-url'),
            ).build(builderContext) as SvgPicture;
            return const SizedBox();
          },
        ),
      ),
    );

    final assetFallback = remotePicture.errorBuilder!(
      context,
      StateError('invalid icon URL'),
      StackTrace.empty,
    );
    await tester.pumpWidget(MaterialApp(home: assetFallback));
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).toString(),
      contains('currency-usd.svg'),
    );
  });

  testWidgets('uses the text symbol when no bundled asset exists',
      (tester) async {
    final unsupportedCurrency = Currency({
      'uuid': 'ZZZ',
      'region_code': 'ZZ',
      'currency_code': 'Z',
      'symbol': 'Z',
      'icon_url': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CurrencySymbol(unsupportedCurrency, color: Colors.purple),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Z'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Z')).style?.color, Colors.purple);
  });
}

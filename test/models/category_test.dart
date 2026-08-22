import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/finance/model/category.dart';
import 'package:my_api/src/finance/model/transaction.dart';

void main() {
  group("Transfer categories", () {
    test("transferTo is an excluded expense category", () {
      expect(Category.transferTo.uuid, "-2");
      expect(Category.transferTo.type, TransactionType.expense);
      expect(Category.transferTo.isIncluded, false);
    });

    test("transferFrom is an excluded income category", () {
      expect(Category.transferFrom.uuid, "-3");
      expect(Category.transferFrom.type, TransactionType.income);
      expect(Category.transferFrom.isIncluded, false);
    });
  });
}

import 'package:my_api/core.dart';
import 'package:my_api/finance.dart';
import 'package:test/test.dart';

class _FeatureModel extends BaseModel
    with NamableModel, DescriptableModel, DeletableModel, PermittableModel {
  _FeatureModel([super.map]);
}

void main() {
  group('model mixins', () {
    test('read and write only their serialized fields', () {
      final model = _FeatureModel({
        ModelKeys.keyUuid: 'resource-id',
        ModelKeys.keyOwner: 'owner-id',
        ModelKeys.keyEditors: ['editor-id', 7],
        ModelKeys.keyViewers: ['viewer-id'],
      });

      model.name = 'Wallet';
      model.descriptions = 'Daily spending';
      model.deleted = true;

      expect(model.name, 'Wallet');
      expect(model.descriptions, 'Daily spending');
      expect(model.deleted, isTrue);
      expect(model.owner, 'owner-id');
      expect(model.editors, ['editor-id', '7']);
      expect(model.viewers, ['viewer-id']);
      expect(model.map[ModelKeys.keyName], 'Wallet');
      expect(model.map[ModelKeys.keyDescription], 'Daily spending');
      expect(model.map[ModelKeys.keyDeleted], isTrue);
    });

    test('truncate mutable text fields to the model limit', () {
      final model = _FeatureModel();
      final longText = 'a' * (BaseModel.maxTextLength + 1);

      model.name = longText;
      model.descriptions = longText;

      expect(model.name, hasLength(BaseModel.maxTextLength));
      expect(model.descriptions, hasLength(BaseModel.maxTextLength));
    });

    test('finance resources compose only supported features', () {
      expect(Account({}), isA<NamableModel>());
      expect(Account({}), isA<DescriptableModel>());
      expect(Account({}), isA<DeletableModel>());
      expect(Account({}), isA<PermittableModel>());
      expect(Category({}), isA<NamableModel>());
      expect(Transaction({}), isNot(isA<NamableModel>()));
      expect(Transaction({}), isA<DescriptableModel>());
      expect(Transaction({}), isA<DeletableModel>());
      expect(Transaction({}), isA<PermittableModel>());
    });
  });
}

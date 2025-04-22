import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_api/src/core/model/model_keys.dart';
import 'package:my_api/src/core/model/preference.dart';
import 'package:my_api/src/core/model/preference_element.dart';
import 'package:my_api/src/core/model/preference_root.dart';

void main() {
  group('Encode/Decode Test', () {
    const key = "test";
    final root = PreferenceRoot("test", {});
    test('Integer', () {
      const value = 0;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('String', () {
      const value = "TEST";
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Decimal', () {
      final value = Decimal.parse("1.52");
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('double', () {
      const value = 0.5;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Bool', () {
      const value = false;
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('List', () {
      const value = ["A", "B", "C"];
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Nested List', () {
      const value = [["A", 1, ["N!=1"]], "B", ",,,,,"];
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value, value);
    });
    test('Map', () {
      final value = {
        "A": 0,
        "B": Decimal.zero,
        "0": "Hi"
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.map, value);
    });
    test('Nested Map', () {
      final value = {
        "A": {
          "1": "one",
          "Two": 2,
          "Decimal.one": "Data"
        },
        "B": [1, 2, "::::"],
        "0": "Hi"
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.map, value);
    });
    test('Complex Structure', () {
      final value = {
        "M{I0:I1}": {0:1},
        "L[0,1]": [0,1],
        "M{L[0]:L[1]}": {[0]: [1]},
        "L[M{I0:I0}]": [{0:1}],
      };
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.rawValue, Preference.encode(value));
    });
    test('DateTime', () {
      final value = DateTime.now();
      final PreferenceElement pref = PreferenceElement(parent: root, key: key, value: value);
      expect(pref.value.year, value.year);
      expect(pref.value.month, value.month);
      expect(pref.value.day, value.day);
      expect(pref.value.hour, value.hour);
      expect(pref.value.minute, value.minute);
      expect(pref.value.second, value.second);
      expect(pref.value.millisecond, value.millisecond);
      expect(pref.value.isUtc, value.isUtc);
    });
    test('Equality', () {
      const value = 0;
      final PreferenceElement a = PreferenceElement(parent: root, key: key, value: value);
      final PreferenceElement b = PreferenceElement(parent: root, key: key, value: value);
      expect(a, b);
    });
  });
  group("PreferenceRoot Test", () {
    test('Full tree conversion', () {
      final root = PreferenceRoot("abc", {});
      const raw = [
        {
          ModelKeys.keySection: "abc",
          ModelKeys.keyOwner: "",
          ModelKeys.keyPreferenceKey: "key1",
          ModelKeys.keyPreferenceValue: "I0"
        }, {
          ModelKeys.keySection: "abc",
          ModelKeys.keyOwner: "",
          ModelKeys.keyPreferenceKey: "key2",
          ModelKeys.keyPreferenceValue: "Btrue"
        }
      ];
      for(Map<String, dynamic> map in raw) {
        root.setChild(PreferenceElement.fromMap(root, map));
      }
      expect(root.rawChildren(""), raw);
    });
  });
}

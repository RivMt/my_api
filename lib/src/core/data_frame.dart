import 'package:my_api/src/core/log.dart';
import 'package:my_api/src/core/model/base_model.dart';

const _tag = "DataFrame";


/// A data frame for [BaseModel]
///
///
class DataFrame<T extends BaseModel> {

  DataFrame({
    this.columns = const [],
    this.data = const [],
    this.conversions = const {},
  });

  /// List of column names
  ///
  /// Column names must be same as [T]'s each key.
  List<String> columns;

  /// List of data which type is [T]
  List<T> data;

  /// Conversion functions
  Map<String, Object Function(dynamic)> conversions;

  /// Convert to csv
  String toCsv({
    String separator = ",",
    String newLine = "\r\n",
    String escape = '"',
  }) {
    final StringBuffer buffer = StringBuffer();
    // Header
    buffer.write(List.generate(columns.length, (index) {
      return _toValidCsvField(
        value: columns[index],
        separator: separator,
        newLine: newLine,
        escape: escape,
      );
    }).join(separator));
    buffer.write(newLine);
    // Content
    for(T item in data) {
      buffer.write(List.generate(columns.length, (index) {
        final key = columns[index];
        Object value;
        // Check value exist
        if (item.map.containsKey(key)) {
          value = item.map[columns[index]] ?? "";
          // Check conversion exist
          if (conversions.containsKey(key)) {
            value = conversions[key]!(value);
          }
        } else {
          Log.e(_tag, "$key does not exist in ${item.uuid}");
          value = "";
        }
        return _toValidCsvField(
          value: value,
          separator: separator,
          newLine: newLine,
          escape: escape,
        );
      }).join(separator));
      buffer.write(newLine);
    }
    // Return
    return buffer.toString();
  }

  /// Check given value to valid csv field
  String _toValidCsvField({
    required Object value,
    required String separator,
    required String newLine,
    required String escape,
  }) {
    String original = value is String ? value : value.toString();
    if (original.toString().contains(RegExp('$separator|$newLine|$escape'))) {
      original = original.replaceAll(RegExp(separator), '$escape$separator');
      original = original.replaceAll(RegExp(newLine), '$escape$newLine');
      original = original.replaceAll(RegExp(escape), '$escape$escape');
      return '"$original"';
    }
    return original;
  }

}
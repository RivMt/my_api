import 'package:my_api/core/model/model.dart';

abstract class SearchResult extends Model {

  /// Create model from [map]
  SearchResult([super.map]);

  /// Convert to subclass from [map].
  ///
  /// Check types from [ModelKeys.keyTable] in [map].
  dynamic get table;

}
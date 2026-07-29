/// Indicates that a model field is invalid.
class InvalidModelException implements Exception {
  /// Invalid model key.
  final String key;

  /// Creates an exception for [key].
  InvalidModelException(this.key);

  @override
  String toString() => "$key is not valid";

}

/// Indicates that an API request failed.
class RequestFailedException implements Exception {
  /// Failure description.
  final String message;

  /// Creates a request failure with an optional [message].
  RequestFailedException([this.message = "Request failed"]);
}

/// Indicates that an operation returned unexpected duplicate data.
class MultipleDataException implements Exception {
  /// Duplicate data returned by the operation.
  final Map data;

  /// Creates an exception for [data].
  MultipleDataException(this.data);
}

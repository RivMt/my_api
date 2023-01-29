/// Exception for Model is not valid
class InvalidModelException implements Exception {
  final String key;

  InvalidModelException(this.key);

}

/// Exception for api request failed
class RequestFailedException implements Exception {
  final String message;

  RequestFailedException([this.message = "Request failed"]);
}

/// Exception for unintended multiple data action
class MultipleDataException implements Exception {
  final Map data;

  MultipleDataException(this.data);
}
/// Exception for Model is not valid
class InvalidModelException implements Exception {
  final String key;

  InvalidModelException(this.key);

}

/// Exception for requested URI has been changed (Code 301)
class RequestedUriChangedException implements Exception {
  final String url;

  RequestedUriChangedException(this.url);
}

/// Exception for invalid request (Code 400)
class RequestInvalidException implements Exception {
  final String url;

  RequestInvalidException(this.url);
}

/// Exception for Non-auth user request (Code 401)
class RequestNonAuthenticatedException implements Exception {
  final String url;

  RequestNonAuthenticatedException(this.url);
}

/// Exception for request has been denied for permission reason (Code 405)
class RequestPermissionDeniedException implements Exception {
  final String url;

  RequestPermissionDeniedException(this.url);
}

/// Exception for any other error (Code 500)
class RequestErrorException implements Exception {
  final String url;

  RequestErrorException(this.url);
}

/// Exception for api action failed
class ActionFailedException implements Exception {
  final Map data;

  ActionFailedException(this.data);
}

/// Exception for unintended multiple data action
class MultipleDataException implements Exception {
  final Map data;

  MultipleDataException(this.data);
}
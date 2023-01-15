/// Exception for Model is not valid
class InvalidModelException implements Exception {
  final String key;

  InvalidModelException(this.key);

}

/// Exception for requested URI has been changed (Code 301)
class UriChangedException implements Exception {
  final String url;

  UriChangedException(this.url);
}

/// Exception for invalid request (Code 400)
class RequestInvalidException implements Exception {
  final String url;

  RequestInvalidException(this.url);
}

/// Exception for Non-auth user request (Code 401)
class NotAuthenticatedException implements Exception {
  final String url;

  NotAuthenticatedException(this.url);
}

/// Exception for request has been denied for permission reason (Code 405)
class PermissionDeniedException implements Exception {
  final String url;

  PermissionDeniedException(this.url);
}

/// Exception for any other error (Code 500)
class HttpErrorException implements Exception {
  final String url;

  HttpErrorException(this.url);
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
import 'package:my_api/src/core/api/api_response_result.dart';

/// A response of type [T].
class ApiResponse<T> {
  /// Result.
  final ApiResponseResult result;

  /// Data.
  final T data;

  /// Initialize.
  ApiResponse({
    required this.result,
    required this.data,
  });

  /// Failed response.
  ApiResponse.failed(
    this.data, [
    this.result = ApiResponseResult.failed,
  ]);

  /// Casts [data] as [E] and returns a new [ApiResponse].
  ApiResponse<E> cast<E>(E data) => ApiResponse<E>(
        result: result,
        data: data,
      );

  /// Casts [data] as a list of [E] and returns a new [ApiResponse].
  ApiResponse<List<E>> casts<E>(List<E> data) => ApiResponse<List<E>>(
        result: result,
        data: data,
      );
}

class ApiResponse<T> {
  final int code;
  final String? message;
  final T? result;

  ApiResponse({
    required this.code,
    this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String?,
      result: fromJsonT != null && json['result'] != null
          ? fromJsonT(json['result'])
          : null,
    );
  }
}
class ApiResponse<T> {
  final bool success;
  final String? error;
  final T? data;

  ApiResponse({
    required this.success,
    this.error,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      error: json['error'],
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      error: message,
    );
  }
}

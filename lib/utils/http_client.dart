import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.error(String message) {
    return ApiResponse(
      success: false,
      error: message,
    );
  }
}

class HttpClient {
  final Dio _dio;
  String? _token;

  HttpClient() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<ApiResponse<T>> get<T>(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(String path, {dynamic body}) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: body,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete<dynamic>(path);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }

  Future<FormData> createMultipartFormData(Map<String, String> files) async {
    final formData = FormData();

    for (final entry in files.entries) {
      formData.files.add(
        MapEntry(
          entry.key,
          await MultipartFile.fromFile(entry.value),
        ),
      );
    }

    return formData;
  }

  ApiResponse<T> _handleResponse<T>(Response<dynamic> response) {
    if (response.statusCode == 200) {
      return ApiResponse<T>(
        success: true,
        data: response.data as T,
      );
    }

    String errorMessage = '請求失敗';
    if (response.data is Map) {
      errorMessage =
          (response.data as Map)['message']?.toString() ?? errorMessage;
    }

    return ApiResponse<T>.error(errorMessage);
  }
}

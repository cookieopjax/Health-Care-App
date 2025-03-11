import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});
}

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  String? _token;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal();

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, {dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(String endpoint, {dynamic body}) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _headers,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(success: true, data: responseData as T);
    } else {
      final errorMessage =
          responseData is Map ? responseData['error'] : responseData.toString();
      return ApiResponse(
        success: false,
        error: errorMessage,
      );
    }
  }
}

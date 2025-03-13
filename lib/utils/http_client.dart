import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
  static final HttpClient _instance = HttpClient._internal();
  final Dio _dio;
  String? _token;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal() : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // 添加攔截器處理 401 錯誤
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (e.response?.statusCode == 401) {
            // 清除 token
            clearToken();
          }
          handler.next(e);
        },
      ),
    );
  }

  void setToken(String token) {
    print('設置 Token: $token'); // Debug
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('目前 Headers: ${_dio.options.headers}'); // Debug
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
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    print('發送請求到: $path'); // Debug
    print('請求 Headers: ${_dio.options.headers}'); // Debug
    print('請求 Body 類型: ${body.runtimeType}'); // Debug

    try {
      final requestHeaders = Map<String, String>.from(_dio.options.headers);

      // 如果是 FormData，保留 Authorization header 但更新 Content-Type
      if (body is FormData) {
        requestHeaders.remove('Content-Type'); // 讓 Dio 自動設置正確的 boundary
        print('FormData Headers: $requestHeaders'); // Debug
      }

      final response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(
          headers: requestHeaders,
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
        queryParameters: queryParameters,
      );

      print('回應狀態碼: ${response.statusCode}'); // Debug
      print('回應內容: ${response.data}'); // Debug

      return _handleResponse<T>(response);
    } catch (e) {
      print('請求錯誤: $e'); // Debug
      if (e is DioException) {
        print('錯誤回應: ${e.response?.data}'); // Debug
      }
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
      final file = File(entry.value);
      final filename = file.path.split('/').last;

      print('準備上傳檔案: ${file.path}'); // Debug
      print('檔案名稱: $filename'); // Debug
      print('檔案大小: ${await file.length()} bytes'); // Debug

      // 檢查檔案是否存在
      if (!await file.exists()) {
        throw Exception('檔案不存在: ${file.path}');
      }

      formData.files.add(
        MapEntry(
          entry.key,
          await MultipartFile.fromFile(
            file.path,
            filename: filename,
            contentType: MediaType.parse('image/jpeg'), // 指定 content type
          ),
        ),
      );
    }

    // 印出整個 FormData 的內容
    print('FormData fields: ${formData.fields}'); // Debug
    print('FormData files: ${formData.files}'); // Debug

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
    log('response.data: ${response.data}');
    if (response.data is Map) {
      errorMessage = (response.data as Map)['msg']?.toString() ?? errorMessage;
    }

    return ApiResponse<T>.error(errorMessage);
  }
}

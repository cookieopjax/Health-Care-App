import '../models/auth_model.dart';
import '../utils/http_client.dart';
import '../config/api_config.dart';

class AuthService {
  final _httpClient = HttpClient();

  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);
      _httpClient.setToken(authResponse.token);
      return ApiResponse(success: true, data: authResponse);
    }

    return ApiResponse(success: false, error: response.error);
  }

  Future<ApiResponse<AuthResponse>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      ApiConfig.register,
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data!);
      _httpClient.setToken(authResponse.token);
      return ApiResponse(success: true, data: authResponse);
    }

    return ApiResponse(success: false, error: response.error);
  }

  void logout() {
    _httpClient.clearToken();
  }

  Future<ApiResponse<User>> getUserProfile() async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiConfig.profile,
    );
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!);
      return ApiResponse(success: true, data: user);
    }
    return ApiResponse(success: false, error: response.error);
  }
}

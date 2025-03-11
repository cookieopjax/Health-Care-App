class ApiConfig {
  static const String devBaseUrl = 'https://health-care.zeabur.app'; // 開發環境
  static const String prodBaseUrl = 'https://health-care.zeabur.app'; // 生產環境

  // Token 相關
  static String? _authToken;

  // 設定 Token
  static void setToken(String token) {
    _authToken = token;
  }

  // 取得 Token
  static String? get token => _authToken;

  // 清除 Token
  static void clearToken() {
    _authToken = null;
  }

  // 產生帶有認證的 Headers
  static Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // 根據環境變數或建置設定來決定使用哪個 URL
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }

  // API 端點
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';

  // 食物分析相關端點
  static const String foodAnalyze = '/api/food/analyze';

  // 可以添加更多 API 端點常數
}

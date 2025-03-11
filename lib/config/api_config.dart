class ApiConfig {
  static const String devBaseUrl = 'https://health-care.zeabur.app'; // 開發環境
  static const String prodBaseUrl = 'https://health-care.zeabur.app'; // 生產環境

  // 根據環境變數或建置設定來決定使用哪個 URL
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }

  // API 端點
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';

  // 可以添加更多 API 端點常數
}

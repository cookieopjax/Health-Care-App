import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/api_response.dart' as api;
import '../models/food_analysis.dart';
import '../config/api_config.dart';
import '../utils/http_client.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final _httpClient = HttpClient();

  // 拍攝食物照片
  Future<api.ApiResponse<File>> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // 設定圖片品質
        maxWidth: 1920, // 設定最大寬度
        maxHeight: 1080, // 設定最大高度
      );

      if (image != null) {
        return api.ApiResponse(
          success: true,
          data: File(image.path),
        );
      }
      return api.ApiResponse.error('未選擇照片');
    } catch (e) {
      return api.ApiResponse.error('拍攝照片時發生錯誤: $e');
    }
  }

  // 從相簿選擇照片
  Future<api.ApiResponse<File>> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return api.ApiResponse(
          success: true,
          data: File(image.path),
        );
      }
      return api.ApiResponse.error('未選擇照片');
    } catch (e) {
      return api.ApiResponse.error('選擇照片時發生錯誤: $e');
    }
  }

  // 分析食物照片
  Future<api.ApiResponse<FoodAnalysis>> analyzeFoodImage(File imageFile) async {
    try {
      print('開始準備上傳檔案'); // Debug
      print('檔案路徑: ${imageFile.path}'); // Debug
      print('檔案是否存在: ${await imageFile.exists()}'); // Debug

      // 確保檔案存在
      if (!await imageFile.exists()) {
        return api.ApiResponse.error('找不到圖片檔案');
      }

      // 檢查檔案大小
      final fileSize = await imageFile.length();
      print('檔案大小: $fileSize bytes'); // Debug

      if (fileSize == 0) {
        return api.ApiResponse.error('圖片檔案是空的');
      }

      final formData = await _httpClient.createMultipartFormData({
        'food_image': imageFile.path,
      });

      print('開始分析照片'); // Debug
      final response = await _httpClient.post<Map<String, dynamic>>(
        ApiConfig.foodAnalyze,
        body: formData,
      );

      print('收到回應: ${response.data}'); // Debug

      if (response.success && response.data != null) {
        try {
          final analysis = FoodAnalysis.fromJson(response.data!);
          print('解析成功: $analysis'); // Debug
          return api.ApiResponse(success: true, data: analysis);
        } catch (e) {
          print('解析回應失敗: $e'); // Debug
          return api.ApiResponse.error('解析回應資料失敗: $e');
        }
      }

      return api.ApiResponse(success: false, error: response.error);
    } catch (e) {
      print('分析照片錯誤: $e'); // Debug
      return api.ApiResponse.error('分析照片時發生錯誤: $e');
    }
  }
}

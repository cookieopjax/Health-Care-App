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
      final formData = await _httpClient.createMultipartFormData({
        'food_image': imageFile.path,
      });

      final response = await _httpClient.post<Map<String, dynamic>>(
        ApiConfig.foodAnalyze,
        body: formData,
      );

      if (response.success && response.data != null) {
        final analysis = FoodAnalysis.fromJson(response.data!);
        return api.ApiResponse(success: true, data: analysis);
      }

      return api.ApiResponse(success: false, error: response.error);
    } catch (e) {
      return api.ApiResponse.error('分析照片時發生錯誤: $e');
    }
  }
}

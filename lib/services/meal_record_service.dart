import '../models/food_analysis.dart';
import '../config/api_config.dart';
import '../utils/http_client.dart';

class MealRecordService {
  final _httpClient = HttpClient();

  Future<ApiResponse<Map<String, dynamic>>> createMealRecord({
    required FoodAnalysis analysis,
    required String imageUrl,
    required String mealType,
    String? notes,
    String? eatenAt,
  }) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      ApiConfig.mealRecordCreate,
      body: {
        'analysis': {
          'name': analysis.name,
          'nutrition': analysis.nutrition,
        },
        'image_url': imageUrl,
        'meal_type': mealType,
        if (notes != null) 'notes': notes,
        if (eatenAt != null) 'eaten_at': eatenAt,
      },
    );

    return response;
  }
}

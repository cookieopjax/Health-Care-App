class NutritionInfo {
  final int id;
  final String name;
  final String unit;
  final double value;

  NutritionInfo({
    required this.id,
    required this.name,
    required this.unit,
    required this.value,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class FoodAnalysis {
  final String name;
  final List<NutritionInfo> nutrition;
  final String imageUrl;

  FoodAnalysis({
    required this.name,
    required this.nutrition,
    required this.imageUrl,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
      name: json['analysis']['name'] as String,
      nutrition: (json['analysis']['nutrition'] as List)
          .map((item) => NutritionInfo.fromJson(item))
          .toList(),
      imageUrl: json['image_url'] as String,
    );
  }
}

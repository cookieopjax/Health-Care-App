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
    print('解析 FoodAnalysis JSON: $json'); // Debug

    final analysisData = json['analysis'] as Map<String, dynamic>;

    return FoodAnalysis(
      name: analysisData['name'] as String,
      nutrition: (analysisData['nutrition'] as List)
          .map((item) => NutritionInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image_url'] as String,
    );
  }

  @override
  String toString() {
    return 'FoodAnalysis(name: $name, nutrition: $nutrition, imageUrl: $imageUrl)';
  }
}

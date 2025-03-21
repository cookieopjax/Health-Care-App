import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'dart:io';
import '../services/image_service.dart';
import '../services/meal_record_service.dart';
import '../models/food_analysis.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class DietControlPage extends StatefulWidget {
  const DietControlPage({super.key});

  @override
  State<DietControlPage> createState() => _DietControlPageState();
}

class _DietControlPageState extends State<DietControlPage> {
  final ImageService _imageService = ImageService();
  final MealRecordService _mealRecordService = MealRecordService();
  File? _selectedImage;
  bool _isAnalyzing = false;
  FoodAnalysis? _analysisResult;
  int _currentIndex = 0;

  Future<void> _captureImage() async {
    setState(() => _isAnalyzing = true);

    try {
      final imageResponse = await _imageService.captureImage();
      if (imageResponse.data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(imageResponse.error ?? '拍攝照片失敗')),
          );
        }
        return;
      }

      final analysisResponse =
          await _imageService.analyzeFoodImage(imageResponse.data!);
      if (!analysisResponse.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(analysisResponse.error ?? '分析失敗，請重試')),
          );
        }
        return;
      }

      setState(() => _analysisResult = analysisResponse.data);
      if (mounted && analysisResponse.data != null) {
        _showAnalysisResult(analysisResponse.data!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('發生錯誤，請重試')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isAnalyzing = true);

    try {
      final imageResponse = await _imageService.pickImageFromGallery();
      if (imageResponse.data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(imageResponse.error ?? '選擇照片失敗')),
          );
        }
        return;
      }

      final analysisResponse =
          await _imageService.analyzeFoodImage(imageResponse.data!);
      if (!analysisResponse.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(analysisResponse.error ?? '分析失敗，請重試')),
          );
        }
        return;
      }

      setState(() => _analysisResult = analysisResponse.data);
      if (mounted && analysisResponse.data != null) {
        _showAnalysisResult(analysisResponse.data!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('發生錯誤，請重試')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<String?> _showMealTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇餐食類型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('早餐'),
              onTap: () => Navigator.pop(context, 'breakfast'),
            ),
            ListTile(
              title: const Text('午餐'),
              onTap: () => Navigator.pop(context, 'lunch'),
            ),
            ListTile(
              title: const Text('晚餐'),
              onTap: () => Navigator.pop(context, 'dinner'),
            ),
            ListTile(
              title: const Text('點心'),
              onTap: () => Navigator.pop(context, 'snack'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMealRecord(FoodAnalysis analysis, String mealType) async {
    try {
      print('完整物件：$analysis');
      print('營養成分列表：');
      analysis.nutrition.forEach((key, value) {
        print('$key: $value');
      });
      // TODO: 這裡需要先上傳圖片到伺服器，取得 image_url
      // 暫時使用一個假造的 URL
      const imageUrl = 'https://example.com/food-image.jpg';

      final response = await _mealRecordService.createMealRecord(
        analysis: analysis,
        imageUrl: imageUrl,
        mealType: mealType,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('儲存成功！')),
          );
          Navigator.pop(context); // 關閉分析結果對話框
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? '儲存失敗')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發生錯誤：$e')),
        );
      }
    }
  }

  void _showAnalysisResult(FoodAnalysis analysis) {
    print('分析結果：$analysis');
    String selectedMealType = 'lunch'; // 預設值

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  analysis.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 餐食類型選擇
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMealTypeButton('早餐', 'breakfast', selectedMealType, (value) {
                        setState(() => selectedMealType = value);
                      }),
                      _buildMealTypeButton('午餐', 'lunch', selectedMealType, (value) {
                        setState(() => selectedMealType = value);
                      }),
                      _buildMealTypeButton('晚餐', 'dinner', selectedMealType, (value) {
                        setState(() => selectedMealType = value);
                      }),
                      _buildMealTypeButton('點心', 'snack', selectedMealType, (value) {
                        setState(() => selectedMealType = value);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildNutritionItem('熱量', analysis.nutrition['calories'] ?? 0, 'kcal'),
                      _buildNutritionItem('蛋白質', analysis.nutrition['protein'] ?? 0, 'g'),
                      _buildNutritionItem('碳水化合物', analysis.nutrition['carbs'] ?? 0, 'g'),
                      _buildNutritionItem('脂肪', analysis.nutrition['fat'] ?? 0, 'g'),
                      _buildNutritionItem('膳食纖維', analysis.nutrition['fiber'] ?? 0, 'g'),
                      _buildNutritionItem('糖分', analysis.nutrition['sugar'] ?? 0, 'g'),
                      _buildNutritionItem('鈉', analysis.nutrition['sodium'] ?? 0, 'mg'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveMealRecord(analysis, selectedMealType),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                    child: const Text(
                      '儲存記錄',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, double value, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$value $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    _analysisResult?.nutrition[label.toLowerCase()] = (value - 1).clamp(0, double.infinity);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    _analysisResult?.nutrition[label.toLowerCase()] = value + 1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeButton(String label, String value, String selected, Function(String) onSelect) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? '飲食控制' : '飲食記錄',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _currentIndex == 0 ? _buildMainPage() : _buildFoodRecordPage(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '飲食記錄',
          ),
        ],
      ),
    );
  }

  Widget _buildMainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailySummaryCard(),
        const SizedBox(height: 20),
        _buildAddFoodSection(),
      ],
    );
  }

  Widget _buildFoodRecordPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '飲食記錄',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildFoodList()),
      ],
    );
  }

  Widget _buildDailySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日飲食良好！',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.show_chart),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日卡路里'),
                    LinearProgressIndicator(
                      value: 1250 / 2000,
                      backgroundColor: Colors.grey[200],
                    ),
                    const Text('1250 / 2000 kcal'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.restaurant, '記錄次數', '3 餐'),
              _buildInfoItem(Icons.pie_chart, '平均蛋白質', '23 g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddFoodSection() {
    return Stack(
      children: [
        InkWell(
          onTap: _isAnalyzing ? null : _captureImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('新增今日飲食'),
                const SizedBox(height: 16),
                const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                const Text('點擊直接拍攝食物照片'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library,
                        color: Color(0xFF4A90E2)),
                    label: const Text(
                      '從相簿選擇照片',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 46, 99),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isAnalyzing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在分析照片...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFoodList() {
    return ListView(
      children: [
        _buildFoodItem('午餐：雞肉沙拉', '10:44', '420 kcal', [
          '蛋白質 25g',
          '碳水 20g',
          '脂肪 15g',
        ]),
        _buildFoodItem('晚餐：鮭魚配蔬菜', '22:44', '480 kcal', [
          '蛋白質 30g',
          '碳水 15g',
          '脂肪 18g',
        ]),
      ],
    );
  }

  Widget _buildFoodItem(
    String title,
    String time,
    String calories,
    List<String> nutrients,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  calories,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  nutrients.join(' · '),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
        ],
      ),
    );
  }
}

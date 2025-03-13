import 'package:flutter/material.dart';
import 'auth_page.dart';
import 'dart:io';
import '../services/image_service.dart';
import '../models/food_analysis.dart';

class DietControlPage extends StatefulWidget {
  const DietControlPage({super.key});

  @override
  State<DietControlPage> createState() => _DietControlPageState();
}

class _DietControlPageState extends State<DietControlPage> {
  final ImageService _imageService = ImageService();
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

  void _showAnalysisResult(FoodAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(analysis.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...analysis.nutrition.map(
              (item) => ListTile(
                title: Text('${item.name}: ${item.value} ${item.unit}'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 這裡可以加入儲存記錄的功能
              Navigator.pop(context);
            },
            child: const Text('儲存記錄'),
          ),
        ],
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
    return InkWell(
      onTap: _captureImage,
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
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library, color: Color(0xFF4A90E2)),
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

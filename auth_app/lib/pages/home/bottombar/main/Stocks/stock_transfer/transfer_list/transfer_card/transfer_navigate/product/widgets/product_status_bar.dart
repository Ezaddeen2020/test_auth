import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';

class ProductStatsBar extends StatelessWidget {
  final ProductManagementController controller;

  const ProductStatsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // شريط البحث
          _buildSearchField(),
          const SizedBox(height: 12),
          // الإحصائيات مع مؤشر تحميل الوحدات
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      onChanged: controller.updateSearch,
      decoration: InputDecoration(
        hintText: 'بحث بكود الصنف أو الوصف...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: Obx(() => controller.hasActiveSearch
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: controller.clearSearch,
              )
            : const SizedBox.shrink()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Obx(() {
          final stats = controller.getProductStats();
          return Expanded(
            flex: 3,
            child: Row(
              children: [
                StatCard(
                  title: 'إجمالي الأصناف',
                  value: '${stats['totalItems']}',
                  icon: Icons.inventory,
                ),
                const SizedBox(width: 8),
                StatCard(
                  title: 'إجمالي الكمية',
                  value: '${stats['totalQuantity'].toStringAsFixed(0)}',
                  icon: Icons.numbers,
                ),
                const SizedBox(width: 8),
                StatCard(
                  title: 'أصناف مختلفة',
                  value: '${stats['uniqueItems']}',
                  icon: Icons.category,
                ),
              ],
            ),
          );
        }),
        // مؤشر تحميل الوحدات
        _buildUnitsLoadingIndicator(),
      ],
    );
  }

  Widget _buildUnitsLoadingIndicator() {
    return Obx(() => controller.isLoadingUnits.value
        ? Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'تحميل الوحدات...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

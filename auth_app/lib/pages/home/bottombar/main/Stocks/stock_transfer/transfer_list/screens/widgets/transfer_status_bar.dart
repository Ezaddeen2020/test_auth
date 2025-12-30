import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =============================================================================
// شريط الإحصائيات
// =============================================================================
class TransferStatsBar extends StatelessWidget {
  final TransferController controller;

  const TransferStatsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.getTransferStats();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF0D47A1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'الإجمالي',
                stats['total'].toString(),
                Icons.all_inbox,
                Colors.white,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'قيد التحضير',
                stats['pending'].toString(),
                Icons.pending_actions,
                Colors.orange[200]!,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'تم الإرسال',
                stats['sent'].toString(),
                Icons.send,
                Colors.blue[200]!,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'مكتمل',
                stats['posted'].toString(),
                Icons.check_circle,
                Colors.green[200]!,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// بناء عنصر الإحصائية الواحد
  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// =============================================================================
// شريط البحث
// =============================================================================
class TransferSearchBar extends StatelessWidget {
  final TransferController controller;

  const TransferSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        decoration: InputDecoration(
          hintText: 'البحث في التحويلات...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.searchController.clear();
                  controller.updateSearch('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

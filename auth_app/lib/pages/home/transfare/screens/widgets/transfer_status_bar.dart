import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';

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
          color: Color.fromARGB(255, 16, 80, 177),
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

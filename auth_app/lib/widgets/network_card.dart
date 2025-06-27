import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NetworkCard extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final bool copyable;

  const NetworkCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.copyable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue[600],
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'غير متوفر',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (copyable && value != null)
            GestureDetector(
              onTap: () => _copyToClipboard(value!),
              child: Icon(
                Icons.copy,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ $title إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
}

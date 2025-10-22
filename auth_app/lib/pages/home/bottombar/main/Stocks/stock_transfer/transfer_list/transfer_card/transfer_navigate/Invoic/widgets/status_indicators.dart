import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:flutter/material.dart';

class StatusIndicators extends StatelessWidget {
  final TransferHeader header;

  const StatusIndicators({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatusIndicator('إرسال', header.isSended, Icons.send),
        _buildStatusIndicator('استلام', header.aproveRecive, Icons.download_done),
        _buildStatusIndicator('ترحيل', header.sapPost, Icons.cloud_upload),
      ],
    );
  }

  Widget _buildStatusIndicator(String title, bool isCompleted, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isCompleted ? Colors.green[700] : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.green[700] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

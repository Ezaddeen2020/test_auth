import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:flutter/material.dart';
import 'status_indicators.dart';

class InvoiceHeader extends StatelessWidget {
  final TransferHeader header;

  const InvoiceHeader({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndStatus(),
          const SizedBox(height: 20),
          StatusIndicators(header: header),
        ],
      ),
    );
  }

  Widget _buildTitleAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'فاتورة التحويل',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
            ),
            const SizedBox(height: 4),
            Text(
              'رقم التحويل: ${header.id}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        _buildOverallStatus(),
      ],
    );
  }

  Widget _buildOverallStatus() {
    final (statusText, statusColor, statusIcon) = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 6),
          Text(statusText,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusInfo() {
    if (header.sapPost) {
      return ('مكتمل', Colors.green, Icons.check_circle);
    } else if (header.aproveRecive) {
      return ('مستلم', Colors.blue, Icons.download_done);
    } else if (header.isSended) {
      return ('مُرسل', Colors.orange, Icons.send);
    } else {
      return ('قيد التحضير', Colors.grey, Icons.pending);
    }
  }
}

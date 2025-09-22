import 'package:flutter/material.dart';

class ProductInfoSection extends StatelessWidget {
  final dynamic line;

  const ProductInfoSection({
    super.key,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: InfoColumn(
              label: 'الكمية الأساسية',
              value: line.baseQty1?.toString() ?? '0',
              textColor: Colors.blue[700]!,
            ),
          ),
          Container(
            width: 2,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: InfoColumn(
              label: 'UomEntry',
              value: line.uomEntry?.toString() ?? '0',
              textColor: Colors.blue[700]!,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const InfoColumn({
    super.key,
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/card/product_card_state.dart';
import 'package:flutter/material.dart';
import 'product_options_menu.dart';

class ProductCardHeader extends StatelessWidget {
  final int rowNumber;
  final dynamic line;
  final ProductCardState cardState;
  final ProductManagementController controller;

  const ProductCardHeader({
    super.key,
    required this.rowNumber,
    required this.line,
    required this.cardState,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$rowNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        if (cardState.statusText.isNotEmpty) ...[
          const SizedBox(width: 8),
          ProductStatusBadge(
            text: cardState.statusText,
            isDeleted: cardState.isDeleted,
            isNew: cardState.isNew,
          ),
        ],
        const SizedBox(width: 12),
        Expanded(
          child: ProductInfoColumn(
            line: line,
            isDeleted: cardState.isDeleted,
          ),
        ),
        ProductOptionsMenu(
          line: line,
          controller: controller,
        ),
      ],
    );
  }
}

class ProductStatusBadge extends StatelessWidget {
  final String text;
  final bool isDeleted;
  final bool isNew;

  const ProductStatusBadge({
    super.key,
    required this.text,
    required this.isDeleted,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = isDeleted ? Colors.red : (isNew ? Colors.green : Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProductInfoColumn extends StatelessWidget {
  final dynamic line;
  final bool isDeleted;

  const ProductInfoColumn({
    super.key,
    required this.line,
    required this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line.itemCode ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDeleted ? Colors.red[700] : Colors.black87,
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          line.description ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isDeleted ? Colors.red[600] : Colors.grey[600],
            decoration: isDeleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

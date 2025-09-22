import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';

class UnitSelectionDialogWidget {
  /// Show unit selection dialog for general item code selection
  static Future<void> showUnitSelectionDialog({
    required String itemCode,
    required List<ItemUnit> units,
    required Function(ItemUnit) onUnitSelected,
  }) async {
    if (units.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد وحدات متوفرة لهذا الصنف',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    List<ItemUnit> sortedUnits = List.from(units);
    sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _buildUnitSelectionDialog(
          itemCode: itemCode,
          units: sortedUnits,
          onUnitSelected: onUnitSelected,
        ),
      ),
    );
  }

  /// Show unit selection dialog for transfer lines
  static Future<void> showTransferLineUnitSelectionDialog({
    required TransferLine line,
    required List<ItemUnit> units,
    required Function(TransferLine, String, int, int) onUnitUpdate,
  }) async {
    if (units.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد وحدات متوفرة لهذا الصنف في النظام',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    List<ItemUnit> sortedUnits = List.from(units);
    sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _buildTransferLineUnitSelectionDialog(
          line: line,
          units: sortedUnits,
          onUnitUpdate: onUnitUpdate,
        ),
      ),
    );
  }

  /// Show unit selection dialog for new products and return selected unit
  static Future<String?> showNewProductUnitSelectionDialog({
    required String itemCode,
    required List<ItemUnit> units,
  }) async {
    if (units.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد وحدات متوفرة لهذا الصنف في النظام',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    }

    List<ItemUnit> sortedUnits = List.from(units);
    sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

    String? selectedUnit;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _buildNewProductUnitSelectionDialog(
          itemCode: itemCode,
          units: sortedUnits,
          onUnitSelected: (unit) {
            selectedUnit = unit.uomName;
            Get.back();
          },
        ),
      ),
    );

    return selectedUnit;
  }

  /// Build general unit selection dialog
  static Widget _buildUnitSelectionDialog({
    required String itemCode,
    required List<ItemUnit> units,
    required Function(ItemUnit) onUnitSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dialogWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth - 32;
        double maxHeight = constraints.maxHeight * 0.8;

        return Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(
                title: 'اختيار الوحدة',
                itemCode: itemCode,
              ),
              Expanded(
                child: _buildUnitsList(
                  units: units,
                  onTap: (unit) {
                    Get.back();
                    onUnitSelected(unit);
                  },
                ),
              ),
              _buildDialogFooter(units.length),
            ],
          ),
        );
      },
    );
  }

  /// Build transfer line unit selection dialog
  static Widget _buildTransferLineUnitSelectionDialog({
    required TransferLine line,
    required List<ItemUnit> units,
    required Function(TransferLine, String, int, int) onUnitUpdate,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dialogWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth - 32;
        double maxHeight = constraints.maxHeight * 0.8;

        return Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(
                title: 'اختيار الوحدة',
                itemCode: line.itemCode ?? '',
              ),
              Expanded(
                child: _buildTransferLineUnitsList(
                  line: line,
                  units: units,
                  onUnitUpdate: onUnitUpdate,
                ),
              ),
              _buildDialogFooter(units.length),
            ],
          ),
        );
      },
    );
  }

  /// Build new product unit selection dialog
  static Widget _buildNewProductUnitSelectionDialog({
    required String itemCode,
    required List<ItemUnit> units,
    required Function(ItemUnit) onUnitSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dialogWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth - 32;
        double maxHeight = constraints.maxHeight * 0.8;

        return Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(
                title: 'اختيار الوحدة',
                itemCode: itemCode,
              ),
              Expanded(
                child: _buildUnitsList(
                  units: units,
                  onTap: onUnitSelected,
                ),
              ),
              _buildDialogFooter(units.length),
            ],
          ),
        );
      },
    );
  }

  /// Build dialog header
  static Widget _buildDialogHeader({
    required String title,
    required String itemCode,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[700]!],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.straighten,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  itemCode,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  /// Build units list for general use
  static Widget _buildUnitsList({
    required List<ItemUnit> units,
    required Function(ItemUnit) onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: units.length,
        itemBuilder: (context, index) {
          ItemUnit unit = units[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => onTap(unit),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildUnitIndexBadge(index),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUnitInfo(unit),
                    ),
                    _buildSelectButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build units list for transfer lines with selection state
  static Widget _buildTransferLineUnitsList({
    required TransferLine line,
    required List<ItemUnit> units,
    required Function(TransferLine, String, int, int) onUnitUpdate,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: units.length,
        itemBuilder: (context, index) {
          ItemUnit unit = units[index];
          bool isSelected = unit.uomName == line.uomCode;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Get.back();
                onUnitUpdate(line, unit.uomName, unit.baseQty, unit.uomEntry);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildUnitIndexBadge(index, isSelected: isSelected),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUnitInfo(unit, isSelected: isSelected),
                    ),
                    _buildStatusButton(isSelected),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build unit index badge
  static Widget _buildUnitIndexBadge(int index, {bool isSelected = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build unit information section
  static Widget _buildUnitInfo(ItemUnit unit, {bool isSelected = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit.uomName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue[700] : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              'Entry: ${unit.uomEntry}',
              Icons.numbers,
              Colors.grey[600]!,
            ),
            _buildInfoChip(
              'الكمية: ${unit.baseQty}',
              Icons.inventory,
              Colors.green[600]!,
            ),
          ],
        ),
      ],
    );
  }

  /// Build info chip
  static Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build select button
  static Widget _buildSelectButton() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radio_button_unchecked,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'اختيار',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build status button
  static Widget _buildStatusButton(bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[600] : Colors.green[500],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isSelected ? 'محدد' : 'اختيار',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build dialog footer
  static Widget _buildDialogFooter(int unitsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'انقر على الوحدة لاختيارها',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unitsCount وحدة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

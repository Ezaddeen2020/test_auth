import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/guide_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductQuantitySection extends StatelessWidget {
  final dynamic line;
  final ProductManagementController controller;
  final bool isDisabled;

  const ProductQuantitySection({
    super.key,
    required this.line,
    required this.controller,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الكمية',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              EditableQuantityField(
                line: line,
                controller: controller,
                isDisabled: isDisabled,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الوحدة',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              UnitSelectionField(
                line: line,
                controller: controller,
                isDisabled: isDisabled,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditableQuantityField extends StatelessWidget {
  final dynamic line;
  final ProductManagementController controller;
  final bool isDisabled;

  const EditableQuantityField({
    super.key,
    required this.line,
    required this.controller,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextFormField(
        initialValue: line.quantity?.toStringAsFixed(0) ?? '0',
        enabled: !isDisabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDisabled ? Colors.grey : Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDisabled ? Colors.grey[200] : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (value) {
          if (!isDisabled && value.isNotEmpty) {
            double? newQuantity = double.tryParse(value);
            if (newQuantity != null && newQuantity >= 0) {
              controller.updateProductQuantity(line, newQuantity);
            }
          }
        },
        onFieldSubmitted: (value) {
          if (!isDisabled) {
            if (value.isNotEmpty) {
              double? newQuantity = double.tryParse(value);
              if (newQuantity != null && newQuantity >= 0) {
                controller.updateProductQuantity(line, newQuantity);
              } else {
                controller.update();
              }
            } else {
              controller.updateProductQuantity(line, 0);
            }
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          double? quantity = double.tryParse(value);
          if (quantity == null || quantity < 0) {
            return 'يرجى إدخال رقم صحيح';
          }
          return null;
        },
      ),
    );
  }
}

class UnitSelectionField extends StatelessWidget {
  final dynamic line;
  final ProductManagementController controller;
  final bool isDisabled;

  const UnitSelectionField({
    super.key,
    required this.line,
    required this.controller,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: isDisabled ? null : () => _handleUnitSelection(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : Colors.grey[50],
            border: Border.all(
              color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(() {
                  bool isLoadingCurrentItem = controller.isLoadingUnits.value;

                  if (isLoadingCurrentItem) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromARGB(255, 0, 13, 23),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    );
                  }

                  return Text(
                    line.uomCode?.isNotEmpty == true ? line.uomCode! : 'اختر الوحدة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDisabled ? Colors.grey : Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUnitSelection() async {
    if (line.itemCode == null || line.itemCode!.isEmpty) {
      Get.snackbar(
        'خطأ',
        'كود الصنف غير متوفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      if (controller is ProductManagementControllerWithUI) {
        await (controller as ProductManagementControllerWithUI).selectUnitForTransferLine(line);
      } else {
        await _showBasicUnitSelectionForLine(line);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في عرض وحدات الصنف: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showBasicUnitSelectionForLine(dynamic line) async {
    try {
      String itemCodeToUse = line.itemCode!;
      List units = await controller.getItemUnits(itemCodeToUse);

      if (units.isEmpty && !itemCodeToUse.toUpperCase().contains('INV')) {
        itemCodeToUse = 'INV${line.itemCode}';
        units = await controller.getItemUnits(itemCodeToUse);
      }

      if (units.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد وحدات متوفرة لهذا الصنف',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      await Get.dialog(
        AlertDialog(
          title: const Text('اختيار الوحدة'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                bool isSelected = unit.uomName == line.uomCode;

                return Card(
                  color: isSelected ? Colors.blue[50] : null,
                  child: ListTile(
                    title: Text(
                      unit.uomName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue[700] : null,
                      ),
                    ),
                    subtitle: Text('الكمية: ${unit.baseQty} | Entry: ${unit.uomEntry}'),
                    leading: isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue[600])
                        : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    onTap: () {
                      Get.back();
                      controller.updateProductUnit(
                        line,
                        unit.uomName,
                        unit.baseQty,
                        unit.uomEntry,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في جلب الوحدات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

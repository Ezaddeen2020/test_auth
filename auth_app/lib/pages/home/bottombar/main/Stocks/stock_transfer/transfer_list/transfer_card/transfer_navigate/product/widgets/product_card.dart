import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controller/product_controller.dart';

class ProductCardWidget extends StatelessWidget {
  final dynamic line;
  final int rowNumber;
  final ProductManagementController controller;

  const ProductCardWidget({
    super.key,
    required this.line,
    required this.rowNumber,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد حالة السطر
    final cardState = _getCardState();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardState.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: cardState.borderColor, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            ProductCardHeader(
              rowNumber: rowNumber,
              line: line,
              cardState: cardState,
              controller: controller,
            ),

            const SizedBox(height: 16),

            // خط فاصل
            _buildDivider(),

            const SizedBox(height: 16),

            // معلومات الكمية والوحدة
            ProductQuantitySection(
              line: line,
              controller: controller,
              isDisabled: cardState.isDeleted,
            ),

            const SizedBox(height: 16),

            // معلومات إضافية
            ProductInfoSection(line: line),
          ],
        ),
      ),
    );
  }

  ProductCardState _getCardState() {
    bool isNewLine = line.lineNum != null && line.lineNum! < 0;
    bool isModifiedLine = controller.modifiedLines.containsKey(line.lineNum);
    bool isDeletedLine = controller.deletedLines.contains(line.lineNum);

    Color borderColor = Colors.grey[200]!;
    Color backgroundColor = Colors.white;
    String statusText = '';

    if (isDeletedLine) {
      borderColor = Colors.red[300]!;
      backgroundColor = Colors.red[50]!;
      statusText = 'محذوف';
    } else if (isNewLine) {
      borderColor = Colors.green[300]!;
      backgroundColor = Colors.green[50]!;
      statusText = 'جديد';
    } else if (isModifiedLine) {
      borderColor = Colors.orange[300]!;
      backgroundColor = Colors.orange[50]!;
      statusText = 'معدل';
    }

    return ProductCardState(
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      statusText: statusText,
      isDeleted: isDeletedLine,
      isNew: isNewLine,
      isModified: isModifiedLine,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// كلاس مساعد لحالة البطاقة
class ProductCardState {
  final Color borderColor;
  final Color backgroundColor;
  final String statusText;
  final bool isDeleted;
  final bool isNew;
  final bool isModified;

  const ProductCardState({
    required this.borderColor,
    required this.backgroundColor,
    required this.statusText,
    required this.isDeleted,
    required this.isNew,
    required this.isModified,
  });
}

// رأس البطاقة
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
        // رقم الصف
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

        // شارة الحالة
        if (cardState.statusText.isNotEmpty) ...[
          const SizedBox(width: 8),
          ProductStatusBadge(
            text: cardState.statusText,
            isDeleted: cardState.isDeleted,
            isNew: cardState.isNew,
          ),
        ],

        const SizedBox(width: 12),

        // معلومات المنتج
        Expanded(
          child: ProductInfoColumn(
            line: line,
            isDeleted: cardState.isDeleted,
          ),
        ),

        // قائمة الخيارات
        ProductOptionsMenu(
          line: line,
          controller: controller,
        ),
      ],
    );
  }
}

// شارة الحالة
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

// عمود معلومات المنتج
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

// قائمة الخيارات
class ProductOptionsMenu extends StatelessWidget {
  final dynamic line;
  final ProductManagementController controller;

  const ProductOptionsMenu({
    super.key,
    required this.line,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'delete':
            ProductDialogs.showDeleteConfirmation(line, controller);
            break;
          case 'duplicate':
            controller.duplicateProduct(line);
            break;
          case 'edit':
            ProductDialogs.showEditDialog(line, controller);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('نسخ'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف'),
            ],
          ),
        ),
      ],
      child: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
      ),
    );
  }
}

// قسم الكمية والوحدة
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
        // حقل الكمية
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

        // حقل الوحدة
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

// حقل الكمية القابل للتعديل
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
    return Container(
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
        // عند تغيير النص - هنا يتم التقاط القيمة
        onChanged: (value) {
          if (!isDisabled && value.isNotEmpty) {
            double? newQuantity = double.tryParse(value);
            if (newQuantity != null && newQuantity >= 0) {
              controller.updateProductQuantity(line, newQuantity);
            }
          }
        },
        // عند الانتهاء من التعديل
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

// حقل اختيار الوحدة
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

  void _handleUnitSelection() {
    if (line.itemCode != null && line.itemCode!.isNotEmpty) {
      controller.showUnitSelectionDialog(line);
    } else {
      Get.snackbar(
        'خطأ',
        'كود الصنف غير متوفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// قسم المعلومات الإضافية
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

// عمود المعلومات
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

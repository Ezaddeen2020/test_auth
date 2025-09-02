import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';

class ProductDialogs {
  // حوار تأكيد الحذف
  static void showDeleteConfirmation(
    dynamic line,
    ProductManagementController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المنتج "${line.itemCode}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(line);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // حوار إضافة منتج جديد
  static void showAddProductDialog(ProductManagementController controller) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController itemCodeController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductTextField(
                  controller: itemCodeController,
                  label: 'كود الصنف',
                  hint: 'أدخل كود الصنف',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: descriptionController,
                  label: 'وصف الصنف',
                  hint: 'أدخل وصف الصنف',
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: quantityController,
                  label: 'الكمية',
                  hint: 'أدخل الكمية',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: _validateQuantity,
                ),
                const SizedBox(height: 16),
                ProductTextField(
                  controller: priceController,
                  label: 'السعر',
                  hint: 'أدخل السعر',
                  keyboardType: TextInputType.number,
                  validator: _validatePrice,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _handleAddProduct(
              formKey,
              itemCodeController,
              descriptionController,
              quantityController,
              priceController,
              controller,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // حوار تعديل منتج
  static void showEditDialog(
    dynamic line,
    ProductManagementController controller,
  ) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController quantityController =
        TextEditingController(text: line.quantity?.toString() ?? '0');
    final TextEditingController priceController =
        TextEditingController(text: line.price?.toString() ?? '0');

    Get.dialog(
      AlertDialog(
        title: Text('تعديل المنتج ${line.itemCode}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                line.description ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ProductTextField(
                controller: quantityController,
                label: 'الكمية',
                hint: 'أدخل الكمية',
                keyboardType: TextInputType.number,
                isRequired: true,
                validator: _validateQuantity,
              ),
              const SizedBox(height: 16),
              ProductTextField(
                controller: priceController,
                label: 'السعر',
                hint: 'أدخل السعر',
                keyboardType: TextInputType.number,
                validator: _validatePrice,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _handleEditProduct(
              formKey,
              quantityController,
              priceController,
              line,
              controller,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // التحقق من صحة الكمية
  static String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الكمية';
    }

    double? quantity = double.tryParse(value.trim());
    if (quantity == null || quantity < 0) {
      return 'يرجى إدخال كمية صحيحة';
    }

    return null;
  }

  // التحقق من صحة السعر
  static String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // السعر اختياري
    }

    double? price = double.tryParse(value.trim());
    if (price == null || price < 0) {
      return 'يرجى إدخال سعر صحيح';
    }

    return null;
  }

  // معالجة إضافة منتج جديد
  static void _handleAddProduct(
    GlobalKey<FormState> formKey,
    TextEditingController itemCodeController,
    TextEditingController descriptionController,
    TextEditingController quantityController,
    TextEditingController priceController,
    ProductManagementController controller,
  ) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    double quantity = double.parse(quantityController.text.trim());
    double price = double.tryParse(priceController.text.trim()) ?? 0.0;

    Get.back();

    // إضافة المنتج الجديد
    controller.addProduct({
      'itemCode': itemCodeController.text.trim(),
      'description': descriptionController.text.trim(),
      'quantity': quantity,
      'price': price,
      'uomCode': 'حبة',
      'baseQty1': 1,
      'uomEntry': 1,
    });
  }

  // معالجة تعديل منتج
  static void _handleEditProduct(
    GlobalKey<FormState> formKey,
    TextEditingController quantityController,
    TextEditingController priceController,
    dynamic line,
    ProductManagementController controller,
  ) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    double quantity = double.parse(quantityController.text.trim());
    double price = double.tryParse(priceController.text.trim()) ?? 0.0;

    Get.back();

    // تحديث الكمية والسعر
    controller.updateProductQuantity(line, quantity);
    if (price != line.price) {
      controller.updateProduct(line, {
        'quantity': quantity,
        'price': price,
      });
    }
  }
}

// ويدجت حقل النص المخصص
class ProductTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool isRequired;
  final String? Function(String?)? validator;

  const ProductTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator ?? (isRequired ? _defaultValidator : null),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}

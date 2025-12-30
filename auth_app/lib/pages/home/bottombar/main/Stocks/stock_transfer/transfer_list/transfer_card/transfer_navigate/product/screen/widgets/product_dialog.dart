import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/guide_controller.dart';
import 'package:auth_app/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';

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

  // حوار إضافة منتج جديد - مُحسن مع معاملات اختيارية
  static void showAddProductDialog(
    ProductManagementController controller, {
    String? prefilledItemCode,
    String? prefilledDescription,
    String? prefilledUnit,
    double? prefilledQuantity,
    double? prefilledPrice,
  }) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController itemCodeController =
        TextEditingController(text: prefilledItemCode ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: prefilledDescription ?? '');
    final TextEditingController quantityController =
        TextEditingController(text: prefilledQuantity?.toString() ?? '');
    final TextEditingController priceController =
        TextEditingController(text: prefilledPrice?.toString() ?? '');
    final TextEditingController unitController = TextEditingController(text: prefilledUnit ?? '');

    final StockController stockController = Get.put(StockController());

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
                  validator: Validation.validateQuantity,
                ),
                const SizedBox(height: 16),

                // حقل الوحدة مع زر الاختيار
                Row(
                  children: [
                    Expanded(
                      child: ProductTextField(
                        controller: unitController,
                        label: 'الوحدة',
                        hint: 'أدخل الوحدة',
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        String currentItemCode = itemCodeController.text.trim();
                        if (currentItemCode.isEmpty) {
                          Get.snackbar('خطأ', 'أدخل كود الصنف أولاً');
                          return;
                        }

                        // التحقق من نوع الكنترولر واستدعاء الدالة المناسبة
                        String? selectedUnit;

                        if (controller is ProductManagementControllerWithUI) {
                          selectedUnit =
                              await controller.showUnitSelectionForNewProduct(currentItemCode);
                        } else {
                          // للكنترولر الأساسي، نستخدم طريقة بديلة
                          selectedUnit = await _showBasicUnitSelection(controller, currentItemCode);
                        }

                        if (selectedUnit != null && selectedUnit.isNotEmpty) {
                          unitController.text = selectedUnit;
                          Get.snackbar(
                            'تم الاختيار',
                            'تم اختيار الوحدة: $selectedUnit',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      icon: const Icon(Icons.list_alt),
                      tooltip: 'اختيار وحدة',
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                ProductTextField(
                  controller: priceController,
                  label: 'السعر',
                  hint: 'أدخل السعر',
                  keyboardType: TextInputType.number,
                  validator: Validation.validatePrice,
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
              unitController,
              priceController,
              controller,
            ),
            child: const Text('إضافة'),
          ),
          ElevatedButton(
            onPressed: () => _handlePullProduct(
              itemCodeController,
              descriptionController,
              quantityController,
              unitController,
              priceController,
              stockController,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('سحب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // دالة بديلة لاختيار الوحدة للكنترولر الأساسي
  static Future<String?> _showBasicUnitSelection(
    ProductManagementController controller,
    String itemCode,
  ) async {
    try {
      var units = await controller.getItemUnits(itemCode);
      if (units.isEmpty) return null;

      String? selectedUnit;

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
                return ListTile(
                  title: Text(unit.uomName),
                  subtitle: Text('الكمية: ${unit.baseQty} | Entry: ${unit.uomEntry}'),
                  onTap: () {
                    selectedUnit = unit.uomName;
                    Get.back();
                  },
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

      return selectedUnit;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب الوحدات: $e');
      return null;
    }
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
                validator: Validation.validateQuantity,
              ),
              const SizedBox(height: 16),
              ProductTextField(
                controller: priceController,
                label: 'السعر',
                hint: 'أدخل السعر',
                keyboardType: TextInputType.number,
                validator: Validation.validatePrice,
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

  static Future<void> _handlePullProduct(
    TextEditingController itemCodeController,
    TextEditingController descriptionController,
    TextEditingController quantityController,
    TextEditingController unitController,
    TextEditingController priceController,
    StockController stockController,
  ) async {
    String itemCode = itemCodeController.text.trim();

    if (itemCode.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال كود الصنف أولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      stockController.itemCodeController.text = itemCode;
      await stockController.searchStock();

      if (stockController.stockItems.isNotEmpty) {
        var stockItem = stockController.stockItems.first;

        descriptionController.text = stockItem.itemName;

        if (stockItem.totalOnHand > 0) {
          quantityController.text = stockItem.totalOnHand.toString();
        }

        if (unitController.text.trim().isEmpty &&
            stockItem.uomCode != null &&
            stockItem.uomCode!.isNotEmpty) {
          unitController.text = stockItem.uomCode!;
        }

        if (stockItem.avgPrice > 0) {
          priceController.text = stockItem.avgPrice.toString();
        }

        Get.snackbar(
          'نجح',
          'تم سحب بيانات الصنف بنجاح\nالوحدة المحفوظة: "${unitController.text}"',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        print('=== بعد السحب ===');
        print('الوحدة المحفوظة: "${unitController.text}"');
        print('السعر المحفوظ: "${priceController.text}"');
      } else {
        Get.snackbar(
          'تنبيه',
          'لم يتم العثور على بيانات لهذا الصنف',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في سحب بيانات الصنف: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  static void _handleAddProduct(
    GlobalKey<FormState> formKey,
    TextEditingController itemCodeController,
    TextEditingController descriptionController,
    TextEditingController quantityController,
    TextEditingController unitController,
    TextEditingController priceController,
    ProductManagementController controller,
  ) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    double quantity = double.parse(quantityController.text.trim());
    double price = double.tryParse(priceController.text.trim()) ?? 0.0;
    String selectedUnit = unitController.text.trim();
    String itemCode = itemCodeController.text.trim();

    // التحقق من الوحدة
    if (selectedUnit.isNotEmpty && double.tryParse(selectedUnit) != null) {
      Get.snackbar(
        'خطأ',
        'تم اكتشاف رقم في حقل الوحدة: "$selectedUnit"\nيرجى اختيار وحدة صحيحة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (selectedUnit.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار وحدة الصنف أو إدخالها يدوياً',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // إغلاق الحوار أولاً
    Get.back();

    // إنشاء بيانات المنتج
    Map<String, dynamic> productData = {
      'itemCode': itemCode,
      'description': descriptionController.text.trim(),
      'quantity': quantity,
      'price': price,
      'uomCode': selectedUnit,
      'baseQty1': 1,
      'uomEntry': 1,
    };

    print('=== بيانات المنتج النهائية ===');
    print('productData: $productData');
    print('الوحدة في البيانات: "${productData['uomCode']}"');

    // إضافة المنتج
    controller.addProduct(productData);

    // رسالة نجاح
    Get.snackbar(
      'تمت الإضافة',
      'تم إضافة المنتج بنجاح',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

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

    controller.updateProductQuantity(line, quantity);
    if (price != line.price) {
      controller.updateProduct(line, {
        'quantity': quantity,
        'price': price,
      });
    }
  }
}

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
      validator: validator ?? (isRequired ? Validation.defaultValidator : null),
    );
  }
}

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controller/product_controller.dart';

// class ProductDialogs {
//   // حوار تأكيد الحذف
//   static void showDeleteConfirmation(
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل تريد حذف المنتج "${line.itemCode}"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteProduct(line);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

// // ===== الحل: تصحيح ترتيب المعاملات في showAddProductDialog =====

//   static void showAddProductDialog(ProductManagementController controller) {
//     final formKey = GlobalKey<FormState>();
//     final TextEditingController itemCodeController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     final TextEditingController quantityController = TextEditingController();
//     final TextEditingController priceController = TextEditingController();
//     final TextEditingController unitController = TextEditingController();

//     // إنشاء مثيل من StockController للبحث
//     final StockController stockController = Get.put(StockController());

//     Get.dialog(
//       AlertDialog(
//         title: const Text('إضافة منتج جديد'),
//         content: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ProductTextField(
//                   controller: itemCodeController,
//                   label: 'كود الصنف',
//                   hint: 'أدخل كود الصنف',
//                   isRequired: true,
//                 ),
//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: descriptionController,
//                   label: 'وصف الصنف',
//                   hint: 'أدخل وصف الصنف',
//                 ),
//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: quantityController,
//                   label: 'الكمية',
//                   hint: 'أدخل الكمية',
//                   keyboardType: TextInputType.number,
//                   isRequired: true,
//                   validator: _validateQuantity,
//                 ),
//                 const SizedBox(height: 16),

//                 // حقل الوحدة
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ProductTextField(
//                         controller: unitController,
//                         label: 'الوحدة',
//                         hint: 'أدخل الوحدة',
//                         keyboardType: TextInputType.text,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       onPressed: () async {
//                         if (itemCodeController.text.isEmpty) {
//                           Get.snackbar('خطأ', 'أدخل كود الصنف أولاً');
//                           return;
//                         }

//                         String fullItemCode = _getFullItemCodeFromStockController();

//                         if (fullItemCode.isEmpty) {
//                           Get.snackbar(
//                             'تنبيه',
//                             'اضغط على زر "سحب" أولاً للحصول على بيانات الصنف',
//                             backgroundColor: Colors.orange,
//                             colorText: Colors.white,
//                           );
//                           return;
//                         }

//                         String? selectedUnit =
//                             await controller.showUnitSelectionForNewProduct(fullItemCode);

//                         if (selectedUnit != null && selectedUnit.isNotEmpty) {
//                           unitController.text = selectedUnit;

//                           Get.snackbar(
//                             'تم الاختيار',
//                             'تم اختيار الوحدة: $selectedUnit',
//                             backgroundColor: Colors.green,
//                             colorText: Colors.white,
//                             duration: const Duration(seconds: 2),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.list_alt),
//                       tooltip: 'اختيار وحدة',
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: priceController,
//                   label: 'السعر',
//                   hint: 'أدخل السعر',
//                   keyboardType: TextInputType.number,
//                   validator: _validatePrice,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handleAddProduct(
//               formKey,
//               itemCodeController,
//               descriptionController,
//               quantityController,
//               unitController, // ✅ الوحدة في المكان الصحيح
//               priceController, // ✅ السعر في المكان الصحيح
//               controller,
//             ),
//             child: const Text('إضافة'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handlePullProduct(
//               itemCodeController,
//               descriptionController,
//               quantityController,
//               unitController, // ✅ الوحدة في المكان الصحيح
//               priceController, // ✅ السعر في المكان الصحيح
//               stockController,
//             ),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//             child: const Text('سحب', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   static String _getFullItemCodeFromStockController() {
//     try {
//       // الحصول على StockController
//       final StockController stockController = Get.find<StockController>();

//       // التحقق من وجود نتائج البحث
//       if (stockController.stockItems.isNotEmpty) {
//         String fullCode = stockController.stockItems.first.itemCode;
//         print('Found full item code from stock: $fullCode'); // للتتبع
//         return fullCode;
//       }

//       print('No stock items found in StockController'); // للتتبع
//       return '';
//     } catch (e) {
//       print('Error accessing StockController: $e'); // للتتبع
//       return '';
//     }
//   }

//   // حوار تعديل منتج
//   static void showEditDialog(
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     final formKey = GlobalKey<FormState>();
//     final TextEditingController quantityController =
//         TextEditingController(text: line.quantity?.toString() ?? '0');
//     final TextEditingController priceController =
//         TextEditingController(text: line.price?.toString() ?? '0');

//     Get.dialog(
//       AlertDialog(
//         title: Text('تعديل المنتج ${line.itemCode}'),
//         content: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 line.description ?? '',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ProductTextField(
//                 controller: quantityController,
//                 label: 'الكمية',
//                 hint: 'أدخل الكمية',
//                 keyboardType: TextInputType.number,
//                 isRequired: true,
//                 validator: _validateQuantity,
//               ),
//               const SizedBox(height: 16),
//               ProductTextField(
//                 controller: priceController,
//                 label: 'السعر',
//                 hint: 'أدخل السعر',
//                 keyboardType: TextInputType.number,
//                 validator: _validatePrice,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handleEditProduct(
//               formKey,
//               quantityController,
//               priceController,
//               line,
//               controller,
//             ),
//             child: const Text('حفظ'),
//           ),
//         ],
//       ),
//     );
//   }

// // في ملف ProductDialogs - تصحيح دالة _handlePullProduct

//   static Future<void> _handlePullProduct(
//     TextEditingController itemCodeController, // 1
//     TextEditingController descriptionController, // 2
//     TextEditingController quantityController, // 3
//     TextEditingController unitController, // 4 ← الوحدة
//     TextEditingController priceController, // 5 ← السعر
//     StockController stockController,
//   ) async {
//     String itemCode = itemCodeController.text.trim();

//     if (itemCode.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى إدخال كود الصنف أولاً',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//       return;
//     }

//     try {
//       // تعيين كود الصنف في controller البحث
//       stockController.itemCodeController.text = itemCode;

//       // تنفيذ البحث
//       await stockController.searchStock();

//       // التحقق من وجود نتائج
//       if (stockController.stockItems.isNotEmpty) {
//         var stockItem = stockController.stockItems.first;

//         // ملء الحقول بالبيانات المسحوبة
//         descriptionController.text = stockItem.itemName ?? '';

//         // ملء الكمية إذا كانت متوفرة
//         if (stockItem.totalOnHand > 0) {
//           quantityController.text = stockItem.totalOnHand.toString();
//         }

//         // ✅ الحل: فقط ملء الوحدة إذا كانت فارغة وتجنب الكتابة فوقها
//         if (unitController.text.trim().isEmpty &&
//             stockItem.uomCode != null &&
//             stockItem.uomCode!.isNotEmpty) {
//           unitController.text = stockItem.uomCode!;
//         }

//         // ملء السعر إذا كان متوفر
//         if (stockItem.avgPrice > 0) {
//           priceController.text = stockItem.avgPrice.toString();
//         }

//         Get.snackbar(
//           'نجح',
//           'تم سحب بيانات الصنف بنجاح\nالوحدة المحفوظة: "${unitController.text}"',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//           duration: const Duration(seconds: 3),
//         );

//         // ✅ طباعة للتأكد من الوحدة المحفوظة
//         print('=== بعد السحب ===');
//         print('الوحدة المحفوظة: "${unitController.text}"');
//         print('السعر المحفوظ: "${priceController.text}"');
//       } else {
//         Get.snackbar(
//           'تنبيه',
//           'لم يتم العثور على بيانات لهذا الصنف',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           icon: const Icon(Icons.info, color: Colors.white),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في سحب بيانات الصنف: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//     }
//   }

//   // التحقق من صحة الكمية
//   static String? _validateQuantity(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'يرجى إدخال الكمية';
//     }

//     double? quantity = double.tryParse(value.trim());
//     if (quantity == null || quantity < 0) {
//       return 'يرجى إدخال كمية صحيحة';
//     }

//     return null;
//   }

//   // التحقق من صحة السعر
//   static String? _validatePrice(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return null; // السعر اختياري
//     }

//     double? price = double.tryParse(value.trim());
//     if (price == null || price < 0) {
//       return 'يرجى إدخال سعر صحيح';
//     }

//     return null;
//   }

//   // // معالجة إضافة منتج جديد

//   static void _handleAddProduct(
//     GlobalKey<FormState> formKey,
//     TextEditingController itemCodeController,
//     TextEditingController descriptionController,
//     TextEditingController quantityController,
//     TextEditingController unitController, // ✅ الوحدة في المكان الصحيح
//     TextEditingController priceController, // ✅ السعر في المكان الصحيح
//     ProductManagementController controller,
//   ) {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     double quantity = double.parse(quantityController.text.trim());
//     double price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     // ✅ الحل: التحقق من الوحدة بعناية
//     String selectedUnit = unitController.text.trim();

//     // التحقق من أن الوحدة ليست رقماً (للتأكد من عدم الخلط)
//     if (selectedUnit.isNotEmpty && double.tryParse(selectedUnit) != null) {
//       Get.snackbar(
//         'خطأ',
//         'تم اكتشاف رقم في حقل الوحدة: "$selectedUnit"\nيرجى اختيار وحدة صحيحة',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//       return;
//     }

//     // التحقق من وجود وحدة صحيحة
//     if (selectedUnit.isEmpty) {
//       Get.snackbar(
//         'تنبيه',
//         'يرجى اختيار وحدة الصنف أو إدخالها يدوياً',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // استخدام الكود الكامل من StockController
//     String fullItemCode = _getFullItemCodeFromStockController();
//     String itemCodeToSave = fullItemCode.isNotEmpty ? fullItemCode : itemCodeController.text.trim();

//     Get.back();

//     // ✅ إضافة المنتج الجديد مع التأكد من الوحدة
//     Map<String, dynamic> productData = {
//       'itemCode': itemCodeToSave,
//       'description': descriptionController.text.trim(),
//       'quantity': quantity,
//       'price': price,
//       'uomCode': selectedUnit, // ✅ استخدام الوحدة المختارة فقط
//       'baseQty1': 1,
//       'uomEntry': 1,
//     };

//     print('=== بيانات المنتج النهائية ===');
//     print('productData: $productData');
//     print('الوحدة في البيانات: "${productData['uomCode']}"');

//     controller.addProduct(productData);
//   }

// // ✅ إضافة دالة للتحقق من صحة الوحدة
//   static bool _isValidUnit(String unit) {
//     if (unit.trim().isEmpty) return false;

//     // التحقق من أن الوحدة ليست رقماً
//     if (double.tryParse(unit.trim()) != null) return false;

//     // التحقق من أن الوحدة تحتوي على أحرف
//     return unit.trim().length > 0;
//   }

//   static void _handleAddProductImproved(
//     GlobalKey<FormState> formKey, // 1
//     TextEditingController itemCodeController, // 2
//     TextEditingController descriptionController, // 3
//     TextEditingController quantityController, // 4
//     TextEditingController unitController, // 5 ← الوحدة
//     TextEditingController priceController, // 6 ← السعر
//     ProductManagementController controller,
//   ) {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     // التحقق من صحة الوحدة
//     String selectedUnit = unitController.text.trim();
//     if (selectedUnit.isEmpty) {
//       Get.snackbar(
//         'تنبيه',
//         'يرجى اختيار وحدة الصنف أو إدخالها يدوياً',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return; // لا تكمل الإضافة بدون وحدة
//     }

//     double quantity = double.parse(quantityController.text.trim());
//     double price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     // استخدام الكود الكامل من StockController
//     String fullItemCode = _getFullItemCodeFromStockController();
//     String itemCodeToSave = fullItemCode.isNotEmpty ? fullItemCode : itemCodeController.text.trim();

//     print('Adding product with unit: "$selectedUnit"'); // للتتبع

//     Get.back();

//     // إضافة المنتج الجديد
//     controller.addProduct({
//       'itemCode': itemCodeToSave,
//       'description': descriptionController.text.trim(),
//       'quantity': quantity,
//       'price': price,
//       'uomCode': selectedUnit, // استخدام الوحدة المختارة مباشرة
//       'baseQty1': 1,
//       'uomEntry': 1,
//     });
//   }

//   // معالجة تعديل منتج
//   static void _handleEditProduct(
//     GlobalKey<FormState> formKey,
//     TextEditingController quantityController,
//     TextEditingController priceController,
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     double quantity = double.parse(quantityController.text.trim());
//     double price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     Get.back();

//     // تحديث الكمية والسعر
//     controller.updateProductQuantity(line, quantity);
//     if (price != line.price) {
//       controller.updateProduct(line, {
//         'quantity': quantity,
//         'price': price,
//       });
//     }
//   }
// }

// // ويدجت حقل النص المخصص
// class ProductTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final TextInputType? keyboardType;
//   final bool isRequired;
//   final String? Function(String?)? validator;

//   const ProductTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     this.keyboardType,
//     this.isRequired = false,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       validator: validator ?? (isRequired ? _defaultValidator : null),
//     );
//   }

//   String? _defaultValidator(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'هذا الحقل مطلوب';
//     }
//     return null;
//   }
// }

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/guide_controller.dart';
// import 'package:auth_app/validation/validation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';

// class ProductDialogs {
//   // حوار تأكيد الحذف
//   static void showDeleteConfirmation(
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل تريد حذف المنتج "${line.itemCode}"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteProduct(line);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // حوار إضافة منتج جديد - يستقبل ProductManagementControllerWithUI
//   static void showAddProductDialog(ProductManagementController controller) {
//     final formKey = GlobalKey<FormState>();
//     final TextEditingController itemCodeController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     final TextEditingController quantityController = TextEditingController();
//     final TextEditingController priceController = TextEditingController();
//     final TextEditingController unitController = TextEditingController();

//     final StockController stockController = Get.put(StockController());

//     Get.dialog(
//       AlertDialog(
//         title: const Text('إضافة منتج جديد'),
//         content: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ProductTextField(
//                   controller: itemCodeController,
//                   label: 'كود الصنف',
//                   hint: 'أدخل كود الصنف',
//                   isRequired: true,
//                 ),
//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: descriptionController,
//                   label: 'وصف الصنف',
//                   hint: 'أدخل وصف الصنف',
//                 ),
//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: quantityController,
//                   label: 'الكمية',
//                   hint: 'أدخل الكمية',
//                   keyboardType: TextInputType.number,
//                   isRequired: true,
//                   validator: Validation.validateQuantity,
//                 ),
//                 const SizedBox(height: 16),

//                 // حقل الوحدة مع زر الاختيار
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ProductTextField(
//                         controller: unitController,
//                         label: 'الوحدة',
//                         hint: 'أدخل الوحدة',
//                         keyboardType: TextInputType.text,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       onPressed: () async {
//                         if (itemCodeController.text.isEmpty) {
//                           Get.snackbar('خطأ', 'أدخل كود الصنف أولاً');
//                           return;
//                         }

//                         String fullItemCode = _getFullItemCodeFromStockController();

//                         if (fullItemCode.isEmpty) {
//                           Get.snackbar(
//                             'تنبيه',
//                             'اضغط على زر "سحب" أولاً للحصول على بيانات الصنف',
//                             backgroundColor: Colors.orange,
//                             colorText: Colors.white,
//                           );
//                           return;
//                         }

//                         // التحقق من نوع الكنترولر واستدعاء الدالة المناسبة
//                         String? selectedUnit;

//                         if (controller is ProductManagementControllerWithUI) {
//                           selectedUnit =
//                               await controller.showUnitSelectionForNewProduct(fullItemCode);
//                         } else {
//                           // للكنترولر الأساسي، نستخدم طريقة بديلة
//                           selectedUnit = await _showBasicUnitSelection(controller, fullItemCode);
//                         }

//                         if (selectedUnit != null && selectedUnit.isNotEmpty) {
//                           unitController.text = selectedUnit;
//                           Get.snackbar(
//                             'تم الاختيار',
//                             'تم اختيار الوحدة: $selectedUnit',
//                             backgroundColor: Colors.green,
//                             colorText: Colors.white,
//                             duration: const Duration(seconds: 2),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.list_alt),
//                       tooltip: 'اختيار وحدة',
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),
//                 ProductTextField(
//                   controller: priceController,
//                   label: 'السعر',
//                   hint: 'أدخل السعر',
//                   keyboardType: TextInputType.number,
//                   validator: Validation.validatePrice,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handleAddProduct(
//               formKey,
//               itemCodeController,
//               descriptionController,
//               quantityController,
//               unitController,
//               priceController,
//               controller,
//             ),
//             child: const Text('إضافة'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handlePullProduct(
//               itemCodeController,
//               descriptionController,
//               quantityController,
//               unitController,
//               priceController,
//               stockController,
//             ),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//             child: const Text('سحب', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // دالة بديلة لاختيار الوحدة للكنترولر الأساسي
//   static Future<String?> _showBasicUnitSelection(
//     ProductManagementController controller,
//     String itemCode,
//   ) async {
//     try {
//       var units = await controller.getItemUnits(itemCode);
//       if (units.isEmpty) return null;

//       String? selectedUnit;

//       await Get.dialog(
//         AlertDialog(
//           title: const Text('اختيار الوحدة'),
//           content: SizedBox(
//             width: double.maxFinite,
//             height: 300,
//             child: ListView.builder(
//               itemCount: units.length,
//               itemBuilder: (context, index) {
//                 final unit = units[index];
//                 return ListTile(
//                   title: Text(unit.uomName),
//                   subtitle: Text('الكمية: ${unit.baseQty} | Entry: ${unit.uomEntry}'),
//                   onTap: () {
//                     selectedUnit = unit.uomName;
//                     Get.back();
//                   },
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('إلغاء'),
//             ),
//           ],
//         ),
//       );

//       return selectedUnit;
//     } catch (e) {
//       Get.snackbar('خطأ', 'فشل في جلب الوحدات: $e');
//       return null;
//     }
//   }

//   static String _getFullItemCodeFromStockController() {
//     try {
//       final StockController stockController = Get.find<StockController>();
//       if (stockController.stockItems.isNotEmpty) {
//         String fullCode = stockController.stockItems.first.itemCode;
//         print('Found full item code from stock: $fullCode');
//         return fullCode;
//       }
//       print('No stock items found in StockController');
//       return '';
//     } catch (e) {
//       print('Error accessing StockController: $e');
//       return '';
//     }
//   }

//   // حوار تعديل منتج
//   static void showEditDialog(
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     final formKey = GlobalKey<FormState>();
//     final TextEditingController quantityController =
//         TextEditingController(text: line.quantity?.toString() ?? '0');
//     final TextEditingController priceController =
//         TextEditingController(text: line.price?.toString() ?? '0');

//     Get.dialog(
//       AlertDialog(
//         title: Text('تعديل المنتج ${line.itemCode}'),
//         content: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 line.description ?? '',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ProductTextField(
//                 controller: quantityController,
//                 label: 'الكمية',
//                 hint: 'أدخل الكمية',
//                 keyboardType: TextInputType.number,
//                 isRequired: true,
//                 // validator: validateQuantity,
//                 validator: Validation.validateQuantity,
//               ),
//               const SizedBox(height: 16),
//               ProductTextField(
//                 controller: priceController,
//                 label: 'السعر',
//                 hint: 'أدخل السعر',
//                 keyboardType: TextInputType.number,
//                 validator: Validation.validatePrice,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => _handleEditProduct(
//               formKey,
//               quantityController,
//               priceController,
//               line,
//               controller,
//             ),
//             child: const Text('حفظ'),
//           ),
//         ],
//       ),
//     );
//   }

//   static Future<void> _handlePullProduct(
//     TextEditingController itemCodeController,
//     TextEditingController descriptionController,
//     TextEditingController quantityController,
//     TextEditingController unitController,
//     TextEditingController priceController,
//     StockController stockController,
//   ) async {
//     String itemCode = itemCodeController.text.trim();

//     if (itemCode.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى إدخال كود الصنف أولاً',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//       return;
//     }

//     try {
//       stockController.itemCodeController.text = itemCode;
//       await stockController.searchStock();

//       if (stockController.stockItems.isNotEmpty) {
//         var stockItem = stockController.stockItems.first;

//         descriptionController.text = stockItem.itemName ?? '';

//         if (stockItem.totalOnHand > 0) {
//           quantityController.text = stockItem.totalOnHand.toString();
//         }

//         if (unitController.text.trim().isEmpty &&
//             stockItem.uomCode != null &&
//             stockItem.uomCode!.isNotEmpty) {
//           unitController.text = stockItem.uomCode!;
//         }

//         if (stockItem.avgPrice > 0) {
//           priceController.text = stockItem.avgPrice.toString();
//         }

//         Get.snackbar(
//           'نجح',
//           'تم سحب بيانات الصنف بنجاح\nالوحدة المحفوظة: "${unitController.text}"',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//           duration: const Duration(seconds: 3),
//         );

//         print('=== بعد السحب ===');
//         print('الوحدة المحفوظة: "${unitController.text}"');
//         print('السعر المحفوظ: "${priceController.text}"');
//       } else {
//         Get.snackbar(
//           'تنبيه',
//           'لم يتم العثور على بيانات لهذا الصنف',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           icon: const Icon(Icons.info, color: Colors.white),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في سحب بيانات الصنف: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//     }
//   }

//   static void _handleAddProduct(
//     GlobalKey<FormState> formKey,
//     TextEditingController itemCodeController,
//     TextEditingController descriptionController,
//     TextEditingController quantityController,
//     TextEditingController unitController,
//     TextEditingController priceController,
//     ProductManagementController controller,
//   ) {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     double quantity = double.parse(quantityController.text.trim());
//     double price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     String selectedUnit = unitController.text.trim();

//     if (selectedUnit.isNotEmpty && double.tryParse(selectedUnit) != null) {
//       Get.snackbar(
//         'خطأ',
//         'تم اكتشاف رقم في حقل الوحدة: "$selectedUnit"\nيرجى اختيار وحدة صحيحة',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//       return;
//     }

//     if (selectedUnit.isEmpty) {
//       Get.snackbar(
//         'تنبيه',
//         'يرجى اختيار وحدة الصنف أو إدخالها يدوياً',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     String fullItemCode = _getFullItemCodeFromStockController();
//     String itemCodeToSave = fullItemCode.isNotEmpty ? fullItemCode : itemCodeController.text.trim();

//     Get.back();

//     Map<String, dynamic> productData = {
//       'itemCode': itemCodeToSave,
//       'description': descriptionController.text.trim(),
//       'quantity': quantity,
//       'price': price,
//       'uomCode': selectedUnit,
//       'baseQty1': 1,
//       'uomEntry': 1,
//     };

//     print('=== بيانات المنتج النهائية ===');
//     print('productData: $productData');
//     print('الوحدة في البيانات: "${productData['uomCode']}"');

//     controller.addProduct(productData);
//   }

//   static void _handleEditProduct(
//     GlobalKey<FormState> formKey,
//     TextEditingController quantityController,
//     TextEditingController priceController,
//     dynamic line,
//     ProductManagementController controller,
//   ) {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }

//     double quantity = double.parse(quantityController.text.trim());
//     double price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     Get.back();

//     controller.updateProductQuantity(line, quantity);
//     if (price != line.price) {
//       controller.updateProduct(line, {
//         'quantity': quantity,
//         'price': price,
//       });
//     }
//   }
// }

// class ProductTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final TextInputType? keyboardType;
//   final bool isRequired;
//   final String? Function(String?)? validator;

//   const ProductTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     this.keyboardType,
//     this.isRequired = false,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       validator: validator ?? (isRequired ? Validation.defaultValidator : null),
//     );
//   }
// }

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

        descriptionController.text = stockItem.itemName ?? '';

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

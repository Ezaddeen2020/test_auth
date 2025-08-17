// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
// import 'package:auth_app/services/api/post_get_api.dart';

// class ProductManagementController extends GetxController {
//   // Status States
//   var statusRequest = StatusRequest.none.obs;
//   var isLoading = false.obs;
//   var isSaving = false.obs;

//   // Data
//   var transferId = Rxn<int>();
//   var transferDetails = Rxn<TransferDetailDto>();
//   var transferLines = <TransferLine>[].obs;
//   var filteredLines = <TransferLine>[].obs;

//   // Search
//   var searchQuery = ''.obs;
//   late TextEditingController searchController;

//   // API
//   late TransferApi transferApi;

//   // Track changes
//   var hasUnsavedChanges = false.obs;
//   var modifiedLines = <int, TransferLine>{}.obs; // lineNum -> modified line
//   var newLines = <TransferLine>[].obs; // خطوط جديدة بدون lineNum
//   var deletedLines = <int>[].obs; // lineNums للخطوط المحذوفة

//   @override
//   void onInit() {
//     super.onInit();
//     searchController = TextEditingController();
//     transferApi = TransferApi(PostGetPage());
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }

//   // تحميل أسطر التحويل من الباك إند
//   Future<void> loadTransferLines(int selectedTransferId) async {
//     try {
//       isLoading.value = true;
//       statusRequest.value = StatusRequest.loading;
//       transferId.value = selectedTransferId;

//       var response = await transferApi.getTransferDetails(selectedTransferId);

//       if (response['status'] == 'success') {
//         TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

//         transferDetails.value = details;
//         transferLines.value = details.lines;

//         // إعادة تعيين التتبع للتغييرات
//         _resetChangeTracking();

//         _applyFilter();
//         statusRequest.value = StatusRequest.success;
//       } else {
//         statusRequest.value = StatusRequest.failure;
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في تحميل أصناف التحويل',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       statusRequest.value = StatusRequest.failure;
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // إعادة تعيين تتبع التغييرات
//   void _resetChangeTracking() {
//     hasUnsavedChanges.value = false;
//     modifiedLines.clear();
//     newLines.clear();
//     deletedLines.clear();
//   }

//   // تحديث البحث وتطبيق الفلترة
//   void updateSearch(String query) {
//     searchQuery.value = query;
//     _applyFilter();
//   }

//   // تطبيق الفلترة على الأسطر
//   void _applyFilter() {
//     if (transferLines.isEmpty) {
//       filteredLines.clear();
//       return;
//     }

//     if (searchQuery.value.isEmpty) {
//       filteredLines.value = List.from(transferLines);
//     } else {
//       String query = searchQuery.value.toLowerCase();
//       filteredLines.value = transferLines.where((line) {
//         bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
//         bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
//         return matchesItemCode || matchesDescription;
//       }).toList();
//     }
//   }

//   // تحديث وحدة المنتج
//   void updateProductUnit(dynamic line, String newUnitName, int newBaseQty, int newUomEntry) {
//     try {
//       int index = transferLines
//           .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//       if (index != -1) {
//         // إنشاء سطر محدث بالوحدة الجديدة
//         TransferLine updatedLine = TransferLine(
//           docEntry: line.docEntry,
//           lineNum: line.lineNum,
//           itemCode: line.itemCode,
//           description: line.description,
//           quantity: line.quantity,
//           price: line.price,
//           lineTotal: line.lineTotal,
//           uomCode: newUnitName,
//           uomCode2: line.uomCode2,
//           invQty: line.invQty,
//           baseQty1: newBaseQty,
//           ugpEntry: line.ugpEntry,
//           uomEntry: newUomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();

//         Get.snackbar(
//           'تم التحديث',
//           'تم تغيير الوحدة إلى $newUnitName',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في تحديث الوحدة: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // تحديث كمية المنتج
//   void updateProductQuantity(dynamic line, double newQuantity) {
//     try {
//       int index = transferLines
//           .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//       if (index != -1) {
//         // إنشاء سطر محدث بالكمية الجديدة
//         TransferLine updatedLine = TransferLine(
//           docEntry: line.docEntry,
//           lineNum: line.lineNum,
//           itemCode: line.itemCode,
//           description: line.description,
//           quantity: newQuantity,
//           price: line.price,
//           lineTotal: newQuantity * (line.price ?? 0.0),
//           uomCode: line.uomCode,
//           uomCode2: line.uomCode2,
//           invQty: line.invQty,
//           baseQty1: line.baseQty1,
//           ugpEntry: line.ugpEntry,
//           uomEntry: line.uomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في تحديث الكمية: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // إضافة منتج جديد
//   void addProduct(Map<String, dynamic> productData) {
//     try {
//       // إنشاء سطر جديد بدون lineNum (سيتم إنشاؤه من الخادم)
//       TransferLine newLine = TransferLine(
//         docEntry: transferId.value,
//         lineNum: null, // لا نحدد lineNum للإضافات الجديدة
//         itemCode: productData['itemCode'],
//         description: productData['description'],
//         quantity: productData['quantity']?.toDouble(),
//         price: productData['price']?.toDouble(),
//         lineTotal: (productData['quantity']?.toDouble() ?? 0.0) *
//             (productData['price']?.toDouble() ?? 0.0),
//         uomCode: productData['uomCode'],
//         uomCode2: productData['uomCode2'],
//         invQty: productData['invQty']?.toDouble(),
//         baseQty1: productData['baseQty1']?.toInt(),
//         ugpEntry: productData['ugpEntry']?.toInt(),
//         uomEntry: productData['uomEntry']?.toInt(),
//       );

//       // إضافة للقائمة الرئيسية مع lineNum مؤقت للعرض
//       TransferLine displayLine = TransferLine(
//         docEntry: newLine.docEntry,
//         lineNum: _getNextTempLineNumber(), // رقم مؤقت للعرض
//         itemCode: newLine.itemCode,
//         description: newLine.description,
//         quantity: newLine.quantity,
//         price: newLine.price,
//         lineTotal: newLine.lineTotal,
//         uomCode: newLine.uomCode,
//         uomCode2: newLine.uomCode2,
//         invQty: newLine.invQty,
//         baseQty1: newLine.baseQty1,
//         ugpEntry: newLine.ugpEntry,
//         uomEntry: newLine.uomEntry,
//       );

//       transferLines.add(displayLine);
//       newLines.add(newLine); // تتبع كونه جديد
//       hasUnsavedChanges.value = true;

//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم إضافة المنتج بنجاح (يتطلب حفظ)',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في إضافة المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // تعديل منتج موجود
//   void updateProduct(TransferLine oldLine, Map<String, dynamic> newData) {
//     try {
//       int index = transferLines.indexWhere(
//           (line) => line.lineNum == oldLine.lineNum && line.itemCode == oldLine.itemCode);

//       if (index != -1) {
//         TransferLine updatedLine = TransferLine(
//           docEntry: oldLine.docEntry,
//           lineNum: oldLine.lineNum,
//           itemCode: newData['itemCode'] ?? oldLine.itemCode,
//           description: newData['description'] ?? oldLine.description,
//           quantity: newData['quantity']?.toDouble() ?? oldLine.quantity,
//           price: newData['price']?.toDouble() ?? oldLine.price,
//           lineTotal: (newData['quantity']?.toDouble() ?? oldLine.quantity ?? 0.0) *
//               (newData['price']?.toDouble() ?? oldLine.price ?? 0.0),
//           uomCode: newData['uomCode'] ?? oldLine.uomCode,
//           uomCode2: newData['uomCode2'] ?? oldLine.uomCode2,
//           invQty: newData['invQty']?.toDouble() ?? oldLine.invQty,
//           baseQty1: newData['baseQty1']?.toInt() ?? oldLine.baseQty1,
//           ugpEntry: newData['ugpEntry']?.toInt() ?? oldLine.ugpEntry,
//           uomEntry: newData['uomEntry']?.toInt() ?? oldLine.uomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();

//         Get.snackbar(
//           'نجح',
//           'تم تعديل المنتج بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في تعديل المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // حذف منتج
//   void deleteProduct(TransferLine line) {
//     try {
//       // إزالة من القائمة الرئيسية
//       transferLines
//           .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//       // تتبع الحذف
//       if (line.lineNum != null && line.lineNum! > 0) {
//         // إذا كان سطر موجود في الخادم
//         deletedLines.add(line.lineNum!);
//         hasUnsavedChanges.value = true;
//       } else {
//         // إذا كان سطر جديد لم يُحفظ بعد
//         newLines.removeWhere((newLine) => newLine.itemCode == line.itemCode);
//       }

//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم حذف المنتج بنجاح',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في حذف المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // تتبع تغيير السطر
//   void _trackLineChange(TransferLine line) {
//     if (line.lineNum != null && line.lineNum! > 0) {
//       modifiedLines[line.lineNum!] = line;
//       hasUnsavedChanges.value = true;
//     }
//   }

//   // الحصول على رقم سطر مؤقت للعرض
//   int _getNextTempLineNumber() {
//     int maxLineNum = 0;
//     for (TransferLine line in transferLines) {
//       if (line.lineNum != null && line.lineNum! > maxLineNum) {
//         maxLineNum = line.lineNum!;
//       }
//     }
//     return -(maxLineNum + 1); // استخدام أرقام سالبة للأسطر الجديدة
//   }

//   // حفظ جميع التغييرات على الخادم
//   Future<void> saveAllChangesToServer() async {
//     if (!hasUnsavedChanges.value) {
//       Get.snackbar(
//         'تنبيه',
//         'لا توجد تغييرات للحفظ',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       isSaving.value = true;
//       int successCount = 0;
//       int errorCount = 0;

//       // 1. حفظ الأسطر الجديدة
//       for (TransferLine newLine in newLines) {
//         var result = await _saveNewLine(newLine);
//         if (result['success'] == true) {
//           successCount++;
//           // تحديث lineNum من الاستجابة
//           if (result['lineNum'] != null) {
//             _updateLineNumInList(newLine, result['lineNum']);
//           }
//         } else {
//           errorCount++;
//         }
//       }

//       // 2. حفظ الأسطر المعدلة
//       for (TransferLine modifiedLine in modifiedLines.values) {
//         var result = await _saveModifiedLine(modifiedLine);
//         if (result['success'] == true) {
//           successCount++;
//         } else {
//           errorCount++;
//         }
//       }

//       // 3. حذف الأسطر المحذوفة
//       for (int deletedLineNum in deletedLines) {
//         var result = await _deleteLineFromServer(deletedLineNum);
//         if (result['success'] == true) {
//           successCount++;
//         } else {
//           errorCount++;
//         }
//       }

//       // عرض النتائج
//       if (errorCount == 0) {
//         _resetChangeTracking();
//         Get.snackbar(
//           'نجح',
//           'تم حفظ جميع التغييرات بنجاح ($successCount عملية)',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );

//         // إعادة تحميل البيانات من الخادم للتأكد من التطابق
//         if (transferId.value != null) {
//           await loadTransferLines(transferId.value!);
//         }
//       } else {
//         Get.snackbar(
//           'تحذير',
//           'تم حفظ $successCount عملية بنجاح، فشل في $errorCount عملية',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في حفظ التغييرات: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   // حفظ سطر جديد
//   Future<Map<String, dynamic>> _saveNewLine(TransferLine line) async {
//     try {
//       var response = await transferApi.upsertTransferLine(
//         docEntry: line.docEntry ?? transferId.value!,
//         lineNum: null, // أو -1 أو 0 للإضافة الجديدة
//         itemCode: line.itemCode!,
//         description: line.description ?? '',
//         quantity: line.quantity ?? 0.0,
//         price: line.price ?? 0.0,
//         lineTotal: line.lineTotal ?? 0.0,
//         uomCode: line.uomCode ?? '',
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       if (response['status'] == 'success') {
//         return {
//           'success': true,
//           'lineNum': response['data']?['lineNum'], // lineNum الجديد من الخادم
//         };
//       } else {
//         return {'success': false, 'error': response['message']};
//       }
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // حفظ سطر معدل
//   Future<Map<String, dynamic>> _saveModifiedLine(TransferLine line) async {
//     try {
//       var response = await transferApi.upsertTransferLine(
//         docEntry: line.docEntry!,
//         lineNum: line.lineNum!, // lineNum موجود للتعديل
//         itemCode: line.itemCode!,
//         description: line.description ?? '',
//         quantity: line.quantity ?? 0.0,
//         price: line.price ?? 0.0,
//         lineTotal: line.lineTotal ?? 0.0,
//         uomCode: line.uomCode ?? '',
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       return {
//         'success': response['status'] == 'success',
//         'error': response['message'],
//       };
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // حذف سطر من الخادم
//   Future<Map<String, dynamic>> _deleteLineFromServer(int lineNum) async {
//     try {
//       var response = await transferApi.deleteTransferLine(
//         docEntry: transferId.value!,
//         lineNum: lineNum,
//       );

//       return {
//         'success': response['status'] == 'success',
//         'error': response['message'],
//       };
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // تحديث lineNum في القائمة بعد الإضافة الناجحة
//   void _updateLineNumInList(TransferLine oldLine, int newLineNum) {
//     int index = transferLines.indexWhere(
//         (line) => line.itemCode == oldLine.itemCode && line.lineNum != null && line.lineNum! < 0);

//     if (index != -1) {
//       TransferLine updatedLine = TransferLine(
//         docEntry: transferLines[index].docEntry,
//         lineNum: newLineNum, // LineNum الجديد من الخادم
//         itemCode: transferLines[index].itemCode,
//         description: transferLines[index].description,
//         quantity: transferLines[index].quantity,
//         price: transferLines[index].price,
//         lineTotal: transferLines[index].lineTotal,
//         uomCode: transferLines[index].uomCode,
//         uomCode2: transferLines[index].uomCode2,
//         invQty: transferLines[index].invQty,
//         baseQty1: transferLines[index].baseQty1,
//         ugpEntry: transferLines[index].ugpEntry,
//         uomEntry: transferLines[index].uomEntry,
//       );

//       transferLines[index] = updatedLine;
//     }
//   }

//   // باقي الدوال المساعدة...
//   Map<String, dynamic> getProductStats() {
//     if (filteredLines.isEmpty) {
//       return {
//         'totalItems': 0,
//         'totalQuantity': 0.0,
//         'totalAmount': 0.0,
//         'uniqueItems': 0,
//       };
//     }

//     double totalQuantity = 0.0;
//     double totalAmount = 0.0;
//     Set<String> uniqueItems = {};

//     for (TransferLine line in filteredLines) {
//       totalQuantity += line.quantity ?? 0.0;
//       totalAmount += line.lineTotal ?? 0.0;

//       if (line.itemCode != null && line.itemCode!.isNotEmpty) {
//         uniqueItems.add(line.itemCode!);
//       }
//     }

//     return {
//       'totalItems': filteredLines.length,
//       'totalQuantity': totalQuantity,
//       'totalAmount': totalAmount,
//       'uniqueItems': uniqueItems.length,
//     };
//   }

//   // مسح البحث
//   void clearSearch() {
//     searchController.clear();
//     updateSearch('');
//   }

//   // إعادة تعيين البيانات
//   void resetData() {
//     transferId.value = null;
//     transferDetails.value = null;
//     transferLines.clear();
//     filteredLines.clear();
//     searchController.clear();
//     searchQuery.value = '';
//     statusRequest.value = StatusRequest.none;
//     _resetChangeTracking();
//   }

//   // نسخ منتج
//   void duplicateProduct(TransferLine line) {
//     try {
//       // إنشاء سطر مكرر كسطر جديد
//       TransferLine duplicatedLine = TransferLine(
//         docEntry: line.docEntry,
//         lineNum: null, // سطر جديد بدون lineNum
//         itemCode: line.itemCode,
//         description: line.description,
//         quantity: line.quantity,
//         price: line.price,
//         lineTotal: line.lineTotal,
//         uomCode: line.uomCode,
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       // إضافة للعرض مع رقم مؤقت
//       TransferLine displayLine = TransferLine(
//         docEntry: duplicatedLine.docEntry,
//         lineNum: _getNextTempLineNumber(),
//         itemCode: duplicatedLine.itemCode,
//         description: duplicatedLine.description,
//         quantity: duplicatedLine.quantity,
//         price: duplicatedLine.price,
//         lineTotal: duplicatedLine.lineTotal,
//         uomCode: duplicatedLine.uomCode,
//         uomCode2: duplicatedLine.uomCode2,
//         invQty: duplicatedLine.invQty,
//         baseQty1: duplicatedLine.baseQty1,
//         ugpEntry: duplicatedLine.ugpEntry,
//         uomEntry: duplicatedLine.uomEntry,
//       );

//       transferLines.add(displayLine);
//       newLines.add(duplicatedLine); // تتبع كونه جديد
//       hasUnsavedChanges.value = true;

//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم نسخ المنتج بنجاح (يتطلب حفظ)',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في نسخ المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // ترتيب المنتجات بواسطة معايير مختلفة
//   void sortProducts(String sortBy) {
//     List<TransferLine> lines = List.from(filteredLines);

//     switch (sortBy) {
//       case 'itemCode':
//         lines.sort((a, b) => (a.itemCode ?? '').compareTo(b.itemCode ?? ''));
//         break;
//       case 'quantity':
//         lines.sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
//         break;
//       case 'price':
//         lines.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
//         break;
//       case 'lineTotal':
//         lines.sort((a, b) => (b.lineTotal ?? 0).compareTo(a.lineTotal ?? 0));
//         break;
//       case 'lineNum':
//       default:
//         lines.sort((a, b) => (a.lineNum ?? 0).compareTo(b.lineNum ?? 0));
//         break;
//     }

//     filteredLines.value = lines;
//   }

//   // البحث عن منتج بواسطة كود الصنف
//   List<TransferLine> searchByItemCode(String itemCode) {
//     return filteredLines
//         .where((line) => line.itemCode?.toLowerCase().contains(itemCode.toLowerCase()) ?? false)
//         .toList();
//   }

//   // الحصول على منتج بواسطة رقم السطر
//   TransferLine? getProductByLineNumber(int lineNum) {
//     try {
//       return transferLines.firstWhere((line) => line.lineNum == lineNum);
//     } catch (e) {
//       return null;
//     }
//   }

//   // التحقق من وجود منتج بنفس الكود
//   bool isProductExists(String itemCode) {
//     return transferLines.any((line) => line.itemCode == itemCode);
//   }

//   // تصدير البيانات
//   Map<String, dynamic> exportProductData() {
//     return {
//       'transferId': transferId.value,
//       'products': filteredLines.map((line) => line.toJson()).toList(),
//       'stats': getProductStats(),
//       'exportDate': DateTime.now().toIso8601String(),
//     };
//   }

//   // فلترة المنتجات بناءً على المخزون
//   void filterByInventory(String filterType) {
//     List<TransferLine> lines = List.from(transferLines);

//     switch (filterType) {
//       case 'available':
//         lines = lines.where((line) => (line.invQty ?? 0) > 0).toList();
//         break;
//       case 'low_stock':
//         lines = lines.where((line) => (line.invQty ?? 0) > 0 && (line.invQty ?? 0) < 10).toList();
//         break;
//       case 'out_of_stock':
//         lines = lines.where((line) => (line.invQty ?? 0) <= 0).toList();
//         break;
//       case 'high_value':
//         lines = lines.where((line) => (line.lineTotal ?? 0) > 1000).toList();
//         break;
//       default:
//         // عرض جميع المنتجات
//         break;
//     }

//     filteredLines.value = lines;
//   }

//   // حساب إجمالي قيمة المنتجات المحددة
//   double calculateSelectedProductsValue(List<TransferLine> selectedLines) {
//     return selectedLines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
//   }

//   // التحقق من صحة بيانات المنتج
//   bool validateProductData(Map<String, dynamic> productData) {
//     if (productData['itemCode'] == null || productData['itemCode'].toString().trim().isEmpty) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'كود المنتج مطلوب',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     if (productData['quantity'] == null || productData['quantity'] <= 0) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'الكمية يجب أن تكون أكبر من صفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     if (productData['price'] == null || productData['price'] < 0) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'السعر يجب أن يكون أكبر من أو يساوي صفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     return true;
//   }

//   // إحصائيات متقدمة
//   Map<String, dynamic> getAdvancedStats() {
//     if (filteredLines.isEmpty) {
//       return {
//         'averagePrice': 0.0,
//         'averageQuantity': 0.0,
//         'averageLineTotal': 0.0,
//         'highestPrice': 0.0,
//         'lowestPrice': 0.0,
//         'totalValue': 0.0,
//       };
//     }

//     List<double> prices =
//         filteredLines.map((line) => line.price ?? 0.0).where((price) => price > 0).toList();

//     List<double> quantities =
//         filteredLines.map((line) => line.quantity ?? 0.0).where((qty) => qty > 0).toList();

//     List<double> totals = filteredLines.map((line) => line.lineTotal ?? 0.0).toList();

//     return {
//       'averagePrice': prices.isNotEmpty ? prices.reduce((a, b) => a + b) / prices.length : 0.0,
//       'averageQuantity':
//           quantities.isNotEmpty ? quantities.reduce((a, b) => a + b) / quantities.length : 0.0,
//       'averageLineTotal': totals.isNotEmpty ? totals.reduce((a, b) => a + b) / totals.length : 0.0,
//       'highestPrice': prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0.0,
//       'lowestPrice': prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0,
//       'totalValue': totals.isNotEmpty ? totals.reduce((a, b) => a + b) : 0.0,
//     };
//   }

//   // Helper methods للحصول على المعلومات
//   int get totalProductsCount => transferLines.length;
//   int get filteredProductsCount => filteredLines.length;
//   bool get hasActiveSearch => searchQuery.value.isNotEmpty;
//   bool get hasData => transferLines.isNotEmpty;
//   bool get hasSelectedTransfer => transferId.value != null;

//   // عدد التغييرات غير المحفوظة
//   int get unsavedChangesCount => newLines.length + modifiedLines.length + deletedLines.length;

//   // التحقق من إمكانية الحفظ
//   bool get canSave => hasUnsavedChanges.value && !isSaving.value;

//   // الحصول على أعلى قيمة منتج
//   TransferLine? get highestValueProduct {
//     if (filteredLines.isEmpty) return null;

//     TransferLine highest = filteredLines.first;
//     for (TransferLine line in filteredLines) {
//       if ((line.lineTotal ?? 0) > (highest.lineTotal ?? 0)) {
//         highest = line;
//       }
//     }
//     return highest;
//   }

//   // الحصول على أعلى كمية منتج
//   TransferLine? get highestQuantityProduct {
//     if (filteredLines.isEmpty) return null;

//     TransferLine highest = filteredLines.first;
//     for (TransferLine line in filteredLines) {
//       if ((line.quantity ?? 0) > (highest.quantity ?? 0)) {
//         highest = line;
//       }
//     }
//     return highest;
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:auth_app/services/api/post_get_api.dart';

class ProductManagementController extends GetxController {
  // Status States
  var statusRequest = StatusRequest.none.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Data
  var transferId = Rxn<int>();
  var transferDetails = Rxn<TransferDetailDto>();
  var transferLines = <TransferLine>[].obs;
  var filteredLines = <TransferLine>[].obs;

  // Search
  var searchQuery = ''.obs;
  late TextEditingController searchController;

  // API
  late TransferApi transferApi;

  // Track changes
  var hasUnsavedChanges = false.obs;
  var modifiedLines = <int, TransferLine>{}.obs; // lineNum -> modified line
  var newLines = <TransferLine>[].obs; // خطوط جديدة بدون lineNum
  var deletedLines = <int>[].obs; // lineNums للخطوط المحذوفة

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    transferApi = TransferApi(PostGetPage());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // تحميل أسطر التحويل من الباك إند
  Future<void> loadTransferLines(int selectedTransferId) async {
    try {
      isLoading.value = true;
      statusRequest.value = StatusRequest.loading;
      transferId.value = selectedTransferId;

      var response = await transferApi.getTransferDetails(selectedTransferId);

      if (response['status'] == 'success') {
        TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

        transferDetails.value = details;
        transferLines.value = details.lines;

        // إعادة تعيين التتبع للتغييرات
        _resetChangeTracking();

        _applyFilter();
        statusRequest.value = StatusRequest.success;
      } else {
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في تحميل أصناف التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة تعيين تتبع التغييرات
  void _resetChangeTracking() {
    hasUnsavedChanges.value = false;
    modifiedLines.clear();
    newLines.clear();
    deletedLines.clear();
  }

  // تحديث البحث وتطبيق الفلترة
  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  // تطبيق الفلترة على الأسطر
  void _applyFilter() {
    if (transferLines.isEmpty) {
      filteredLines.clear();
      return;
    }

    if (searchQuery.value.isEmpty) {
      filteredLines.value = List.from(transferLines);
    } else {
      String query = searchQuery.value.toLowerCase();
      filteredLines.value = transferLines.where((line) {
        bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
        bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
        return matchesItemCode || matchesDescription;
      }).toList();
    }
  }

  // تحديث وحدة المنتج
  void updateProductUnit(TransferLine line, String newUnitName, int newBaseQty, int newUomEntry) {
    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
        // إنشاء سطر محدث بالوحدة الجديدة
        TransferLine updatedLine = TransferLine(
          docEntry: line.docEntry,
          lineNum: line.lineNum,
          itemCode: line.itemCode,
          description: line.description,
          quantity: line.quantity,
          price: line.price,
          lineTotal: line.lineTotal,
          uomCode: newUnitName,
          uomCode2: line.uomCode2,
          invQty: line.invQty,
          baseQty1: newBaseQty,
          ugpEntry: line.ugpEntry,
          uomEntry: newUomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();

        Get.snackbar(
          'تم التحديث',
          'تم تغيير الوحدة إلى $newUnitName',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الوحدة: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تحديث كمية المنتج
  void updateProductQuantity(TransferLine line, double newQuantity) {
    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
        // إنشاء سطر محدث بالكمية الجديدة
        TransferLine updatedLine = TransferLine(
          docEntry: line.docEntry,
          lineNum: line.lineNum,
          itemCode: line.itemCode,
          description: line.description,
          quantity: newQuantity,
          price: line.price,
          lineTotal: newQuantity * (line.price ?? 0.0),
          uomCode: line.uomCode,
          uomCode2: line.uomCode2,
          invQty: line.invQty,
          baseQty1: line.baseQty1,
          ugpEntry: line.ugpEntry,
          uomEntry: line.uomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الكمية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // إضافة منتج جديد
  void addProduct(Map<String, dynamic> productData) {
    try {
      // التحقق من صحة البيانات
      if (!validateProductData(productData)) {
        return;
      }

      // إنشاء سطر جديد بدون lineNum (سيتم إنشاؤه من الخادم)
      TransferLine newLine = TransferLine(
        docEntry: transferId.value,
        lineNum: null, // لا نحدد lineNum للإضافات الجديدة
        itemCode: productData['itemCode'],
        description: productData['description'],
        quantity: productData['quantity']?.toDouble(),
        price: productData['price']?.toDouble(),
        lineTotal: (productData['quantity']?.toDouble() ?? 0.0) *
            (productData['price']?.toDouble() ?? 0.0),
        uomCode: productData['uomCode'],
        uomCode2: productData['uomCode2'],
        invQty: productData['invQty']?.toDouble(),
        baseQty1: productData['baseQty1']?.toInt(),
        ugpEntry: productData['ugpEntry']?.toInt(),
        uomEntry: productData['uomEntry']?.toInt(),
      );

      // إضافة للقائمة الرئيسية مع lineNum مؤقت للعرض
      TransferLine displayLine = TransferLine(
        docEntry: newLine.docEntry,
        lineNum: _getNextTempLineNumber(), // رقم مؤقت للعرض
        itemCode: newLine.itemCode,
        description: newLine.description,
        quantity: newLine.quantity,
        price: newLine.price,
        lineTotal: newLine.lineTotal,
        uomCode: newLine.uomCode,
        uomCode2: newLine.uomCode2,
        invQty: newLine.invQty,
        baseQty1: newLine.baseQty1,
        ugpEntry: newLine.ugpEntry,
        uomEntry: newLine.uomEntry,
      );

      transferLines.add(displayLine);
      newLines.add(newLine); // تتبع كونه جديد
      hasUnsavedChanges.value = true;

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم إضافة المنتج بنجاح (يتطلب حفظ)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تعديل منتج موجود
  void updateProduct(TransferLine oldLine, Map<String, dynamic> newData) {
    try {
      int index = transferLines.indexWhere(
          (line) => line.lineNum == oldLine.lineNum && line.itemCode == oldLine.itemCode);

      if (index != -1) {
        TransferLine updatedLine = TransferLine(
          docEntry: oldLine.docEntry,
          lineNum: oldLine.lineNum,
          itemCode: newData['itemCode'] ?? oldLine.itemCode,
          description: newData['description'] ?? oldLine.description,
          quantity: newData['quantity']?.toDouble() ?? oldLine.quantity,
          price: newData['price']?.toDouble() ?? oldLine.price,
          lineTotal: (newData['quantity']?.toDouble() ?? oldLine.quantity ?? 0.0) *
              (newData['price']?.toDouble() ?? oldLine.price ?? 0.0),
          uomCode: newData['uomCode'] ?? oldLine.uomCode,
          uomCode2: newData['uomCode2'] ?? oldLine.uomCode2,
          invQty: newData['invQty']?.toDouble() ?? oldLine.invQty,
          baseQty1: newData['baseQty1']?.toInt() ?? oldLine.baseQty1,
          ugpEntry: newData['ugpEntry']?.toInt() ?? oldLine.ugpEntry,
          uomEntry: newData['uomEntry']?.toInt() ?? oldLine.uomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();

        Get.snackbar(
          'نجح',
          'تم تعديل المنتج بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تعديل المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // حذف منتج
  void deleteProduct(TransferLine line) {
    try {
      // إزالة من القائمة الرئيسية
      transferLines
          .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      // تتبع الحذف
      if (line.lineNum != null && line.lineNum! > 0) {
        // إذا كان سطر موجود في الخادم
        deletedLines.add(line.lineNum!);
        hasUnsavedChanges.value = true;
      } else {
        // إذا كان سطر جديد لم يُحفظ بعد
        newLines.removeWhere((newLine) => newLine.itemCode == line.itemCode);
      }

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم حذف المنتج بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تتبع تغيير السطر
  void _trackLineChange(TransferLine line) {
    if (line.lineNum != null && line.lineNum! > 0) {
      modifiedLines[line.lineNum!] = line;
      hasUnsavedChanges.value = true;
    }
  }

  // الحصول على رقم سطر مؤقت للعرض
  int _getNextTempLineNumber() {
    int maxLineNum = 0;
    for (TransferLine line in transferLines) {
      if (line.lineNum != null && line.lineNum! > maxLineNum) {
        maxLineNum = line.lineNum!;
      }
    }
    return -(maxLineNum + 1); // استخدام أرقام سالبة للأسطر الجديدة
  }

  // حفظ جميع التغييرات على الخادم
  Future<void> saveAllChangesToServer() async {
    if (!hasUnsavedChanges.value) {
      Get.snackbar(
        'تنبيه',
        'لا توجد تغييرات للحفظ',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      int successCount = 0;
      int errorCount = 0;

      // 1. حفظ الأسطر الجديدة
      for (TransferLine newLine in newLines) {
        var result = await _saveNewLine(newLine);
        if (result['success'] == true) {
          successCount++;
          // تحديث lineNum من الاستجابة
          if (result['lineNum'] != null) {
            _updateLineNumInList(newLine, result['lineNum']);
          }
        } else {
          errorCount++;
        }
      }

      // 2. حفظ الأسطر المعدلة
      for (TransferLine modifiedLine in modifiedLines.values) {
        var result = await _saveModifiedLine(modifiedLine);
        if (result['success'] == true) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      // 3. حذف الأسطر المحذوفة
      for (int deletedLineNum in deletedLines) {
        var result = await _deleteLineFromServer(deletedLineNum);
        if (result['success'] == true) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      // عرض النتائج
      if (errorCount == 0) {
        _resetChangeTracking();
        Get.snackbar(
          'نجح',
          'تم حفظ جميع التغييرات بنجاح ($successCount عملية)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // إعادة تحميل البيانات من الخادم للتأكد من التطابق
        if (transferId.value != null) {
          await loadTransferLines(transferId.value!);
        }
      } else {
        Get.snackbar(
          'تحذير',
          'تم حفظ $successCount عملية بنجاح، فشل في $errorCount عملية',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ التغييرات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // حفظ سطر جديد
  Future<Map<String, dynamic>> _saveNewLine(TransferLine line) async {
    try {
      var response = await transferApi.upsertTransferLine(
        docEntry: line.docEntry ?? transferId.value!,
        lineNum: null, // أو -1 أو 0 للإضافة الجديدة
        itemCode: line.itemCode!,
        description: line.description ?? '',
        quantity: line.quantity ?? 0.0,
        price: line.price ?? 0.0,
        lineTotal: line.lineTotal ?? 0.0,
        uomCode: line.uomCode ?? '',
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      if (response['status'] == 'success') {
        return {
          'success': true,
          'lineNum': response['data']?['lineNum'], // lineNum الجديد من الخادم
        };
      } else {
        return {'success': false, 'error': response['message']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // حفظ سطر معدل
  Future<Map<String, dynamic>> _saveModifiedLine(TransferLine line) async {
    try {
      var response = await transferApi.upsertTransferLine(
        docEntry: line.docEntry!,
        lineNum: line.lineNum!, // lineNum موجود للتعديل
        itemCode: line.itemCode!,
        description: line.description ?? '',
        quantity: line.quantity ?? 0.0,
        price: line.price ?? 0.0,
        lineTotal: line.lineTotal ?? 0.0,
        uomCode: line.uomCode ?? '',
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      return {
        'success': response['status'] == 'success',
        'error': response['message'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // حذف سطر من الخادم
  Future<Map<String, dynamic>> _deleteLineFromServer(int lineNum) async {
    try {
      var response = await transferApi.deleteTransferLine(
        docEntry: transferId.value!,
        lineNum: lineNum,
      );

      return {
        'success': response['status'] == 'success',
        'error': response['message'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // تحديث lineNum في القائمة بعد الإضافة الناجحة
  void _updateLineNumInList(TransferLine oldLine, int newLineNum) {
    int index = transferLines.indexWhere(
        (line) => line.itemCode == oldLine.itemCode && line.lineNum != null && line.lineNum! < 0);

    if (index != -1) {
      TransferLine updatedLine = TransferLine(
        docEntry: transferLines[index].docEntry,
        lineNum: newLineNum, // LineNum الجديد من الخادم
        itemCode: transferLines[index].itemCode,
        description: transferLines[index].description,
        quantity: transferLines[index].quantity,
        price: transferLines[index].price,
        lineTotal: transferLines[index].lineTotal,
        uomCode: transferLines[index].uomCode,
        uomCode2: transferLines[index].uomCode2,
        invQty: transferLines[index].invQty,
        baseQty1: transferLines[index].baseQty1,
        ugpEntry: transferLines[index].ugpEntry,
        uomEntry: transferLines[index].uomEntry,
      );

      transferLines[index] = updatedLine;
    }
  }

  // باقي الدوال المساعدة...
  Map<String, dynamic> getProductStats() {
    if (filteredLines.isEmpty) {
      return {
        'totalItems': 0,
        'totalQuantity': 0.0,
        'totalAmount': 0.0,
        'uniqueItems': 0,
      };
    }

    double totalQuantity = 0.0;
    double totalAmount = 0.0;
    Set<String> uniqueItems = {};

    for (TransferLine line in filteredLines) {
      totalQuantity += line.quantity ?? 0.0;
      totalAmount += line.lineTotal ?? 0.0;

      if (line.itemCode != null && line.itemCode!.isNotEmpty) {
        uniqueItems.add(line.itemCode!);
      }
    }

    return {
      'totalItems': filteredLines.length,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'uniqueItems': uniqueItems.length,
    };
  }

  // مسح البحث
  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  // إعادة تعيين البيانات
  void resetData() {
    transferId.value = null;
    transferDetails.value = null;
    transferLines.clear();
    filteredLines.clear();
    searchController.clear();
    searchQuery.value = '';
    statusRequest.value = StatusRequest.none;
    _resetChangeTracking();
  }

  // نسخ منتج
  void duplicateProduct(TransferLine line) {
    try {
      // إنشاء سطر مكرر كسطر جديد
      TransferLine duplicatedLine = TransferLine(
        docEntry: line.docEntry,
        lineNum: null, // سطر جديد بدون lineNum
        itemCode: line.itemCode,
        description: line.description,
        quantity: line.quantity,
        price: line.price,
        lineTotal: line.lineTotal,
        uomCode: line.uomCode,
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      // إضافة للعرض مع رقم مؤقت
      TransferLine displayLine = TransferLine(
        docEntry: duplicatedLine.docEntry,
        lineNum: _getNextTempLineNumber(),
        itemCode: duplicatedLine.itemCode,
        description: duplicatedLine.description,
        quantity: duplicatedLine.quantity,
        price: duplicatedLine.price,
        lineTotal: duplicatedLine.lineTotal,
        uomCode: duplicatedLine.uomCode,
        uomCode2: duplicatedLine.uomCode2,
        invQty: duplicatedLine.invQty,
        baseQty1: duplicatedLine.baseQty1,
        ugpEntry: duplicatedLine.ugpEntry,
        uomEntry: duplicatedLine.uomEntry,
      );

      transferLines.add(displayLine);
      newLines.add(duplicatedLine); // تتبع كونه جديد
      hasUnsavedChanges.value = true;

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم نسخ المنتج بنجاح (يتطلب حفظ)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في نسخ المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ترتيب المنتجات بواسطة معايير مختلفة
  void sortProducts(String sortBy) {
    List<TransferLine> lines = List.from(filteredLines);

    switch (sortBy) {
      case 'itemCode':
        lines.sort((a, b) => (a.itemCode ?? '').compareTo(b.itemCode ?? ''));
        break;
      case 'quantity':
        lines.sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
        break;
      case 'price':
        lines.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'lineTotal':
        lines.sort((a, b) => (b.lineTotal ?? 0).compareTo(a.lineTotal ?? 0));
        break;
      case 'lineNum':
      default:
        lines.sort((a, b) => (a.lineNum ?? 0).compareTo(b.lineNum ?? 0));
        break;
    }

    filteredLines.value = lines;
  }

  // البحث عن منتج بواسطة كود الصنف
  List<TransferLine> searchByItemCode(String itemCode) {
    return filteredLines
        .where((line) => line.itemCode?.toLowerCase().contains(itemCode.toLowerCase()) ?? false)
        .toList();
  }

  // الحصول على منتج بواسطة رقم السطر
  TransferLine? getProductByLineNumber(int lineNum) {
    try {
      return transferLines.firstWhere((line) => line.lineNum == lineNum);
    } catch (e) {
      return null;
    }
  }

  // التحقق من وجود منتج بنفس الكود
  bool isProductExists(String itemCode) {
    return transferLines.any((line) => line.itemCode == itemCode);
  }

  // تصدير البيانات
  Map<String, dynamic> exportProductData() {
    return {
      'transferId': transferId.value,
      'products': filteredLines.map((line) => line.toJson()).toList(),
      'stats': getProductStats(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // فلترة المنتجات بناءً على المخزون
  void filterByInventory(String filterType) {
    List<TransferLine> lines = List.from(transferLines);

    switch (filterType) {
      case 'available':
        lines = lines.where((line) => (line.invQty ?? 0) > 0).toList();
        break;
      case 'low_stock':
        lines = lines.where((line) => (line.invQty ?? 0) > 0 && (line.invQty ?? 0) < 10).toList();
        break;
      case 'out_of_stock':
        lines = lines.where((line) => (line.invQty ?? 0) <= 0).toList();
        break;
      case 'high_value':
        lines = lines.where((line) => (line.lineTotal ?? 0) > 1000).toList();
        break;
      default:
        // عرض جميع المنتجات
        break;
    }

    filteredLines.value = lines;
  }

  // حساب إجمالي قيمة المنتجات المحددة
  double calculateSelectedProductsValue(List<TransferLine> selectedLines) {
    return selectedLines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
  }

  // التحقق من صحة بيانات المنتج
  bool validateProductData(Map<String, dynamic> productData) {
    if (productData['itemCode'] == null || productData['itemCode'].toString().trim().isEmpty) {
      Get.snackbar(
        'خطأ في البيانات',
        'كود المنتج مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (productData['quantity'] == null || productData['quantity'] <= 0) {
      Get.snackbar(
        'خطأ في البيانات',
        'الكمية يجب أن تكون أكبر من صفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (productData['price'] == null || productData['price'] < 0) {
      Get.snackbar(
        'خطأ في البيانات',
        'السعر يجب أن يكون أكبر من أو يساوي صفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // إحصائيات متقدمة
  Map<String, dynamic> getAdvancedStats() {
    if (filteredLines.isEmpty) {
      return {
        'averagePrice': 0.0,
        'averageQuantity': 0.0,
        'averageLineTotal': 0.0,
        'highestPrice': 0.0,
        'lowestPrice': 0.0,
        'totalValue': 0.0,
      };
    }

    List<double> prices =
        filteredLines.map((line) => line.price ?? 0.0).where((price) => price > 0).toList();

    List<double> quantities =
        filteredLines.map((line) => line.quantity ?? 0.0).where((qty) => qty > 0).toList();

    List<double> totals = filteredLines.map((line) => line.lineTotal ?? 0.0).toList();

    return {
      'averagePrice': prices.isNotEmpty ? prices.reduce((a, b) => a + b) / prices.length : 0.0,
      'averageQuantity':
          quantities.isNotEmpty ? quantities.reduce((a, b) => a + b) / quantities.length : 0.0,
      'averageLineTotal': totals.isNotEmpty ? totals.reduce((a, b) => a + b) / totals.length : 0.0,
      'highestPrice': prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0.0,
      'lowestPrice': prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0,
      'totalValue': totals.isNotEmpty ? totals.reduce((a, b) => a + b) : 0.0,
    };
  }

  // Helper methods للحصول على المعلومات
  int get totalProductsCount => transferLines.length;
  int get filteredProductsCount => filteredLines.length;
  bool get hasActiveSearch => searchQuery.value.isNotEmpty;
  bool get hasData => transferLines.isNotEmpty;
  bool get hasSelectedTransfer => transferId.value != null;

  // عدد التغييرات غير المحفوظة
  int get unsavedChangesCount => newLines.length + modifiedLines.length + deletedLines.length;

  // التحقق من إمكانية الحفظ
  bool get canSave => hasUnsavedChanges.value && !isSaving.value;

  // الحصول على أعلى قيمة منتج
  TransferLine? get highestValueProduct {
    if (filteredLines.isEmpty) return null;

    TransferLine highest = filteredLines.first;
    for (TransferLine line in filteredLines) {
      if ((line.lineTotal ?? 0) > (highest.lineTotal ?? 0)) {
        highest = line;
      }
    }
    return highest;
  }

  // الحصول على أعلى كمية منتج
  TransferLine? get highestQuantityProduct {
    if (filteredLines.isEmpty) return null;

    TransferLine highest = filteredLines.first;
    for (TransferLine line in filteredLines) {
      if ((line.quantity ?? 0) > (highest.quantity ?? 0)) {
        highest = line;
      }
    }
    return highest;
  }
}

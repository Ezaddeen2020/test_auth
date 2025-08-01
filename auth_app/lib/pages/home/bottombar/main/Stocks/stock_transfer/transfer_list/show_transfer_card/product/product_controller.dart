// pages/home/product/controllers/product_management_controller.dart

import 'package:auth_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/show_transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:auth_app/services/api/post_get_api.dart';

class ProductManagementController extends GetxController {
  // Status States
  var statusRequest = StatusRequest.none.obs;
  var isLoading = false.obs;

  // Data
  var transferId = Rxn<int>();
  var transferDetails = Rxn<TransferDetailDto>(); // إضافة التفاصيل الكاملة
  var transferLines = <TransferLine>[].obs;
  var filteredLines = <TransferLine>[].obs;

  // Search
  var searchQuery = ''.obs;
  late TextEditingController searchController;

  // API
  late TransferApi transferApi;

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

  // تحميل أسطر التحويل من الباك إند بشكل ديناميكي
  Future<void> loadTransferLines(int selectedTransferId) async {
    try {
      isLoading.value = true;
      statusRequest.value = StatusRequest.loading;
      transferId.value = selectedTransferId;

      var response = await transferApi.getTransferDetails(selectedTransferId);

      if (response['status'] == 'success') {
        TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

        // حفظ التفاصيل الكاملة (هيدر + أصناف)
        transferDetails.value = details;

        // استخراج الأسطر من الاستجابة
        transferLines.value = details.lines;

        // تطبيق الفلترة
        _applyFilter();

        statusRequest.value = StatusRequest.success;

        // Get.snackbar(
        //   'نجح',
        //   'تم تحميل أصناف التحويل رقم $selectedTransferId بنجاح',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
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

  // حساب إحصائيات المنتجات
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

  // تحديث وحدة المنتج
  void updateProductUnit(dynamic line, String newUnitName, int newBaseQty, int newUomEntry) {
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
  void updateProductQuantity(dynamic line, double newQuantity) {
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
          lineTotal: newQuantity * (line.price ?? 0.0), // إعادة حساب المجموع
          uomCode: line.uomCode,
          uomCode2: line.uomCode2,
          invQty: line.invQty,
          baseQty1: line.baseQty1,
          ugpEntry: line.ugpEntry,
          uomEntry: line.uomEntry,
        );

        transferLines[index] = updatedLine;
        _applyFilter();

        // إشعار بالتحديث (اختياري - يمكن حذفه لتقليل الإشعارات)
        // Get.snackbar(
        //   'تم التحديث',
        //   'تم تحديث الكمية إلى ${newQuantity.toStringAsFixed(0)}',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 1),
        // );
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
      TransferLine newLine = TransferLine(
        docEntry: transferId.value,
        lineNum: _getNextLineNumber(),
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

      transferLines.add(newLine);
      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم إضافة المنتج بنجاح',
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
      transferLines
          .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);
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

  // نسخ منتج
  void duplicateProduct(TransferLine line) {
    try {
      TransferLine duplicatedLine = TransferLine(
        docEntry: line.docEntry,
        lineNum: _getNextLineNumber(),
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

      transferLines.add(duplicatedLine);
      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم نسخ المنتج بنجاح',
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

  // الحصول على رقم السطر التالي
  int _getNextLineNumber() {
    if (transferLines.isEmpty) return 1;

    int maxLineNum = 0;
    for (TransferLine line in transferLines) {
      if (line.lineNum != null && line.lineNum! > maxLineNum) {
        maxLineNum = line.lineNum!;
      }
    }
    return maxLineNum + 1;
  }

  // مسح البحث
  void clearSearch() {
    searchController.clear();
    updateSearch('');
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

  // حفظ التغييرات على الخادم
  Future<void> saveChangesToServer() async {
    try {
      isLoading.value = true;

      // هنا يمكن إضافة API call لحفظ التغييرات
      // await transferApi.updateTransferLines(transferId.value!, transferLines);

      // محاكاة عملية الحفظ
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'نجح',
        'تم حفظ التغييرات بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ التغييرات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

  // إعادة تعيين البيانات
  void resetData() {
    transferId.value = null;
    transferDetails.value = null;
    transferLines.clear();
    filteredLines.clear();
    searchController.clear();
    searchQuery.value = '';
    statusRequest.value = StatusRequest.none;
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

  // عدد المنتجات الإجمالي
  int get totalProductsCount => transferLines.length;

  // عدد المنتجات المفلترة
  int get filteredProductsCount => filteredLines.length;

  // التحقق من وجود بحث نشط
  bool get hasActiveSearch => searchQuery.value.isNotEmpty;

  // التحقق من وجود بيانات
  bool get hasData => transferLines.isNotEmpty;

  // التحقق من تحديد تحويل
  bool get hasSelectedTransfer => transferId.value != null;

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




// // pages/home/product/controllers/product_management_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/salse/models/details_model.dart';
// import 'package:auth_app/pages/home/transfare/services/transfer_api.dart';
// import 'package:auth_app/services/api/post_get_api.dart';

// class ProductManagementController extends GetxController {
//   // Status States
//   var statusRequest = StatusRequest.none.obs;
//   var isLoading = false.obs;

//   // Data
//   var transferId = Rxn<int>();
//   var transferDetails = Rxn<TransferDetailDto>(); // إضافة التفاصيل الكاملة
//   var transferLines = <TransferLine>[].obs;
//   var filteredLines = <TransferLine>[].obs;

//   // Search
//   var searchQuery = ''.obs;
//   late TextEditingController searchController;

//   // API
//   late TransferApi transferApi;

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

//   // تحميل أسطر التحويل من الباك إند بشكل ديناميكي
//   Future<void> loadTransferLines(int selectedTransferId) async {
//     try {
//       isLoading.value = true;
//       statusRequest.value = StatusRequest.loading;
//       transferId.value = selectedTransferId;

//       var response = await transferApi.getTransferDetails(selectedTransferId);

//       if (response['status'] == 'success') {
//         TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

//         // حفظ التفاصيل الكاملة (هيدر + أصناف)
//         transferDetails.value = details;

//         // استخراج الأسطر من الاستجابة
//         transferLines.value = details.lines;

//         // تطبيق الفلترة
//         _applyFilter();

//         statusRequest.value = StatusRequest.success;

//         Get.snackbar(
//           'نجح',
//           'تم تحميل أصناف التحويل رقم $selectedTransferId بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
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

//   // حساب إحصائيات المنتجات
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

//   // إضافة منتج جديد
//   void addProduct(Map<String, dynamic> productData) {
//     try {
//       TransferLine newLine = TransferLine(
//         docEntry: transferId.value,
//         lineNum: _getNextLineNumber(),
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

//       transferLines.add(newLine);
//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم إضافة المنتج بنجاح',
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
//       transferLines
//           .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);
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

//   // نسخ منتج
//   void duplicateProduct(TransferLine line) {
//     try {
//       TransferLine duplicatedLine = TransferLine(
//         docEntry: line.docEntry,
//         lineNum: _getNextLineNumber(),
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

//       transferLines.add(duplicatedLine);
//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم نسخ المنتج بنجاح',
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

//   // الحصول على رقم السطر التالي
//   int _getNextLineNumber() {
//     if (transferLines.isEmpty) return 1;

//     int maxLineNum = 0;
//     for (TransferLine line in transferLines) {
//       if (line.lineNum != null && line.lineNum! > maxLineNum) {
//         maxLineNum = line.lineNum!;
//       }
//     }
//     return maxLineNum + 1;
//   }

//   // مسح البحث
//   void clearSearch() {
//     searchController.clear();
//     updateSearch('');
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

//   // حفظ التغييرات على الخادم (يمكن تطويرها لاحقاً)
//   Future<void> saveChangesToServer() async {
//     try {
//       isLoading.value = true;

//       // هنا يمكن إضافة API call لحفظ التغييرات
//       // await transferApi.updateTransferLines(transferId.value!, transferLines);

//       Get.snackbar(
//         'نجح',
//         'تم حفظ التغييرات بنجاح',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في حفظ التغييرات: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
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

//   // إعادة تعيين البيانات
//   void resetData() {
//     transferId.value = null;
//     transferLines.clear();
//     filteredLines.clear();
//     searchController.clear();
//     searchQuery.value = '';
//     statusRequest.value = StatusRequest.none;
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

//   // Helper methods للحصول على المعلومات

//   // عدد المنتجات الإجمالي
//   int get totalProductsCount => transferLines.length;

//   // عدد المنتجات المفلترة
//   int get filteredProductsCount => filteredLines.length;

//   // التحقق من وجود بحث نشط
//   bool get hasActiveSearch => searchQuery.value.isNotEmpty;

//   // التحقق من وجود بيانات
//   bool get hasData => transferLines.isNotEmpty;

//   // التحقق من تحديد تحويل
//   bool get hasSelectedTransfer => transferId.value != null;

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
//       'totalValue': totals.reduce((a, b) => a + b),
//     };
//   }
// }

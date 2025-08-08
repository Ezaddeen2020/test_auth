import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/services/stock_api.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockController extends GetxController {
  final StockApi stockApi = StockApi(PostGetPage());

  // المتغيرات التفاعلية
  var stockItems = <StockModel>[].obs;
  var isLoading = false.obs;
  var itemCodeController = TextEditingController();
  var hasSearched = false.obs;

  @override
  void onClose() {
    itemCodeController.dispose();
    super.onClose();
  }

  // // البحث عن المخزون
  Future<void> searchStock() async {
    String itemCode = itemCodeController.text.trim();

    if (itemCode.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الصنف',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    isLoading.value = true;
    EasyLoading.show(status: 'جاري البحث...');

    try {
      var response = await stockApi.getStockByItemCode(itemCode);

      if (response['status'] == 'success') {
        List<dynamic> data = response['data'] ?? [];
        stockItems.value = data.map((item) => StockModel.fromJson(item)).toList();
        hasSearched.value = true;

        if (stockItems.isEmpty) {
          Get.snackbar(
            'نتيجة البحث',
            'لا توجد بيانات مخزون لهذا الصنف',
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            icon: const Icon(Icons.info, color: Colors.white),
          );
        }
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'حدث خطأ أثناء البحث',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        stockItems.clear();
        hasSearched.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال بالخادم',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      stockItems.clear();
      hasSearched.value = false;
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  // مسح البحث
  void clearSearch() {
    itemCodeController.clear();
    stockItems.clear();
    hasSearched.value = false;
  }

  // حساب إجمالي المخزون
  double get totalStock {
    return stockItems.fold(0.0, (sum, item) => sum + item.totalOnHand);
  }

  // حساب متوسط السعر
  double get averagePrice {
    if (stockItems.isEmpty) return 0.0;
    double totalPrice = stockItems.fold(0.0, (sum, item) => sum + item.avgPrice);
    return totalPrice / stockItems.length;
  }
}



// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/services/stock_api.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// class StockController extends GetxController {
//   final StockApi stockApi = StockApi(PostGetPage());

//   // المتغيرات التفاعلية
//   var stockItems = <StockModel>[].obs;
//   var isLoading = false.obs;
//   var itemCodeController = TextEditingController();
//   var hasSearched = false.obs;

//   // متحكم الإلغاء
//   Completer<void>? _currentSearchCompleter;
//   bool _isCancelled = false;

//   @override
//   void onClose() {
//     // إلغاء أي عملية بحث جارية
//     cancelCurrentSearch();
//     itemCodeController.dispose();
//     super.onClose();
//   }

//   // إلغاء عملية البحث الحالية
//   void cancelCurrentSearch() {
//     if (_currentSearchCompleter != null && !_currentSearchCompleter!.isCompleted) {
//       _isCancelled = true;
//       _currentSearchCompleter!.complete();
//       isLoading.value = false;
//       EasyLoading.dismiss();
//     }
//     // تنظيف المتغيرات
//     _currentSearchCompleter = null;
//     _isCancelled = false;
//   }

//   // البحث عن المخزون
//   Future<void> searchStock() async {
//     String itemCode = itemCodeController.text.trim();
//     if (itemCode.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'يرجى إدخال رقم الصنف',
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error, color: Colors.white),
//       );
//       return;
//     }

//     // إلغاء أي عملية بحث سابقة
//     cancelCurrentSearch();

//     // بدء عملية بحث جديدة
//     _currentSearchCompleter = Completer<void>();
//     _isCancelled = false;

//     isLoading.value = true;
//     EasyLoading.show(status: 'جاري البحث...');

//     try {
//       // التحقق من الإلغاء قبل بدء API call
//       if (_isCancelled) return;

//       var response = await stockApi.getStockByItemCode(itemCode);

//       // التحقق من الإلغاء بعد الحصول على الاستجابة
//       if (_isCancelled) return;

//       if (response['status'] == 'success') {
//         List<dynamic> data = response['data'] ?? [];
//         stockItems.value = data.map((item) => StockModel.fromJson(item)).toList();
//         hasSearched.value = true;

//         if (stockItems.isEmpty) {
//           Get.snackbar(
//             'نتيجة البحث',
//             'لا توجد بيانات مخزون لهذا الصنف',
//             backgroundColor: Colors.orange.withOpacity(0.8),
//             colorText: Colors.white,
//             icon: const Icon(Icons.info, color: Colors.white),
//           );
//         }
//       } else {
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'حدث خطأ أثناء البحث',
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//         );
//         stockItems.clear();
//         hasSearched.value = false;
//       }
//     } catch (e) {
//       // التحقق من الإلغاء قبل عرض رسالة الخطأ
//       if (!_isCancelled) {
//         Get.snackbar(
//           'خطأ',
//           'حدث خطأ في الاتصال بالخادم',
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//         );
//         stockItems.clear();
//         hasSearched.value = false;
//       }
//     } finally {
//       // التحقق من وجود الـ completer وعدم اكتماله قبل استكماله
//       if (!_isCancelled) {
//         isLoading.value = false;
//         EasyLoading.dismiss();
//       }

//       // إنهاء الـ completer بأمان
//       if (_currentSearchCompleter != null && !_currentSearchCompleter!.isCompleted) {
//         _currentSearchCompleter!.complete();
//       }

//       // تنظيف المتغيرات
//       _currentSearchCompleter = null;
//       _isCancelled = false;
//     }
//   }

//   // مسح البحث
//   void clearSearch() {
//     // إلغاء أي عملية بحث جارية
//     cancelCurrentSearch();
//     itemCodeController.clear();
//     stockItems.clear();
//     hasSearched.value = false;
//   }

//   // حساب إجمالي المخزون
//   double get totalStock {
//     return stockItems.fold(0.0, (sum, item) => sum + item.totalOnHand);
//   }

//   // حساب متوسط السعر
//   double get averagePrice {
//     if (stockItems.isEmpty) return 0.0;
//     double totalPrice = stockItems.fold(0.0, (sum, item) => sum + item.avgPrice);
//     return totalPrice / stockItems.length;
//   }
// }

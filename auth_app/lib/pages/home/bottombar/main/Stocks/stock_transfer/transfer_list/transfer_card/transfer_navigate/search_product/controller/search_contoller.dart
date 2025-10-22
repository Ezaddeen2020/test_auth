// search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController1 extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedSearchType = 'name'.obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;
  final RxList<String> results = <String>[].obs;
  var hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    results.clear();
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    isSearching.value = true;

    // محاكاة عملية البحث
    await Future.delayed(const Duration(seconds: 1));

    isSearching.value = false;

    // هنا يمكنك إضافة منطق البحث الفعلي
    print('تم البحث عن: $query بنوع: ${getSearchTypeLabel()}');

    Get.snackbar(
      'نتائج البحث',
      'تم البحث عن: $query',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // void _showErrorSnackbar(String title, String message) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     backgroundColor: Colors.red.withOpacity(0.8),
  //     colorText: Colors.white,
  //     icon: const Icon(Icons.error, color: Colors.white),
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: const Duration(seconds: 3),
  //   );
  // }

  // Future<void> searchStock() async {
  //   String itemCode = searchController.text.trim();

  //   if (itemCode.isEmpty) {
  //     _showErrorSnackbar('خطأ', 'يرجى إدخال رقم الصنف');
  //     return;
  //   }

  //   // تجنب البحث المتكرر إذا كان نفس الرقم
  //   if (hasSearched.value && stockItems.isNotEmpty && stockItems.first.itemCode == itemCode) {
  //     return;
  //   }

  //   isLoading.value = true;
  //   EasyLoading.show(status: 'جاري البحث...');

  //   try {
  //     var response = await stockApi.getStockByItemCode(itemCode);

  //     if (response['status'] == 'success') {
  //       List<dynamic> data = response['data'] ?? [];
  //       stockItems.value = data.map((item) => StockModel.fromJson(item)).toList();
  //       hasSearched.value = true;

  //       if (stockItems.isEmpty) {
  //         _showWarningSnackbar('نتيجة البحث', 'لا توجد بيانات مخزون لهذا الصنف');
  //       } else {
  //         _showSuccessSnackbar('نجح البحث', 'تم العثور على ${stockItems.length} عنصر');
  //       }
  //     } else {
  //       _handleApiError(response['message'] ?? 'حدث خطأ أثناء البحث');
  //     }
  //   } catch (e) {
  //     print('Stock search error: $e'); // للتشخيص
  //     _handleNetworkError();
  //   } finally {
  //     isLoading.value = false;
  //     EasyLoading.dismiss();
  //   }
  // }

  String getSearchTypeLabel() {
    switch (selectedSearchType.value) {
      case 'name':
        return 'اسم الصنف';
      case 'barcode':
        return 'باركود';
      case 'number':
        return 'رقم الصنف';
      default:
        return 'غير محدد';
    }
  }

  void setSearchType(String type) {
    selectedSearchType.value = type;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SearchController extends GetxController {
//   final TextEditingController searchController = TextEditingController();

//   var selectedSearchType = 'name'.obs;
//   var isSearching = false.obs;
//   var results = <String>[].obs;

//   // المتغير لحفظ الرقم المدخل
//   var searchText = ''.obs;

//   void clearSearch() {
//     searchController.clear();
//     searchText.value = '';
//     selectedSearchType.value = 'name';
//     isSearching.value = false;
//     results.clear();
//     update();
//   }

//   void performSearch(String query) {
//     if (query.isEmpty) return;

//     isSearching.value = true;

//     // طباعة القيمة على نافذة الأوامر
//     print('تم البحث عن: $query');

//     // لمحاكاة عملية البحث يمكن وضع تأخير قصير
//     Future.delayed(const Duration(seconds: 1), () {
//       isSearching.value = false;
//     });
//   }

//   String getSearchTypeLabel() {
//     switch (selectedSearchType.value) {
//       case 'name':
//         return 'اسم الصنف';
//       case 'barcode':
//         return 'باركود';
//       case 'number':
//         return 'رقم الصنف';
//       default:
//         return 'غير محدد';
//     }
//   }

//   void setSearchType(String type) {
//     selectedSearchType.value = type;
//   }
// }


//   // @override
//   // void onInit() {
//   //   super.onInit();
//   //   searchController.addListener(() {
//   //     update(); // عشان الـ suffixIcon يتحدث
//   //   });
//   // }

//   // void performSearch(String query) {
//   //   if (query.trim().isEmpty) return;

//   //   isSearching.value = true;

//   //   Future.delayed(const Duration(seconds: 1), () {
//   //     isSearching.value = false;

//   //     // محاكاة نتائج
//   //     results.assignAll([
//   //       "نتيجة 1 للـ $query",
//   //       "نتيجة 2 للـ $query",
//   //       "نتيجة 3 للـ $query",
//   //     ]);
//   //   });
//   // }


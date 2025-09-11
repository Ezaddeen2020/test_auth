// search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController1 extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedSearchType = 'name'.obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;
  final RxList<String> results = <String>[].obs;

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


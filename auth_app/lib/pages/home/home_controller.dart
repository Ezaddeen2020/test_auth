// lib/pages/home/controllers/home_controller.dart
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class HomeController extends GetxController {
//   // المتغير الذي يحفظ رقم الصفحة الحالية في البوتوم بار
//   RxInt pageIndex = 0.obs;

//   // متحكم PageView
//   late PageController pageController;

//   @override
//   void onInit() {
//     super.onInit();
//     pageController = PageController(initialPage: pageIndex.value);
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }

//   // استدعاؤها عند تغيير الصفحة من البوتوم بار أو عند السحب
//   void onPageChanged(int index) {
//     pageIndex.value = index;
//   }
// }

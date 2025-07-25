import 'package:auth_app/pages/home/salse/categories.dart';
import 'package:auth_app/pages/home/salse/invice_page.dart';
import 'package:auth_app/pages/home/salse/main/purchase_controller.dart';
import 'package:auth_app/pages/home/salse/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class PurchaseOrderPage extends StatelessWidget {
  PurchaseOrderPage({super.key});

  final PurchaseController controller = Get.find<PurchaseController>();
  final PageController pageController = PageController(initialPage: 0);

  final List<Widget> pages = [const InvoicePage(), const SearchPage(), const CategoriesPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          controller.changeTab(index);
        },
        children: pages,
      ),
      bottomNavigationBar: Obx(() {
        return CurvedNavigationBar(
          index: controller.selectedIndex.value,
          items: const [
            Icon(Icons.receipt, size: 30, color: Colors.white),
            Icon(Icons.search, size: 30, color: Colors.white),
            Icon(Icons.inventory, size: 30, color: Colors.white),
          ],
          height: 60,
          backgroundColor: Colors.grey[200]!,
          color: Colors.blue.shade900,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            controller.changeTab(index);
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      }),
    );
  }
}


// import 'package:auth_app/pages/home/bottombar/mainpage.dart';
// import 'package:auth_app/pages/home/bottombar/operation_tab.dart';
// import 'package:auth_app/pages/home/bottombar/setting.dart';
// import 'package:auth_app/pages/home/home_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// class PurchaseOrderPage extends StatelessWidget {
//   PurchaseOrderPage({super.key});

//   // final HomeController controller = Get.put(HomeController());

//   // 👇 أضف initialPage: 1 لجعل MainTab تظهر أولًا
//   final PageController pageController = PageController(initialPage: 1);

//   final List<Widget> pages = [
//     MainTab(),
//     const OperationsTab(),
//     const SettingsTab(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: PageView(
//         controller: pageController,
//         onPageChanged: (index) {
//           controller.changeTab(index);
//         },
//         children: pages,
//       ),
//       bottomNavigationBar: Obx(() {
//         return CurvedNavigationBar(
//           index: controller.selectedIndex.value,
//           items: const [
//             Icon(Icons.business_center, size: 30, color: Colors.white),
//             Icon(Icons.home, size: 30, color: Colors.white),
//             Icon(Icons.settings, size: 30, color: Colors.white),
//           ],
//           height: 60,
//           backgroundColor: Colors.grey[200]!,
//           color: Colors.blue.shade900,
//           animationDuration: const Duration(milliseconds: 300),
//           onTap: (index) {
//             controller.changeTab(index);
//             pageController.jumpToPage(index);
//           },
//         );
//       }),
//     );
//   }
// }

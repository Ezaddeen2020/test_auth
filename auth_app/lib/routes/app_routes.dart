// // lib/routes/app_routes.dart (Updated)

// import 'package:auth_app/pages/configration/screens/configration_page.dart';
// import 'package:auth_app/pages/home/home_page.dart';
// import 'package:auth_app/pages/home/salse/main/purchase_order.dart';
// import 'package:auth_app/pages/home/transfare/decoment_transfer.dart';
// import 'package:auth_app/pages/home/transfare/screens/transfer_screen.dart';
// import 'package:auth_app/pages/home/transfare/screens/transfer_details_screen.dart';
// import 'package:auth_app/pages/stocks/screens/stock_page.dart';

// import 'package:get/get.dart';
// import 'package:auth_app/pages/auth/screens/login_page.dart';
// import 'package:auth_app/pages/auth/screens/signup_page.dart';

// class AppRoutes {
//   static const login = '/login';
//   static const signup = '/signup';
//   static const home = '/home';
//   static const configuration = '/configuration';
//   static const stock = '/stock';
//   static const purchase = '/purchase';

//   // مسارات التحويلات
//   static const transfer = '/transfer';
//   static const transferDetails = '/transfer-details';
//   static const createTransfer = '/create-transfer';
//   static const editTransfer = '/edit-transfer';

//   static final routes = [
//     // المسارات الأساسية
//     GetPage(
//       name: login,
//       page: () => LoginPage(),
//       transition: Transition.fadeIn,
//     ),
//     GetPage(
//       name: signup,
//       page: () => SignUpPage(),
//       transition: Transition.fadeIn,
//     ),
//     GetPage(
//       name: home,
//       page: () => HomePage(),
//       transition: Transition.fadeIn,
//     ),
//     GetPage(
//       name: configuration,
//       page: () => const ConfigrationPage(),
//       transition: Transition.rightToLeft,
//     ),
//     GetPage(
//       name: stock,
//       page: () => const StockPage(),
//       transition: Transition.rightToLeft,
//     ),
//     GetPage(
//       name: purchase,
//       page: () => PurchaseOrderPage(),
//       transition: Transition.rightToLeft,
//     ),

//     // مسارات التحويلات
//     GetPage(
//       name: transfer,
//       page: () => const TransferScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//     GetPage(
//       name: transferDetails,
//       page: () => TransferDetailsScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//     GetPage(
//       name: createTransfer,
//       page: () => const TransferScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//     GetPage(
//       name: editTransfer,
//       page: () => const TransferScreen(),
//       transition: Transition.rightToLeft,
//       transitionDuration: const Duration(milliseconds: 300),
//     ),
//   ];

//   // دوال مساعدة للتنقل
//   static void goToTransfersList() => Get.toNamed(transfer);
//   static void goToTransferDetails(int transferId) => Get.toNamed(transferDetails, arguments: transferId);
//   static void goToCreateTransfer() => Get.toNamed(createTransfer);
//   static void goToEditTransfer(int transferId) => Get.toNamed(editTransfer, arguments: {'transferId': transferId});
// }

// lib/routes/app_routes.dart (Updated)

import 'package:auth_app/pages/configration/screens/configration_page.dart';
import 'package:auth_app/pages/home/home_page.dart';
import 'package:auth_app/pages/home/salse/main/purchase_order.dart';
import 'package:auth_app/pages/home/transfare/screens/transfer_screen.dart';
import 'package:auth_app/pages/stocks/screens/stock_page.dart';

import 'package:get/get.dart';
import 'package:auth_app/pages/auth/screens/login_page.dart';
import 'package:auth_app/pages/auth/screens/signup_page.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const configuration = '/configuration';
  static const stock = '/stock';
  static const purchase = '/purchase';
  static const transfer = '/transfer';

  static final routes = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignUpPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: configuration, page: () => const ConfigrationPage()),
    GetPage(name: stock, page: () => const StockPage()),
    GetPage(name: purchase, page: () => PurchaseOrderPage()),
    GetPage(name: transfer, page: () => const TransferScreen()),
  ];
}

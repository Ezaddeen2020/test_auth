import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/pages/configration/screens/configration_page.dart';
import 'package:auth_app/pages/home/home_controller.dart';
import 'package:auth_app/pages/home/home_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invice_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_order.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/transfer_screen.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/screens/stock_page.dart';
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
  static const search = '/search';
  static const invoice = '/invoice';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: signup,
      page: () => SignUpPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: home,
      page: () => HomePage(),
      binding: BindingsBuilder(() {
        // تأكد من تهيئة جميع Controllers المطلوبة للصفحة الرئيسية
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => AuthController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: configuration,
      page: () => const ConfigrationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: stock,
      page: () => const StockPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: purchase,
      page: () => const TransferDetailsNavigationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: transfer,
      page: () => const TransferScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: search,
      page: () => const SearchPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: invoice,
      page: () => const InvoicePage(),
      transition: Transition.rightToLeft,
    ),
  ];

  // دالة للتحقق من صحة المسار
  static bool isValidRoute(String route) {
    return routes.any((page) => page.name == route);
  }

  // دالة للحصول على المسار الافتراضي
  static String getInitialRoute() {
    // يمكنك إضافة منطق للتحقق من حالة المستخدم هنا
    return login;
  }
}

// import 'package:auth_app/pages/configration/screens/configration_page.dart';
// import 'package:auth_app/pages/home/home_page.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invice_page.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_order.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/transfer_screen.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/screens/stock_page.dart';

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
//   static const transfer = '/transfer';
//   static const search = '/search';
//   static const invoice = '/invoice';

//   static final routes = [
//     GetPage(name: login, page: () => LoginPage()),
//     GetPage(name: signup, page: () => SignUpPage()),
//     GetPage(name: home, page: () => HomePage()),
//     GetPage(name: configuration, page: () => const ConfigrationPage()),
//     GetPage(name: stock, page: () => const StockPage()),
//     GetPage(name: purchase, page: () => const TransferDetailsNavigationScreen()),
//     GetPage(name: transfer, page: () => const TransferScreen()),
//     GetPage(name: search, page: () => const SearchPage()),
//     GetPage(name: invoice, page: () => const InvoicePage()),
//   ];
// }

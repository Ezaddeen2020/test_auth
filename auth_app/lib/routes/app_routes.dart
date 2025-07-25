// lib/routes/app_routes.dart (Updated)

import 'package:auth_app/pages/configration/screens/configration_page.dart';
import 'package:auth_app/pages/home/home_page.dart';
import 'package:auth_app/pages/home/salse/purchase_order.dart';
import 'package:auth_app/pages/home/transfare/decoment_transfer.dart';
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
    GetPage(name: purchase, page: () => const PurchaseOrderPage()),
    GetPage(name: transfer, page: () => DecomentTransfer()),
  ];
}

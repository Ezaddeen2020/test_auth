// lib/routes/app_routes.dart (Updated)

import 'package:auth_app/pages/configration/screen/configration_page.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/auth/screens/login_page.dart';
import 'package:auth_app/pages/auth/screens/signup_page.dart';
import 'package:auth_app/pages/home/home_page.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const configuration = '/configuration';

  static final routes = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignUpPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: configuration, page: () => const ConfigurationPage()),
  ];
}

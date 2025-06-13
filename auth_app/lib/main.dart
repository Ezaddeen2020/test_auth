// lib/main.dart

import 'package:auth_app/binding/initial_binding.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.initPref();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      initialRoute: _getInitialRoute(),
      initialBinding: InitialBinding(),
      getPages: AppRoutes.routes,
      builder: EasyLoading.init(),
    );
  }

  String _getInitialRoute() {
    // التحقق من حالة التكوين أولاً
    bool isConfigured = Preferences.getBoolean('configuration_saved');
    String printerMac = Preferences.getString('printer_mac_address');
    String deviceName = Preferences.getString('device_name');

    // إذا لم يتم التكوين بعد، انتقل إلى صفحة التكوين
    if (!isConfigured || printerMac.isEmpty || deviceName.isEmpty) {
      return AppRoutes.configuration;
    }

    // إذا تم التكوين، تحقق من حالة تسجيل الدخول
    bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    String savedToken = Preferences.getString('auth_token');

    if (isLoggedIn && savedToken.isNotEmpty) {
      return AppRoutes.home;
    }

    // إذا تم التكوين ولكن لم يتم تسجيل الدخول، انتقل إلى صفحة تسجيل الدخول
    return AppRoutes.login;
  }
}

// // lib/main.dart

// import 'package:auth_app/binding/initial_binding.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/routes/app_routes.dart'; // <-- استيراد ملف التوجيه
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Preferences.initPref();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Auth App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Cairo',
//       ),
//       initialRoute: _getInitialRoute(),
//       initialBinding: InitialBinding(),
//       getPages: AppRoutes.routes, // <-- استخدم routes من AppRoutes
//       builder: EasyLoading.init(),
//     );
//   }

//   String _getInitialRoute() {
//     bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
//     String savedToken = Preferences.getString('auth_token');

//     if (isLoggedIn && savedToken.isNotEmpty) {
//       return AppRoutes.home;
//     }
//     return AppRoutes.configuration;
//   }
// }

import 'package:auth_app/binding/initial_binding.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/routes/app_routes.dart';
import 'package:auth_app/check_internet/internet_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'dart:developer'; // إضافة للتسجيل

void main() async {
  // إضافة معالج الأخطاء العام
  FlutterError.onError = (FlutterErrorDetails details) {
    log('Flutter Error: ${details.exception}');
    log('Stack trace: ${details.stack}');
  };

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Preferences.initPref();
    log('✅ Preferences initialized successfully');
  } catch (e) {
    log('❌ Error initializing preferences: $e');
  }

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

      // معالج المسارات غير المعروفة
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => _buildErrorPage('الصفحة المطلوبة غير موجودة'),
      ),

      // تطبيق EasyLoading و Internet Status Overlay
      builder: (context, child) {
        try {
          // تطبيق EasyLoading أولاً
          child = EasyLoading.init()(context, child);

          // ثم تطبيق الـ Internet Overlay
          return Stack(
            children: [
              child,
              const InternetStatusOverlay(),
            ],
          );
        } catch (e) {
          log('❌ Error in app builder: $e');
          return _buildErrorPage('خطأ في تحميل التطبيق');
        }
      },

      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  String _getInitialRoute() {
    try {
      bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
      String savedToken = Preferences.getString('auth_token');

      log('Initial route check - isLoggedIn: $isLoggedIn, hasToken: ${savedToken.isNotEmpty}');

      // تبسيط المنطق - فقط في حالة وجود token صالح
      if (isLoggedIn && savedToken.isNotEmpty && savedToken != 'null') {
        return AppRoutes.home;
      }

      return AppRoutes.login;
    } catch (e) {
      log('Error getting initial route: $e');
      return AppRoutes.login;
    }
  }

  // دالة مساعدة لبناء صفحة خطأ
  static Widget _buildErrorPage(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  try {
                    Get.offAllNamed(AppRoutes.login);
                  } catch (e) {
                    log('Error navigating to login: $e');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة تحميل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:auth_app/binding/initial_binding.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/routes/app_routes.dart';
// import 'package:auth_app/check_internet/internet_status_banner.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
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
//       initialBinding: InitialBinding(), // ⬅️ يحتوي على InternetConnectionController
//       getPages: AppRoutes.routes,

//       // ⬅️ تطبيق Internet Status Overlay مباشرة
//       builder: (context, child) {
//         // تطبيق EasyLoading أولاً
//         child = EasyLoading.init()(context, child);

//         // ثم تطبيق الـ Internet Overlay مباشرة
//         return Stack(
//           children: [
//             child,
//             const InternetStatusOverlay(), // ⬅️ مباشرة بدون wrapper
//           ],
//         );
//       },

//       locale: const Locale('ar'),
//       fallbackLocale: const Locale('ar'),
//       supportedLocales: const [
//         Locale('ar', ''),
//         Locale('en', ''),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//     );
//   }

//   String _getInitialRoute() {
//     bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
//     String savedToken = Preferences.getString('auth_token');

//     if (isLoggedIn && savedToken.isNotEmpty) {
//       return AppRoutes.home;
//     }

//     return AppRoutes.login;
//   }
// }

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/pages/auth/screens/login_page.dart';
import 'package:auth_app/pages/home/home_page.dart'; // تأكد من وجود هذه الصفحة
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة SharedPreferences
  await Preferences.initPref();

  // تهيئة خدمات Get
  _initializeServices();

  runApp(MyApp());

  // تكوين EasyLoading
  _configureEasyLoading();
}

void _initializeServices() {
  // تهيئة PostGetPage
  Get.put(PostGetPage(), permanent: true);
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,

      // إعداد الـ Routes
      initialRoute: _getInitialRoute(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()), // تأكد من إنشاء هذه الصفحة
      ],

      // إضافة EasyLoading
      builder: EasyLoading.init(),

      // إعداد اللغة العربية
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),

      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // إذا كان لديك خط عربي
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  String _getInitialRoute() {
    // التحقق من حالة تسجيل الدخول
    bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    String? token = Preferences.getString('auth_token');

    if (isLoggedIn && token.isNotEmpty) {
      return '/home';
    } else {
      return '/login';
    }
  }
}

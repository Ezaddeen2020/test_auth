// // lib/main.dart
// import 'package:auth_app/binding/initial_binding.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/midle_ware/auth_middleware.dart';
// import 'package:auth_app/views/pages/home_page.dart';
// import 'package:auth_app/views/pages/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'views/pages/login_page.dart';
// import 'views/pages/signup_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // تهيئة SharedPreferences
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
//       builder: EasyLoading.init(),

//       // إعداد المسارات
//       initialRoute: '/splash',
//       getPages: [
//         GetPage(
//           name: '/splash',
//           page: () => const SplashScreen(),
//           binding: AuthBinding(),
//         ),
//         GetPage(
//           name: '/login',
//           page: () => LoginPage(),
//           binding: AuthBinding(),
//         ),
//         GetPage(
//           name: '/signup',
//           page: () => SignUpPage(),
//           binding: AuthBinding(),
//         ),
//         GetPage(
//           name: '/home',
//           page: () => HomePage(),
//           middlewares: [AuthMiddleware()],
//         ),
//       ],

//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Arial', // يمكنك تغيير الخط إلى خط عربي
//       ),
//     );
//   }
// }

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/views/pages/login_page.dart';
import 'package:auth_app/views/pages/home_page.dart'; // تأكد من وجود هذه الصفحة
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

// lib/main.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/controllers/auth_controller.dart';
// import 'package:auth_app/views/pages/login_page.dart';
// import 'package:auth_app/views/pages/signup_page.dart';
// import 'package:auth_app/views/pages/home_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // تهيئة SharedPreferences
//   await Preferences.initPref();
  
//   // تسجيل الخدمات في GetX
//   Get.put(PostGetPage());
  
//   runApp(MyApp());
  
//   // إعداد EasyLoading
//   configLoading();
// }

// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..loadingStyle = EasyLoadingStyle.dark
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.yellow
//     ..backgroundColor = Colors.green
//     ..indicatorColor = Colors.yellow
//     ..textColor = Colors.yellow
//     ..maskColor = Colors.blue.withOpacity(0.5)
//     ..userInteractions = true
//     ..dismissOnTap = false;
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Auth App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Cairo', // تأكد من إضافة خط عربي
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(fontSize: 16),
//           bodyMedium: TextStyle(fontSize: 14),
//         ),
//       ),
//       // تحديد الصفحة الأولى بناءً على حالة تسجيل الدخول
//       home: _getInitialPage(),
//       getPages: [
//         GetPage(name: '/login', page: () => LoginPage()),
//         GetPage(name: '/signup', page: () => SignUpPage()),
//         GetPage(name: '/home', page: () => HomePage()),
//       ],
//       builder: EasyLoading.init(),
//     );
//   }

//   Widget _getInitialPage() {
//     bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
//     return isLoggedIn ? HomePage() : LoginPage();
//   }
// }

// // lib/views/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/controllers/auth_controller.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/models/user_model.dart';

// class HomePage extends StatelessWidget {
//   final AuthController authController = Get.put(AuthController());

//   @override
//   Widget build(BuildContext context) {
//     UserModel? user = Preferences.getDataUser();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الصفحة الرئيسية'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             onPressed: () => _showLogoutDialog(context),
//             icon: const Icon(Icons.logout),
//             tooltip: 'تسجيل الخروج',
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // أيقونة الترحيب
//               Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.home,
//                   size: 50,
//                   color: Colors.green,
//                 ),
//               ),
              
//               const SizedBox(height: 30),
              
//               // رسالة الترحيب
//               Text(
//                 'مرحباً، ${user?.getDisplayName() ?? 'مستخدم'}!',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               const SizedBox(height: 16),
              
//               Text(
//                 'تم تسجيل الدخول بنجاح',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
              
//               const SizedBox(height: 40),
              
//               // معلومات المستخدم
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'معلومات الحساب:',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _buildInfoRow('الاسم:', user?.name ?? 'غير محدد'),
//                       _buildInfoRow('البريد الإلكتروني:', user?.email ?? 'غير محدد'),
//                       _buildInfoRow(
//                         'حالة التحقق:', 
//                         user?.isEmailVerified == true ? 'محقق' : 'غير محقق'
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 40),
              
//               // زر تسجيل الخروج
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => _showLogoutDialog(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'تسجيل الخروج',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تسجيل الخروج'),
//         content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               authController.logout();
//             },
//             child: const Text(
//               'تسجيل الخروج',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'views/pages/login_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Auth App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Arial', // Use Arabic-compatible font
//       ),
//       home: LoginPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

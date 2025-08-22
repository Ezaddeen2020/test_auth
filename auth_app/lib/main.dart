import 'package:auth_app/binding/initial_binding.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/routes/app_routes.dart';
import 'package:auth_app/check_internet/internet_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      initialBinding: InitialBinding(), // ⬅️ يحتوي على InternetConnectionController
      getPages: AppRoutes.routes,

      // ⬅️ تطبيق Internet Status Overlay مباشرة
      builder: (context, child) {
        // تطبيق EasyLoading أولاً
        child = EasyLoading.init()(context, child);

        // ثم تطبيق الـ Internet Overlay مباشرة
        return Stack(
          children: [
            child,
            const InternetStatusOverlay(), // ⬅️ مباشرة بدون wrapper
          ],
        );
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
    bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    String savedToken = Preferences.getString('auth_token');

    if (isLoggedIn && savedToken.isNotEmpty) {
      return AppRoutes.home;
    }

    return AppRoutes.login;
  }
}

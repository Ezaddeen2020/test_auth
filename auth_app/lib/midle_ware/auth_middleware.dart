import 'package:auth_app/classes/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLogin = Preferences.getBoolean(Preferences.isLogin);
    // return isLogin ? null : const RouteSettings(name: '/login');
    return isLogin ? null : const RouteSettings(name: '/configuration');
  }
}

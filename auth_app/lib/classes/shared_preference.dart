// ignore_for_file: file_names

import 'dart:convert';

import 'package:auth_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String isLogin = "isLogin";
  static const String userData = 'userData';
  static const user = "user";
  static const isCheckEmail = "isCheckEmail";
  static const userId = "userID";
  static const email = "email";
  static const password = "password";
  static const token = "token";

  static late SharedPreferences pref;

  static initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  static bool getBoolean(String key) {
    return pref.getBool(key) ?? false;
  }

  static Future<void> setBoolean(String key, bool value) async {
    await pref.setBool(key, value);
  }

  static String getString(String key) {
    return pref.getString(key) ?? "";
  }

  static Future<void> setString(String key, String value) async {
    await pref.setString(key, value);
  }

  static Future<void> setListString(String key, List<String>? value) async {
    await pref.setStringList(key, value ?? []);
  }

  static List<String> getListString(String key) {
    return pref.getStringList(key) ?? [];
  }

  static int getInt(String key) {
    return pref.getInt(key) ?? 0;
  }

  static Future<void> setInt(String key, int value) async {
    await pref.setInt(key, value);
  }

  static Future<void> clearSharPreference() async {
    await pref.clear();
  }

  static Future<void> clearKeyData(String key) async {
    await pref.remove(key);
  }

  static Future<void> setDataUser(UserModel userModel) async {
    var userEncode = jsonEncode(userModel.toJson());
    await pref.setString(user, userEncode);
  }

  static Future<bool> removeString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  static UserModel? getDataUser() {
    var data = pref.getString(user);
    if (data != null && data.isNotEmpty) {
      var userDecode = jsonDecode(data);
      UserModel userModel = UserModel.fromJson(userDecode);

      return userModel;
    } else {
      return null;
    }
  }
}


// classes/shared_preference.dart - إضافة هذه الطرق إلى الكلاس الموجود
// class Preferences {
//   static const String isLogin = 'isLogin';
//   static const String userData = 'userData';
  
//   // إضافة طرق جديدة لحفظ واستلام String
//   static Future<bool> setString(String key, String value) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(key, value);
//   }
  
//   static Future<String?> getString(String key) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }
  
//   static Future<bool> removeString(String key) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.remove(key);
//   }
  
//   // الطرق الموجودة (تأكد من وجودها)
//   static Future<bool> setBoolean(String key, bool value) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setBool(key, value);
//   }
  
//   static Future<bool?> getBoolean(String key) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(key);
//   }
  
//   static Future<bool> setDataUser(UserModel user) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(userData, jsonEncode(user.toJson()));
//   }
  
//   static UserModel? getDataUser() {
//     // تنفيذ الطريقة حسب الكلاس الموجود لديك
//     // هذا مثال عام
//     return null;
//   }
// }
import 'dart:developer';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/auth/services/auth_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../services/api/post_get_api.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  final PostGetPage postGetPage = PostGetPage();
  late final AuthApi authApi;
  StatusRequest statusRequest = StatusRequest.none;
  String? authToken;

  @override
  void onInit() {
    super.onInit();
    authApi = AuthApi(postGetPage);
    checkExistingAuth();
  }

  void checkExistingAuth() {
    try {
      bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
      String? savedToken = Preferences.getString('auth_token');

      if (isLoggedIn && savedToken != null && savedToken.isNotEmpty) {
        authToken = savedToken;
        log('Found saved auth token: $authToken');
        // إزالة التنقل التلقائي من هنا - يتم التعامل معه في main.dart
      }
    } catch (e) {
      log('Error checking existing auth: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  UserModel? getCurrentUser() {
    try {
      return Preferences.getDataUser();
    } catch (e) {
      log('Error getting current user: $e');
      return null;
    }
  }

  Future<void> login() async {
    // منع الضغط المتعدد
    if (isLoading.value) {
      log('Login already in progress');
      return;
    }

    if (loginFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        statusRequest = StatusRequest.loading;

        UserModel userModel = UserModel(
          name: usernameController.text.trim(),
          password: passwordController.text,
        );

        EasyLoading.show(status: 'جاري تسجيل الدخول...');

        final res = await authApi.postlogin(userModel);
        statusRequest = handleResult(res);

        log('Login response: $res');

        if (statusRequest == StatusRequest.success &&
            res['data'] != null &&
            res['data']['token'] != null) {
          authToken = res['data']['token'];

          // حفظ البيانات
          await Preferences.setBoolean(Preferences.isLogin, true);
          await Preferences.setString('auth_token', authToken!);

          UserModel loggedUser = UserModel(
            name: usernameController.text.trim(),
            token: authToken,
          );

          await Preferences.setDataUser(loggedUser);

          log("تم تسجيل الدخول بنجاح مع Token: $authToken");

          // إغلاق التحميل
          EasyLoading.dismiss();

          // اختبار API
          await testApiWithToken();

          // التنقل المباشر
          Get.offAllNamed('/home');

          // رسالة النجاح
          Get.showSnackbar(const GetSnackBar(
            title: 'نجح',
            message: 'تم تسجيل الدخول بنجاح',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
        } else {
          EasyLoading.dismiss();
          throw Exception(res['message'] ?? 'فشل في تسجيل الدخول');
        }
      } catch (e) {
        log('Login Error: $e');
        EasyLoading.dismiss();

        Get.showSnackbar(GetSnackBar(
          title: 'خطأ',
          message: 'اسم المستخدم أو كلمة المرور غير صحيحة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ));
      } finally {
        isLoading.value = false;
        statusRequest = StatusRequest.none;
      }
    }
  }

  Future<void> testApiWithToken() async {
    if (authToken == null) return;

    try {
      log('Testing API with token...');
      final result = await postGetPage.getDataWithToken(ApiServices.testApi, authToken!);

      result.fold(
        (failure) => log('API Test Failed: $failure'),
        (data) {
          log('API Test Success: $data');
        },
      );
    } catch (e) {
      log('API Test Error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await Preferences.setBoolean(Preferences.isLogin, false);
      await Preferences.removeString('auth_token');
      authToken = null;
      clearForm();

      Get.snackbar(
        'تم',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      log('Logout Error: $e');
    }
  }

  void clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

// import 'dart:developer';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/functions/handling_data.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/auth/services/auth_api.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../../../services/api/post_get_api.dart';

// class AuthController extends GetxController {
//   var isLoading = false.obs;
//   var isPasswordVisible = false.obs;

//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

//   final PostGetPage postGetPage = PostGetPage();
//   late final AuthApi authApi;
//   StatusRequest statusRequest = StatusRequest.none;
//   String? authToken;

//   @override
//   void onInit() {
//     super.onInit();
//     authApi = AuthApi(postGetPage);
//     checkExistingAuth();
//   }

//   void checkExistingAuth() {
//     bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
//     String? savedToken = Preferences.getString('auth_token');

//     if (isLoggedIn && savedToken.isNotEmpty) {
//       authToken = savedToken;
//       log('Found saved auth token: $authToken');
//     }
//   }

//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   UserModel? getCurrentUser() {
//     return Preferences.getDataUser();
//   }

//   // تسجيل حساب جديد
//   Future<void> signUp() async {
//     if (registerFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       EasyLoading.show(status: 'جاري إنشاء الحساب...');

//       UserModel userModel = UserModel(
//         name: usernameController.text.trim(),
//         password: passwordController.text,
//       );

//       try {
//         final res = await authApi.postSignUp(userModel);
//         statusRequest = handleResult(res);

//         EasyLoading.dismiss();

//         if (statusRequest == StatusRequest.success && res['status'] == 'success') {
//           await Preferences.setBoolean(Preferences.isLogin, true);
//           Get.offAllNamed('/home');
//           log('تم إنشاء الحساب بنجاح');

//           Get.showSnackbar(const GetSnackBar(
//             title: 'نجح',
//             message: 'تم إنشاء الحساب بنجاح',
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ));
//         } else {
//           throw Exception(res['message'] ?? 'فشل في إنشاء الحساب');
//         }
//       } catch (e) {
//         EasyLoading.dismiss();
//         log('Signup Error: $e');

//         Get.showSnackbar(const GetSnackBar(
//           title: 'خطأ',
//           message: 'فشل في إنشاء الحساب',
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ));
//       }

//       isLoading.value = false;
//     }
//   }

//   Future<void> login() async {
//     if (loginFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       statusRequest = StatusRequest.loading;

//       UserModel userModel = UserModel(
//         name: usernameController.text.trim(),
//         password: passwordController.text,
//       );

//       EasyLoading.show(status: 'جاري تسجيل الدخول...');

//       try {
//         final res = await authApi.postlogin(userModel);
//         statusRequest = handleResult(res);

//         log('Login response: $res');

//         if (statusRequest == StatusRequest.success &&
//             res['data'] != null &&
//             res['data']['token'] != null) {
//           authToken = res['data']['token'];

//           await Preferences.setBoolean(Preferences.isLogin, true);
//           await Preferences.setString('auth_token', authToken!);

//           UserModel loggedUser = UserModel(
//             name: usernameController.text.trim(),
//             token: authToken,
//           );

//           await Preferences.setDataUser(loggedUser);

//           EasyLoading.dismiss();
//           await testApiWithToken();

//           Get.offAllNamed('/home');

//           Get.showSnackbar(const GetSnackBar(
//             title: 'نجح',
//             message: 'تم تسجيل الدخول بنجاح',
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ));

//           log("تم تسجيل الدخول بنجاح مع Token: $authToken");
//         } else {
//           throw Exception(res['message'] ?? 'فشل في تسجيل الدخول');
//         }
//       } catch (e) {
//         log('Login Error: $e');
//         EasyLoading.dismiss();

//         String errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
//         if (e.toString().contains('connection')) {
//           errorMessage = 'خطأ في الاتصال بالخادم';
//         }

//         Get.showSnackbar(GetSnackBar(
//           title: 'خطأ',
//           message: errorMessage,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ));
//       }

//       isLoading.value = false;
//     }
//   }

//   Future<void> testApiWithToken() async {
//     if (authToken == null) return;

//     try {
//       log('Testing API with token...');
//       final result = await postGetPage.getDataWithToken(ApiServices.testApi, authToken!);

//       result.fold(
//         (failure) => log('API Test Failed: $failure'),
//         (data) {
//           log('API Test Success: $data');
//           Get.showSnackbar(const GetSnackBar(
//             title: 'اختبار الـ API',
//             message: 'تم الاتصال بالـ API بنجاح',
//             backgroundColor: Colors.blue,
//             duration: Duration(seconds: 2),
//           ));
//         },
//       );
//     } catch (e) {
//       log('API Test Error: $e');
//     }
//   }

//   Future<void> logout() async {
//     await Preferences.setBoolean(Preferences.isLogin, false);
//     await Preferences.removeString('auth_token');
//     authToken = null;
//     clearForm();

//     Get.snackbar(
//       'تم',
//       'تم تسجيل الخروج بنجاح',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );

//     Get.offAllNamed('/login');
//   }

//   void clearForm() {
//     usernameController.clear();
//     passwordController.clear();
//   }
// }

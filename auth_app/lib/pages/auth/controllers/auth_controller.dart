// // lib/controllers/auth_controller.dart

// import 'dart:developer';

// import 'package:auth_app/classes/handling_data.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/classes/status_request.dart';
// import 'package:auth_app/services/auh/auth_api.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import '../models/user_model.dart';

// class AuthController extends GetxController {
//   // Observable variables
//   var isLoading = false.obs;
//   var isPasswordVisible = false.obs;
//   var isConfirmPasswordVisible = false.obs;
//   // var isLoggedIn = false.obs;

//   // Text controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   final AuthApi authApi = AuthApi(Get.find());
//   StatusRequest statusRequest = StatusRequest.none;
//   GlobalKey<FormState>? loginFormKey;

//   @override
//   void onInit() {
//     super.onInit();
//     // فقط تحديد حالة تسجيل الدخول بدون navigation
//     loginFormKey = GlobalKey<FormState>();
//   }

//   // Toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   void toggleConfirmPasswordVisibility() {
//     isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
//   }

//   UserModel? getCurrentUser() {
//     return Preferences.getDataUser();
//   }

//   // Login function
//   Future<void> login() async {
//     statusRequest = StatusRequest.loading;
//     if (loginFormKey!.currentState!.validate()) {
//       UserModel userModel = UserModel(
//         name: nameController.text,
//         // email: emailController.text,
//         password: passwordController.text,
//       );
//       EasyLoading.show(status: 'loading...');

//       final res = await authApi.postlogin(userModel);
//       statusRequest = handlingData(res);
//       if (statusRequest == StatusRequest.success && res['status'] == 'success') {
//         var model = UserModel.fromJson(res['user']);
//         model.password = passwordController.text;
//         Preferences.setBoolean(Preferences.isLogin, true);
//         Preferences.setDataUser(model);
//         Get.offAllNamed('/home');
//         log("Success Login");
//       } else {
//         log('Error Login');
//       }
//       EasyLoading.dismiss();
//       EasyLoading.dismiss();
//       Get.showSnackbar(const GetSnackBar(
//         title: 'خطأ',
//         message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ));
//     }
//   }

//   // Sign up function
//   Future<void> signUp() async {
//     if (signupFormKey.currentState!.validate()) {
//       EasyLoading.show(status: 'Signing up...');
//       UserModel userModel = UserModel(
//         name: nameController.text,
//         // email: emailController.text,
//         password: passwordController.text,
//       );

//       final res = await authApi.postSignUp(userModel);
//       statusRequest = handlingData(res);
//       EasyLoading.dismiss();

//       if (statusRequest == StatusRequest.success && res['status'] == 'success') {
//         Preferences.setBoolean(Preferences.isLogin, true);

//         Get.offAllNamed('/home');
//         log('Success Signup');
//       } else {
//         Get.snackbar('خطأ', 'فشل في إنشاء الحساب');
//         log('Error Signup');
//       }
//     }
//   }

//   // تسجيل الخروج
//   Future<void> logout() async {
//     Preferences.setBoolean(Preferences.isLogin, false);
//     Get.snackbar(
//       'تم',
//       'تم تسجيل الخروج بنجاح',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );
//   }

//   // Clear form data
//   void clearForm() {
//     emailController.clear();
//     passwordController.clear();
//     confirmPasswordController.clear();
//     nameController.clear();
//   }
// }

// pages/auth/controllers/auth_controller.dart
import 'dart:developer';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/auh/auth_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/api/post_get_api.dart';

class AuthController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // API Service
  final PostGetPage postGetPage = PostGetPage();
  late final AuthApi authApi;
  StatusRequest statusRequest = StatusRequest.none;

  // متغير لحفظ Token
  String? authToken;

  @override
  void onInit() {
    super.onInit();
    authApi = AuthApi(postGetPage);
    checkExistingAuth();
  }

  // فحص وجود token محفوظ
  void checkExistingAuth() {
    bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    String savedToken = Preferences.getString('auth_token');

    if (isLoggedIn && savedToken.isNotEmpty) {
      authToken = savedToken;
      log('Found saved auth token: $authToken');
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  UserModel? getCurrentUser() {
    return Preferences.getDataUser();
  }

  // دالة تسجيل الدخول المحسّنة
  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      statusRequest = StatusRequest.loading;

      // إنشاء نموذج المستخدم للتسجيل
      UserModel userModel = UserModel(
        name: usernameController.text.trim(),
        password: passwordController.text,
      );

      EasyLoading.show(status: 'جاري تسجيل الدخول...');

      try {
        final res = await authApi.postlogin(userModel);
        statusRequest = handlingData(res);

        log('Login response: $res');

        if (statusRequest == StatusRequest.success && res['token'] != null) {
          // حفظ Token من الاستجابة
          authToken = res['token'];

          // حفظ بيانات المستخدم في SharedPreferences
          await Preferences.setBoolean(Preferences.isLogin, true);
          await Preferences.setString('auth_token', authToken!);

          // إنشاء نموذج المستخدم مع Token
          UserModel loggedUser = UserModel(
            name: usernameController.text.trim(),
            token: authToken,
          );

          await Preferences.setDataUser(loggedUser);

          EasyLoading.dismiss();

          // اختبار الـ API
          await testApiWithToken();

          // الانتقال إلى الصفحة الرئيسية
          Get.offAllNamed('/home');

          // عرض رسالة نجاح
          Get.showSnackbar(const GetSnackBar(
            title: 'نجح',
            message: 'تم تسجيل الدخول بنجاح',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));

          log("تم تسجيل الدخول بنجاح مع Token: $authToken");
        } else {
          throw Exception(res['message'] ?? 'فشل في تسجيل الدخول');
        }
      } catch (e) {
        log('Login Error: $e');
        EasyLoading.dismiss();

        String errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
        if (e.toString().contains('connection')) {
          errorMessage = 'خطأ في الاتصال بالخادم';
        }

        Get.showSnackbar(GetSnackBar(
          title: 'خطأ',
          message: errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ));
      }

      isLoading.value = false;
    }
  }

  // اختبار الـ API مع الـ Token
  Future<void> testApiWithToken() async {
    if (authToken == null) return;

    try {
      log('Testing API with token...');

      final result = await postGetPage.getDataWithToken(ApiServices.testApi, authToken!);

      result.fold(
        (failure) {
          log('API Test Failed: $failure');
        },
        (data) {
          log('API Test Success: $data');
          Get.showSnackbar(const GetSnackBar(
            title: 'اختبار الـ API',
            message: 'تم الاتصال بالـ API بنجاح',
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ));
        },
      );
    } catch (e) {
      log('API Test Error: $e');
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await Preferences.setBoolean(Preferences.isLogin, false);
    await Preferences.removeString('auth_token');
    authToken = null;

    // مسح الحقول
    clearForm();

    Get.snackbar(
      'تم',
      'تم تسجيل الخروج بنجاح',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );

    // العودة إلى صفحة تسجيل الدخول
    Get.offAllNamed('/login');
  }

  // Clear form data
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

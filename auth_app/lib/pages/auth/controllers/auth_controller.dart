import 'dart:developer';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/auh/auth_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/api/post_get_api.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

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
    bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    String? savedToken = Preferences.getString('auth_token');

    if (isLoggedIn && savedToken.isNotEmpty) {
      authToken = savedToken;
      log('Found saved auth token: $authToken');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  UserModel? getCurrentUser() {
    return Preferences.getDataUser();
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      statusRequest = StatusRequest.loading;

      UserModel userModel = UserModel(
        name: usernameController.text.trim(),
        password: passwordController.text,
      );

      EasyLoading.show(status: 'جاري تسجيل الدخول...');

      try {
        final res = await authApi.postlogin(userModel);
        statusRequest = handleResult(res);

        log('Login response: $res');

        if (statusRequest == StatusRequest.success && res['token'] != null) {
          authToken = res['token'];

          await Preferences.setBoolean(Preferences.isLogin, true);
          await Preferences.setString('auth_token', authToken!);

          UserModel loggedUser = UserModel(
            name: usernameController.text.trim(),
            token: authToken,
          );

          await Preferences.setDataUser(loggedUser);

          EasyLoading.dismiss();
          await testApiWithToken();

          Get.offAllNamed('/home');

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

  Future<void> testApiWithToken() async {
    if (authToken == null) return;

    try {
      log('Testing API with token...');
      final result = await postGetPage.getDataWithToken(ApiServices.testApi, authToken!);

      result.fold(
        (failure) => log('API Test Failed: $failure'),
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

  Future<void> logout() async {
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
  }

  void clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    // usernameController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}















//   // Login function محدثة ومحسنة
//   Future<void> login() async {
//     if (loginFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       statusRequest = StatusRequest.loading;

//       // إنشاء نموذج المستخدم للتسجيل
//       UserModel userModel = UserModel(
//         name: nameController.text.trim(),
//         password: passwordController.text,
//       );

//       EasyLoading.show(status: 'جاري تسجيل الدخول...');

//       try {
//         final res = await authApi.postlogin(userModel);
//         statusRequest = handlingData(res);

//         log('Login response: $res');

//         if (statusRequest == StatusRequest.success && res['token'] != null) {
//           // حفظ Token من الاستجابة
//           authToken = res['token'];

//           // حفظ بيانات المستخدم في SharedPreferences
//           await Preferences.setBoolean(Preferences.isLogin, true);
//           await Preferences.setString('auth_token', authToken!);

//           // إنشاء نموذج المستخدم مع Token
//           UserModel loggedUser = UserModel(
//             name: nameController.text.trim(),
//             token: authToken,
//           );

//           await Preferences.setDataUser(loggedUser);

//           EasyLoading.dismiss();

//           // اختبار جميع APIs الجديدة
//           await testAllApis();

//           // الانتقال إلى الصفحة الرئيسية
//           Get.offAllNamed('/home');

//           // عرض رسالة نجاح
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

  // // اختبار جميع APIs الجديدة
  // Future<void> testAllApis() async {
  //   if (authToken != null) {
  //     try {
  //       // 1. اختبار API الأساسي
  //       log('=== اختبار API الأساسي ===');
  //       final testRes = await authApi.testApiWithToken(authToken!);
  //       log('Basic API Test Result: $testRes');

  //       // 2. اختبار echo endpoint مع رقم المنتج من الرابط
  //       log('=== اختبار Echo Endpoint ===');
  //       final echoRes = await authApi.testEchoEndpoint('6943090420065', authToken!);
  //       log('Echo API Test Result: $echoRes');

  //       // 3. اختبار جلب بيانات المخزون
  //       log('=== اختبار بيانات المخزون ===');
  //       final stockRes = await authApi.getStockInfo('6943090420065', authToken!);
  //       log('Stock API Test Result: $stockRes');

  //       // 4. اختبار جلب بيانات المبيعات
  //       log('=== اختبار بيانات المبيعات ===');
  //       final salesRes = await authApi.getSalesData(authToken!);
  //       log('Sales API Test Result: $salesRes');

  //       // عرض رسالة نجاح شاملة
  //       Get.showSnackbar(GetSnackBar(
  //         title: 'اختبار APIs',
  //         message: 'تم اختبار جميع APIs بنجاح',
  //         backgroundColor: Colors.blue,
  //         duration: const Duration(seconds: 2),
  //       ));
  //     } catch (e) {
  //       log('APIs Test Error: $e');
  //     }
  //   }
  // }

  // // وظيفة جديدة لجلب بيانات منتج معين
  // Future<Map<String, dynamic>?> getProductData(String productCode) async {
  //   if (authToken == null) {
  //     Get.showSnackbar(GetSnackBar(
  //       title: 'خطأ',
  //       message: 'يجب تسجيل الدخول أولاً',
  //       backgroundColor: Colors.red,
  //       duration: const Duration(seconds: 2),
  //     ));
  //     return null;
  //   }

  //   try {
  //     EasyLoading.show(status: 'جاري جلب بيانات المنتج...');

  //     final result = await authApi.getStockInfo(productCode, authToken!);

  //     EasyLoading.dismiss();

  //     if (result['status'] == 'success') {
  //       return result;
  //     } else {
  //       Get.showSnackbar(GetSnackBar(
  //         title: 'خطأ',
  //         message: result['message'] ?? 'فشل في جلب بيانات المنتج',
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 2),
  //       ));
  //       return null;
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     log('Product Data Error: $e');
  //     return null;
  //   }
  // }

  // // وظيفة جديدة لجلب بيانات المبيعات
  // Future<Map<String, dynamic>?> fetchSalesData() async {
  //   if (authToken == null) {
  //     Get.showSnackbar(GetSnackBar(
  //       title: 'خطأ',
  //       message: 'يجب تسجيل الدخول أولاً',
  //       backgroundColor: Colors.red,
  //       duration: const Duration(seconds: 2),
  //     ));
  //     return null;
  //   }

  //   try {
  //     EasyLoading.show(status: 'جاري جلب بيانات المبيعات...');

  //     final result = await authApi.getSalesData(authToken!);

  //     EasyLoading.dismiss();

  //     if (result['status'] == 'success') {
  //       return result;
  //     } else {
  //       Get.showSnackbar(GetSnackBar(
  //         title: 'خطأ',
  //         message: result['message'] ?? 'فشل في جلب بيانات المبيعات',
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 2),
  //       ));
  //       return null;
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     log('Sales Data Error: $e');
  //     return null;
  //   }
  // }

  // تسجيل حساب جديد
//   Future<void> signUp() async {
//     if (signupFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       EasyLoading.show(status: 'جاري إنشاء الحساب...');

//       UserModel userModel = UserModel(
//         name: nameController.text.trim(),
//         password: passwordController.text,
//       );

//       try {
//         final res = await authApi.postSignUp(userModel);
//         statusRequest = handlingData(res);

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

//         Get.showSnackbar(GetSnackBar(
//           title: 'خطأ',
//           message: 'فشل في إنشاء الحساب',
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ));
//       }

//       isLoading.value = false;
//     }
//   }

//   // تسجيل الخروج
//   Future<void> logout() async {
//     await Preferences.setBoolean(Preferences.isLogin, false);
//     await Preferences.removeString('auth_token');
//     authToken = null;

//     // مسح بيانات المستخدم
//     clearForm();

//     Get.snackbar(
//       'تم',
//       'تم تسجيل الخروج بنجاح',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//     );

//     // العودة إلى صفحة تسجيل الدخول
//     Get.offAllNamed('/login');
//   }

//   // Clear form data
//   void clearForm() {
//     emailController.clear();
//     passwordController.clear();
//     confirmPasswordController.clear();
//     nameController.clear();
//   }

//   @override
//   void onClose() {
//     // تنظيف الموارد
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
// }

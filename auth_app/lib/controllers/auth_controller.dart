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

import 'dart:developer';
import 'package:auth_app/classes/handling_data.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/classes/status_request.dart';
import 'package:auth_app/services/auh/auth_api.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // API Service
  final AuthApi authApi = AuthApi(Get.find());
  StatusRequest statusRequest = StatusRequest.none;

  // متغير لحفظ Token
  String? authToken;

  @override
  void onInit() {
    super.onInit();
    // تحقق من وجود token محفوظ عند بدء التطبيق
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

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  UserModel? getCurrentUser() {
    return Preferences.getDataUser();
  }

  // Login function محدثة ومحسنة
  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      statusRequest = StatusRequest.loading;

      // إنشاء نموذج المستخدم للتسجيل
      UserModel userModel = UserModel(
        name: nameController.text.trim(),
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
            name: nameController.text.trim(),
            token: authToken,
          );

          await Preferences.setDataUser(loggedUser);

          EasyLoading.dismiss();

          // اختبار جميع APIs الجديدة
          await testAllApis();

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

  // اختبار جميع APIs الجديدة
  Future<void> testAllApis() async {
    if (authToken != null) {
      try {
        // 1. اختبار API الأساسي
        log('=== اختبار API الأساسي ===');
        final testRes = await authApi.testApiWithToken(authToken!);
        log('Basic API Test Result: $testRes');

        // 2. اختبار echo endpoint مع رقم المنتج من الرابط
        log('=== اختبار Echo Endpoint ===');
        final echoRes = await authApi.testEchoEndpoint('6943090420065', authToken!);
        log('Echo API Test Result: $echoRes');

        // 3. اختبار جلب بيانات المخزون
        log('=== اختبار بيانات المخزون ===');
        final stockRes = await authApi.getStockInfo('6943090420065', authToken!);
        log('Stock API Test Result: $stockRes');

        // 4. اختبار جلب بيانات المبيعات
        log('=== اختبار بيانات المبيعات ===');
        final salesRes = await authApi.getSalesData(authToken!);
        log('Sales API Test Result: $salesRes');

        // عرض رسالة نجاح شاملة
        Get.showSnackbar(GetSnackBar(
          title: 'اختبار APIs',
          message: 'تم اختبار جميع APIs بنجاح',
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ));
      } catch (e) {
        log('APIs Test Error: $e');
      }
    }
  }

  // وظيفة جديدة لجلب بيانات منتج معين
  Future<Map<String, dynamic>?> getProductData(String productCode) async {
    if (authToken == null) {
      Get.showSnackbar(GetSnackBar(
        title: 'خطأ',
        message: 'يجب تسجيل الدخول أولاً',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
      return null;
    }

    try {
      EasyLoading.show(status: 'جاري جلب بيانات المنتج...');

      final result = await authApi.getStockInfo(productCode, authToken!);

      EasyLoading.dismiss();

      if (result['status'] == 'success') {
        return result;
      } else {
        Get.showSnackbar(GetSnackBar(
          title: 'خطأ',
          message: result['message'] ?? 'فشل في جلب بيانات المنتج',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ));
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      log('Product Data Error: $e');
      return null;
    }
  }

  // وظيفة جديدة لجلب بيانات المبيعات
  Future<Map<String, dynamic>?> fetchSalesData() async {
    if (authToken == null) {
      Get.showSnackbar(GetSnackBar(
        title: 'خطأ',
        message: 'يجب تسجيل الدخول أولاً',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
      return null;
    }

    try {
      EasyLoading.show(status: 'جاري جلب بيانات المبيعات...');

      final result = await authApi.getSalesData(authToken!);

      EasyLoading.dismiss();

      if (result['status'] == 'success') {
        return result;
      } else {
        Get.showSnackbar(GetSnackBar(
          title: 'خطأ',
          message: result['message'] ?? 'فشل في جلب بيانات المبيعات',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ));
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      log('Sales Data Error: $e');
      return null;
    }
  }

  // تسجيل حساب جديد
  Future<void> signUp() async {
    if (signupFormKey.currentState!.validate()) {
      isLoading.value = true;
      EasyLoading.show(status: 'جاري إنشاء الحساب...');

      UserModel userModel = UserModel(
        name: nameController.text.trim(),
        password: passwordController.text,
      );

      try {
        final res = await authApi.postSignUp(userModel);
        statusRequest = handlingData(res);

        EasyLoading.dismiss();

        if (statusRequest == StatusRequest.success && res['status'] == 'success') {
          await Preferences.setBoolean(Preferences.isLogin, true);
          Get.offAllNamed('/home');
          log('تم إنشاء الحساب بنجاح');

          Get.showSnackbar(const GetSnackBar(
            title: 'نجح',
            message: 'تم إنشاء الحساب بنجاح',
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
        } else {
          throw Exception(res['message'] ?? 'فشل في إنشاء الحساب');
        }
      } catch (e) {
        EasyLoading.dismiss();
        log('Signup Error: $e');

        Get.showSnackbar(GetSnackBar(
          title: 'خطأ',
          message: 'فشل في إنشاء الحساب',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ));
      }

      isLoading.value = false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await Preferences.setBoolean(Preferences.isLogin, false);
    await Preferences.removeString('auth_token');
    authToken = null;

    // مسح بيانات المستخدم
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
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
  }

  @override
  void onClose() {
    // تنظيف الموارد
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}

// lib/controllers/auth_controller.dart
// lib/controllers/auth_controller.dart
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

//   // Text controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

//   // API Service
//   final AuthApi authApi = AuthApi(Get.find());
//   StatusRequest statusRequest = StatusRequest.none;

//   // متغير لحفظ Token
//   String? authToken;

//   @override
//   void onInit() {
//     super.onInit();
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

//   // Login function محدثة
//   Future<void> login() async {
//     if (loginFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       statusRequest = StatusRequest.loading;

//       // إنشاء نموذج المستخدم للتسجيل
//       UserModel userModel = UserModel(
//         name: nameController.text.trim(), // سيتم إرساله كـ username
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

//           // اختبار API مع Token
//           await testApiConnection();
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

//   // اختبار الاتصال بـ API
//   Future<void> testApiConnection() async {
//     if (authToken != null) {
//       try {
//         final testRes = await authApi.testApiWithToken(authToken!);
//         if (testRes.containsKey('message') || testRes.containsKey('data')) {
//           log('API Test Success: $testRes');

//           // يمكنك عرض رسالة للمستخدم إذا أردت
//           // Get.showSnackbar(GetSnackBar(
//           //   title: 'اختبار API',
//           //   message: 'تم الاتصال بـ API بنجاح',
//           //   backgroundColor: Colors.blue,
//           //   duration: const Duration(seconds: 2),
//           // ));
//         }
//       } catch (e) {
//         log('API Test Error: $e');
//       }
//     }
//   }

//   // Sign up function (إذا كان مطلوب)
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


// lib/controllers/auth_controller.dart

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
//   var acceptTerms = false.obs;

//   // Text controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  
//   final AuthApi authApi = AuthApi(Get.find());
//   StatusRequest statusRequest = StatusRequest.none;

//   @override
//   void onInit() {
//     super.onInit();
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
//     if (loginFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       statusRequest = StatusRequest.loading;
      
//       UserModel userModel = UserModel(
//         email: emailController.text.trim(),
//         password: passwordController.text,
//       );
      
//       EasyLoading.show(status: 'جاري تسجيل الدخول...');

//       try {
//         final res = await authApi.postlogin(userModel);
//         statusRequest = handlingData(res);
        
//         if (statusRequest == StatusRequest.success) {
//           // التحقق من وجود بيانات المستخدم في الاستجابة
//           if (res['user'] != null) {
//             var model = UserModel.fromJson(res['user']);
//             model.password = passwordController.text;
            
//             // حفظ التوكن إذا كان موجود
//             if (res['token'] != null) {
//               await Preferences.setString(Preferences.token, res['token']);
//             }
            
//             await Preferences.setBoolean(Preferences.isLogin, true);
//             await Preferences.setDataUser(model);
            
//             EasyLoading.dismiss();
//             Get.offAllNamed('/home');
            
//             Get.showSnackbar(GetSnackBar(
//               title: 'نجح',
//               message: 'تم تسجيل الدخول بنجاح',
//               snackPosition: SnackPosition.TOP,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 2),
//             ));
            
//             log("Success Login");
//           } else {
//             _showErrorMessage('خطأ في البيانات المسترجعة من الخادم');
//           }
//         } else {
//           String errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          
//           // التحقق من وجود رسائل خطأ مخصصة
//           if (res['errors'] != null && res['errors']['email'] != null) {
//             errorMessage = res['errors']['email'][0];
//           } else if (res['message'] != null) {
//             errorMessage = res['message'];
//           }
          
//           _showErrorMessage(errorMessage);
//         }
//       } catch (e) {
//         log('Login Error: $e');
//         _showErrorMessage('حدث خطأ أثناء تسجيل الدخول');
//       } finally {
//         EasyLoading.dismiss();
//         isLoading.value = false;
//       }
//     }
//   }

//   // Sign up function
//   Future<void> signUp() async {
//     if (signupFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       EasyLoading.show(status: 'جاري إنشاء الحساب...');
      
//       UserModel userModel = UserModel(
//         name: nameController.text.trim(),
//         email: emailController.text.trim(),
//         password: passwordController.text,
//         passwordConfirmation: confirmPasswordController.text,
//       );

//       try {
//         final res = await authApi.postSignUp(userModel);
//         statusRequest = handlingData(res);
        
//         if (statusRequest == StatusRequest.success) {
//           if (res['user'] != null) {
//             // حفظ التوكن إذا كان موجود
//             if (res['token'] != null) {
//               await Preferences.setString(Preferences.token, res['token']);
//             }
            
//             await Preferences.setBoolean(Preferences.isLogin, true);
//             var model = UserModel.fromJson(res['user']);
//             await Preferences.setDataUser(model);
            
//             EasyLoading.dismiss();
            
//             Get.showSnackbar(GetSnackBar(
//               title: 'نجح',
//               message: res['message'] ?? 'تم إنشاء الحساب بنجاح',
//               snackPosition: SnackPosition.TOP,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 3),
//             ));
            
//             // الانتقال لصفحة التحقق من البريد الإلكتروني إذا لزم الأمر
//             if (res['verification_code'] != null) {
//               Get.offAllNamed('/verification');
//             } else {
//               Get.offAllNamed('/home');
//             }
            
//             log('Success Signup');
//           }
//         } else {
//           String errorMessage = 'فشل في إنشاء الحساب';
          
//           // معالجة أخطاء التحقق
//           if (res['errors'] != null) {
//             Map<String, dynamic> errors = res['errors'];
//             List<String> errorMessages = [];
            
//             errors.forEach((key, value) {
//               if (value is List) {
//                 errorMessages.addAll(value.cast<String>());
//               }
//             });
            
//             errorMessage = errorMessages.isNotEmpty ? errorMessages.first : errorMessage;
//           } else if (res['message'] != null) {
//             errorMessage = res['message'];
//           }
          
//           _showErrorMessage(errorMessage);
//         }
//       } catch (e) {
//         log('Signup Error: $e');
//         _showErrorMessage('حدث خطأ أثناء إنشاء الحساب');
//       } finally {
//         EasyLoading.dismiss();
//         isLoading.value = false;
//       }
//     }
//   }

//   // تسجيل الخروج
//   Future<void> logout() async {
//     try {
//       // إرسال طلب تسجيل الخروج للخادم
//       await authApi.postlogout();
      
//       // مسح البيانات المحلية
//       await Preferences.setBoolean(Preferences.isLogin, false);
//       await Preferences.clearKeyData(Preferences.user);
//       await Preferences.clearKeyData(Preferences.token);
      
//       Get.offAllNamed('/login');
      
//       Get.showSnackbar(GetSnackBar(
//         title: 'تم',
//         message: 'تم تسجيل الخروج بنجاح',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 2),
//       ));
//     } catch (e) {
//       log('Logout Error: $e');
//     }
//   }

//   // دالة مساعدة لإظهار رسائل الخطأ
//   void _showErrorMessage(String message) {
//     Get.showSnackbar(GetSnackBar(
//       title: 'خطأ',
//       message: message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     ));
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
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
// }










// lib/controllers/auth_controller.dart

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

//   // Text controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  
//   final AuthApi authApi = AuthApi(Get.find());
//   StatusRequest statusRequest = StatusRequest.none;

//   @override
//   void onInit() {
//     super.onInit();
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
//     if (loginFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       statusRequest = StatusRequest.loading;
      
//       UserModel userModel = UserModel(
//         email: emailController.text.trim(),
//         password: passwordController.text,
//       );
      
//       EasyLoading.show(status: 'جاري تسجيل الدخول...');

//       try {
//         final res = await authApi.postlogin(userModel);
//         statusRequest = handlingData(res);
        
//         if (statusRequest == StatusRequest.success) {
//           // التحقق من وجود بيانات المستخدم في الاستجابة
//           if (res['user'] != null) {
//             var model = UserModel.fromJson(res['user']);
//             model.password = passwordController.text;
            
//             // حفظ التوكن إذا كان موجود
//             if (res['token'] != null) {
//               await Preferences.setString(Preferences.token, res['token']);
//             }
            
//             await Preferences.setBoolean(Preferences.isLogin, true);
//             await Preferences.setDataUser(model);
            
//             EasyLoading.dismiss();
//             Get.offAllNamed('/home');
            
//             Get.showSnackbar(GetSnackBar(
//               title: 'نجح',
//               message: 'تم تسجيل الدخول بنجاح',
//               snackPosition: SnackPosition.TOP,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 2),
//             ));
            
//             log("Success Login");
//           } else {
//             _showErrorMessage('خطأ في البيانات المسترجعة من الخادم');
//           }
//         } else {
//           String errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          
//           // التحقق من وجود رسائل خطأ مخصصة
//           if (res['errors'] != null && res['errors']['email'] != null) {
//             errorMessage = res['errors']['email'][0];
//           } else if (res['message'] != null) {
//             errorMessage = res['message'];
//           }
          
//           _showErrorMessage(errorMessage);
//         }
//       } catch (e) {
//         log('Login Error: $e');
//         _showErrorMessage('حدث خطأ أثناء تسجيل الدخول');
//       } finally {
//         EasyLoading.dismiss();
//         isLoading.value = false;
//       }
//     }
//   }

//   // Sign up function
//   Future<void> signUp() async {
//     if (signupFormKey.currentState!.validate()) {
//       isLoading.value = true;
//       EasyLoading.show(status: 'جاري إنشاء الحساب...');
      
//       UserModel userModel = UserModel(
//         name: nameController.text.trim(),
//         email: emailController.text.trim(),
//         password: passwordController.text,
//         passwordConfirmation: confirmPasswordController.text,
//       );

//       try {
//         final res = await authApi.postSignUp(userModel);
//         statusRequest = handlingData(res);
        
//         if (statusRequest == StatusRequest.success) {
//           if (res['user'] != null) {
//             // حفظ التوكن إذا كان موجود
//             if (res['token'] != null) {
//               await Preferences.setString(Preferences.token, res['token']);
//             }
            
//             await Preferences.setBoolean(Preferences.isLogin, true);
//             var model = UserModel.fromJson(res['user']);
//             await Preferences.setDataUser(model);
            
//             EasyLoading.dismiss();
            
//             Get.showSnackbar(GetSnackBar(
//               title: 'نجح',
//               message: res['message'] ?? 'تم إنشاء الحساب بنجاح',
//               snackPosition: SnackPosition.TOP,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//               duration: const Duration(seconds: 3),
//             ));
            
//             // الانتقال لصفحة التحقق من البريد الإلكتروني إذا لزم الأمر
//             if (res['verification_code'] != null) {
//               Get.offAllNamed('/verification');
//             } else {
//               Get.offAllNamed('/home');
//             }
            
//             log('Success Signup');
//           }
//         } else {
//           String errorMessage = 'فشل في إنشاء الحساب';
          
//           // معالجة أخطاء التحقق
//           if (res['errors'] != null) {
//             Map<String, dynamic> errors = res['errors'];
//             List<String> errorMessages = [];
            
//             errors.forEach((key, value) {
//               if (value is List) {
//                 errorMessages.addAll(value.cast<String>());
//               }
//             });
            
//             errorMessage = errorMessages.isNotEmpty ? errorMessages.first : errorMessage;
//           } else if (res['message'] != null) {
//             errorMessage = res['message'];
//           }
          
//           _showErrorMessage(errorMessage);
//         }
//       } catch (e) {
//         log('Signup Error: $e');
//         _showErrorMessage('حدث خطأ أثناء إنشاء الحساب');
//       } finally {
//         EasyLoading.dismiss();
//         isLoading.value = false;
//       }
//     }
//   }

//   // تسجيل الخروج
//   Future<void> logout() async {
//     try {
//       // إرسال طلب تسجيل الخروج للخادم
//       await authApi.postlogout();
      
//       // مسح البيانات المحلية
//       await Preferences.setBoolean(Preferences.isLogin, false);
//       await Preferences.clearKeyData(Preferences.user);
//       await Preferences.clearKeyData(Preferences.token);
      
//       Get.offAllNamed('/login');
      
//       Get.showSnackbar(GetSnackBar(
//         title: 'تم',
//         message: 'تم تسجيل الخروج بنجاح',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 2),
//       ));
//     } catch (e) {
//       log('Logout Error: $e');
//     }
//   }

//   // دالة مساعدة لإظهار رسائل الخطأ
//   void _showErrorMessage(String message) {
//     Get.showSnackbar(GetSnackBar(
//       title: 'خطأ',
//       message: message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     ));
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
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
// }



// // lib/controllers/auth_controller.dart

// import 'package:get/get.dart';
// import 'package:flutter/material.dart';

// class AuthController extends GetxController {
//   // Observable variables
//   var isLoading = false.obs;
//   var isPasswordVisible = false.obs;
//   var isConfirmPasswordVisible = false.obs;

//   // Text controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

//   // Toggle password visibility
//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   void toggleConfirmPasswordVisibility() {
//     isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
//   }

//   // Login function
//   Future<void> login() async {
//     if (!loginFormKey.currentState!.validate()) {
//       // UserModel userModel =
//       //     UserModel(email: emailController.text, password: passwordController.text);
//       // EasyLoading.show(status: 'loading...');
//     }

//     try {
//       isLoading.value = true;

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       // Here you would implement your actual login logic
//       // Example: await FirebaseAuth.instance.signInWithEmailAndPassword(...)

//       Get.snackbar(
//         'نجح',
//         'تم تسجيل الدخول بنجاح',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );

//       // Navigate to home page
//       // Get.offAllNamed('/home');
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في تسجيل الدخول',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Sign up function
//   Future<void> signUp() async {
//     if (!signupFormKey.currentState!.validate()) return;

//     try {
//       isLoading.value = true;

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       // Here you would implement your actual signup logic
//       // Example: await FirebaseAuth.instance.createUserWithEmailAndPassword(...)

//       Get.snackbar(
//         'نجح',
//         'تم إنشاء الحساب بنجاح',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );

//       // Navigate to home page or login page
//       // Get.offAllNamed('/home');
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في إنشاء الحساب',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       isLoading.value = false;
//     }
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
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
// }

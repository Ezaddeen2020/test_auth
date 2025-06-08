// services/auth/auth_api.dart
import 'dart:developer';
import 'package:auth_app/models/user_model.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class AuthApi {
  final PostGetPage postGetPage;

  AuthApi(this.postGetPage);

  // تسجيل الدخول
  Future<Map<String, dynamic>> postlogin(UserModel userModel) async {
    try {
      log('Attempting login with data: ${userModel.toJson()}');

      final result = await postGetPage.postData(
        ApiServices.login,
        userModel.toJson(),
      );

      return result.fold(
        (failure) {
          log('Login API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في الاتصال بالخادم'};
        },
        (data) {
          log('Login API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Login Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // اختبار API مع Token
  Future<Map<String, dynamic>> testApiWithToken(String token) async {
    try {
      log('Testing API with token: $token');

      final result = await postGetPage.getDataWithToken(
        ApiServices.salesDataTest, // استخدام الرابط الجديد
        token,
      );

      return result.fold(
        (failure) {
          log('Test API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في اختبار API'};
        },
        (data) {
          log('Test API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Test API Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ في اختبار API'};
    }
  }

  // جلب بيانات المخزون - وظيفة جديدة
  Future<Map<String, dynamic>> getStockInfo(String stockCode, String token) async {
    try {
      log('Getting stock info for code: $stockCode');

      final result = await postGetPage.getDataWithToken(
        ApiServices.stockInfo(stockCode),
        token,
      );

      return result.fold(
        (failure) {
          log('Stock API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في جلب بيانات المخزون'};
        },
        (data) {
          log('Stock API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Stock API Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ في جلب بيانات المخزون'};
    }
  }

  // جلب بيانات المبيعات - وظيفة جديدة
  Future<Map<String, dynamic>> getSalesData(String token) async {
    try {
      log('Getting sales data with token: $token');

      final result = await postGetPage.getDataWithToken(
        ApiServices.salesData,
        token,
      );

      return result.fold(
        (failure) {
          log('Sales Data API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في جلب بيانات المبيعات'};
        },
        (data) {
          log('Sales Data API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Sales Data API Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ في جلب بيانات المبيعات'};
    }
  }

  // اختبار echo endpoint - وظيفة جديدة للاختبار
  Future<Map<String, dynamic>> testEchoEndpoint(String stockCode, String token) async {
    try {
      log('Testing echo endpoint with stock code: $stockCode');

      final result = await postGetPage.getDataWithToken(
        "${ApiServices.echo}/$stockCode",
        token,
      );

      return result.fold(
        (failure) {
          log('Echo API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في اختبار Echo'};
        },
        (data) {
          log('Echo API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Echo API Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ في اختبار Echo'};
    }
  }

  // تسجيل حساب جديد
  Future<Map<String, dynamic>> postSignUp(UserModel userModel) async {
    try {
      log('Attempting signup with data: ${userModel.toJson()}');

      final result = await postGetPage.postData(
        ApiServices.register,
        userModel.toJson(),
      );

      return result.fold(
        (failure) {
          log('Signup API Error: $failure');
          return {'status': 'failure', 'message': 'فشل في إنشاء الحساب'};
        },
        (data) {
          log('Signup API Success: $data');
          return data;
        },
      );
    } catch (e) {
      log('Signup Exception: $e');
      return {'status': 'failure', 'message': 'حدث خطأ في إنشاء الحساب'};
    }
  }
}

  // postCheckEmail(String email) async {
  //   var res = await apiReq.postData(ApiServices.check, {'email': email});
  //   return res.fold((l) => l, (r) => r);
  // }

  // postReset(String email, String password) async {
  //   var res = await apiReq.postData(
  //       ApiServices.resetpassword, {'email': email, 'password': password});
  //   return res.fold((r) => r, (l) => l);
  // }



// // lib/services/auth/auth_api.dart

// import 'package:auth_app/models/user_model.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:auth_app/classes/shared_preference.dart';

// class AuthApi {
//   final PostGetPage apiReq;
  
//   AuthApi(this.apiReq);

//   // تسجيل الدخول
//   Future<dynamic> postlogin(UserModel userModel) async {
//     try {
//       Map<String, dynamic> data = {
//         'email': userModel.email,
//         'password': userModel.password,
//       };
      
//       var res = await apiReq.postData(ApiServices.login, data);
//       return res.fold((left) => left, (right) => right);
//     } catch (e) {
//       print('Login API Error: $e');
//       return {'error': 'حدث خطأ في الاتصال'};
//     }
//   }

//   // تسجيل حساب جديد
//   Future<dynamic> postSignUp(UserModel userModel) async {
//     try {
//       Map<String, dynamic> data = {
//         'name': userModel.name,
//         'email': userModel.email,
//         'password': userModel.password,
//         'password_confirmation': userModel.passwordConfirmation,
//       };
      
//       var res = await apiReq.postData(ApiServices.register, data);
//       return res.fold((left) => left, (right) => right);
//     } catch (e) {
//       print('SignUp API Error: $e');
//       return {'error': 'حدث خطأ في الاتصال'};
//     }
//   }

//   // تسجيل الخروج
//   Future<dynamic> postlogout() async {
//     try {
//       String token = Preferences.getString(Preferences.token);
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
      
//       var res = await apiReq.postDataWithHeaders(ApiServices.logout, {}, headers);
//       return res.fold((left) => left, (right) => right);
//     } catch (e) {
//       print('Logout API Error: $e');
//       return {'error': 'حدث خطأ في الاتصال'};
//     }
//   }

//   // التحقق من البريد الإلكتروني
//   Future<dynamic> verifyEmail(String email, String code) async {
//     try {
//       Map<String, dynamic> data = {
//         'email': email,
//         'verification_code': code,
//       };
      
//       var res = await apiReq.postData(ApiServices.verifyEmail, data);
//       return res.fold((left) => left, (right) => right);
//     } catch (e) {
//       print('Verify Email API Error: $e');
//       return {'error': 'حدث خطأ في الاتصال'};
//     }
//   }

//   // إعادة إرسال كود التحقق
//   Future<dynamic> resendVerificationCode(String email) async {
//     try {
//       Map<String, dynamic> data = {
//         'email': email,
//       };
      
//       var res = await apiReq.postData(ApiServices.resendVerification, data);
//       return res.fold((left) => left, (right) => right);
//     } catch (e) {
//       print('Resend Verification API Error: $e');
//       return {'error': 'حدث خطأ في الاتصال'};
//     }
//   }
// }
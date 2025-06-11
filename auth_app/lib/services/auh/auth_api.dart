import 'dart:developer';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/models/user_model.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:dartz/dartz.dart';

class AuthApi {
  final PostGetPage postGetPage;

  AuthApi(this.postGetPage);

  // دالة مساعدة للـ logging
  void _log(String tag, String message) {
    log('$tag: $message');
  }

  // دالة مساعدة للتعامل مع الـ Either
  Future<Map<String, dynamic>> _handleResult(
    Future<Either<StatusRequest, Map<String, dynamic>>> future,
    String successTag,
    String failureMessage,
  ) async {
    try {
      final result = await future;
      return result.fold(
        (failure) {
          _log('API Error', failure.toString());
          return {'status': 'failure', 'message': failureMessage};
        },
        (data) {
          _log(successTag, data.toString());
          return data;
        },
      );
    } catch (e) {
      _log('API Exception', e.toString());
      return {'status': 'failure', 'message': 'حدث خطأ غير متوقع'};
    }
  }

  Future<Map<String, dynamic>> postlogin(UserModel userModel) async {
    _log('Login', 'Attempting login with data: ${userModel.toJson()}');
    return _handleResult(
      postGetPage.postData(ApiServices.login, userModel.toJson()),
      'Login Success',
      'فشل في الاتصال بالخادم',
    );
  }

  // Future<Map<String, dynamic>> postlogin(UserModel userModel) async {
  //   // طباعة مباشرة للتأكد
  //   const directUrl = "https://qitaf3.dynalias.net:44322/api/Account/login";
  //   print('DIRECT URL: $directUrl');
  //   print('ApiServices.server: ${ApiServices.server}');
  //   print('ApiServices.login: ${ApiServices.login}');
  //   print('Are they equal? ${directUrl == ApiServices.login}');

  //   _log('Login', 'Attempting login with data: ${userModel.toJson()}');
  //   return _handleResult(
  //     postGetPage.postData(directUrl, userModel.toJson()), // استخدم المباشر
  //     'Login Success',
  //     'فشل في الاتصال بالخادم',
  //   );
  // }

  Future<Map<String, dynamic>> postSignUp(UserModel userModel) async {
    _log('Signup', 'Attempting signup with data: ${userModel.toJson()}');
    return _handleResult(
      postGetPage.postData(ApiServices.register, userModel.toJson()),
      'Signup API Success',
      'فشل في إنشاء الحساب',
    );
  }
}


  // Future<Map<String, dynamic>> testApiWithToken(String token) async {
  //   _log('Test API', 'Testing API with token: $token');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.salesDataTest, token),
  //     'Test API Success',
  //     'فشل في اختبار API',
  //   );
  // }

  // Future<Map<String, dynamic>> getStockInfo(String stockCode, String token) async {
  //   _log('Stock Info', 'Getting stock info for code: $stockCode');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.stockInfo(stockCode), token),
  //     'Stock API Success',
  //     'فشل في جلب بيانات المخزون',
  //   );
  // }

  // Future<Map<String, dynamic>> getSalesData(String token) async {
  //   _log('Sales Data', 'Getting sales data with token: $token');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.salesData, token),
  //     'Sales Data API Success',
  //     'فشل في جلب بيانات المبيعات',
  //   );
  // }

  // Future<Map<String, dynamic>> testEchoEndpoint(String stockCode, String token) async {
  //   _log('Echo Endpoint', 'Testing echo endpoint with stock code: $stockCode');
  //   return _handleResult(
  //     postGetPage.getDataWithToken("${ApiServices.echo}/$stockCode", token),
  //     'Echo API Success',
  //     'فشل في اختبار Echo',
  //   );
  // }

  



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
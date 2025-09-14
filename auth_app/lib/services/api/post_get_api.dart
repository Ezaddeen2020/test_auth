// import 'dart:convert';
// import 'dart:developer';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/io_client.dart';

// class PostGetPage {
//   final IOClient client;

//   // ================== الدوال الأصلية - بدون تغيير ==================
//   PostGetPage({IOClient? client}) : client = client ?? IOClient();

//   /// POST request without token (الدالة الأصلية)
//   Future<Either<StatusRequest, Map<String, dynamic>>> postData(
//       String link, Map<String, dynamic> data) async {
//     try {
//       log('POST URL: $link');
//       log('POST Data: ${jsonEncode(data)}');

//       var res = await client.post(
//         Uri.parse(link),
//         headers: ApiServices.headers,
//         body: jsonEncode(data),
//       );

//       log('POST Response Status: ${res.statusCode}');
//       log('POST Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('POST Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   /// GET request with token (الدالة الأصلية)
//   Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
//     try {
//       log('GET with Token URL: $link');

//       var res = await client.get(
//         Uri.parse(link),
//         headers: ApiServices.headersWithToken(token),
//       );

//       log('GET Response Status: ${res.statusCode}');
//       log('GET Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('GET Error: $e');
//       return const Left(StatusRequest.failure);
//     }
//   }

//   // ================== الدوال الجديدة المضافة بأمان ==================

//   /// POST request with token (دالة جديدة للتحويلات)
//   Future<Either<StatusRequest, dynamic>> postDataWithToken(
//       String link, Map<String, dynamic> data, String token) async {
//     try {
//       log('POST with Token URL: $link');
//       log('POST with Token Data: ${jsonEncode(data)}');

//       var res = await client.post(
//         Uri.parse(link),
//         headers: ApiServices.headersWithToken(token),
//         body: jsonEncode(data),
//       );

//       log('POST with Token Response Status: ${res.statusCode}');
//       log('POST with Token Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('POST with Token Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   // أضف هذه الدالة في PostGetPage class
//   Future<Either<StatusRequest, dynamic>> deleteDataWithToken(
//       String link, Map<String, dynamic> data, String token) async {
//     try {
//       log('DELETE with Token URL: $link');
//       log('DELETE with Token Data: ${jsonEncode(data)}');

//       var res = await client.delete(
//         Uri.parse(link),
//         headers: ApiServices.headersWithToken(token),
//         body: jsonEncode(data),
//       );

//       log('DELETE Response Status: ${res.statusCode}');
//       log('DELETE Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
//         if (res.body.isNotEmpty) {
//           var resBody = jsonDecode(res.body);
//           return Right(resBody);
//         } else {
//           return const Right({'status': 'success', 'message': 'Deleted successfully'});
//         }
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('DELETE Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auth_app/functions/status_request.dart';
import 'package:dartz/dartz.dart';
import 'package:http/io_client.dart';

class PostGetPage {
  final IOClient client;

  PostGetPage({IOClient? client}) : client = client ?? _createHttpClient();

  // إنشاء HTTP client محسّن لـ Android
  static IOClient _createHttpClient() {
    final httpClient = HttpClient();

    // إعدادات timeout محسّنة لـ Android
    httpClient.connectionTimeout = const Duration(seconds: 15);
    httpClient.idleTimeout = const Duration(seconds: 30);

    // تجاهل مشاكل SSL المؤقتة (للتطوير فقط)
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      log('تجاهل شهادة SSL غير صالحة للـ host: $host');
      return true;
    };

    // إعدادات User Agent لـ Android
    httpClient.userAgent = 'Flutter-Android-Auth-App/1.0';

    return IOClient(httpClient);
  }

  /// POST request without token - محسّن لـ Android
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
      String link, Map<String, dynamic> data) async {
    try {
      log('🚀 POST Request - Android');
      log('📍 URL: $link');
      log('📦 Data: ${jsonEncode(data)}');

      // Headers محسّنة لـ Android
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Flutter-Android/1.0',
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate',
      };

      final response = await client
          .post(
            Uri.parse(link),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      log('✅ Response Status: ${response.statusCode}');
      log('📄 Response Headers: ${response.headers}');
      log('📝 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return const Right({'status': 'success', 'message': 'Empty response'});
        }

        final resBody = jsonDecode(response.body);
        return Right(resBody);
      } else {
        log('❌ Server Error: ${response.statusCode} - ${response.reasonPhrase}');
        return const Left(StatusRequest.serverfailure);
      }
    } on SocketException catch (e) {
      log('🌐 Network Error: $e');
      return const Left(StatusRequest.offlinefailure);
    } on HttpException catch (e) {
      log('🔧 HTTP Error: $e');
      return const Left(StatusRequest.serverfailure);
    } on FormatException catch (e) {
      log('📋 JSON Format Error: $e');
      return const Left(StatusRequest.serverfailure);
    } catch (e) {
      log('⚠️ Unexpected Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// GET request with token - محسّن لـ Android
  Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
    try {
      log('🚀 GET Request with Token - Android');
      log('📍 URL: $link');
      log('🔑 Token: ${token.length > 20 ? '${token.substring(0, 20)}...' : token}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Flutter-Android/1.0',
        'Connection': 'keep-alive',
      };

      final response = await client
          .get(
            Uri.parse(link),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      log('✅ Response Status: ${response.statusCode}');
      log('📝 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return const Right([]);
        }

        final resBody = jsonDecode(response.body);
        return Right(resBody);
      } else {
        log('❌ Server Error: ${response.statusCode} - ${response.reasonPhrase}');
        return const Left(StatusRequest.serverfailure);
      }
    } on SocketException catch (e) {
      log('🌐 Network Error: $e');
      return const Left(StatusRequest.offlinefailure);
    } on HttpException catch (e) {
      log('🔧 HTTP Error: $e');
      return const Left(StatusRequest.serverfailure);
    } on FormatException catch (e) {
      log('📋 JSON Format Error: $e');
      return const Left(StatusRequest.serverfailure);
    } catch (e) {
      log('⚠️ Unexpected Error: $e');
      return const Left(StatusRequest.failure);
    }
  }

  /// POST request with token - محسّن لـ Android
  Future<Either<StatusRequest, dynamic>> postDataWithToken(
      String link, Map<String, dynamic> data, String token) async {
    try {
      log('🚀 POST Request with Token - Android');
      log('📍 URL: $link');
      log('📦 Data: ${jsonEncode(data)}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Flutter-Android/1.0',
        'Connection': 'keep-alive',
      };

      final response = await client
          .post(
            Uri.parse(link),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      log('✅ Response Status: ${response.statusCode}');
      log('📝 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          return const Right({'status': 'success'});
        }

        final resBody = jsonDecode(response.body);
        return Right(resBody);
      } else {
        log('❌ Server Error: ${response.statusCode} - ${response.reasonPhrase}');
        return const Left(StatusRequest.serverfailure);
      }
    } on SocketException catch (e) {
      log('🌐 Network Error: $e');
      return const Left(StatusRequest.offlinefailure);
    } on HttpException catch (e) {
      log('🔧 HTTP Error: $e');
      return const Left(StatusRequest.serverfailure);
    } on FormatException catch (e) {
      log('📋 JSON Format Error: $e');
      return const Left(StatusRequest.serverfailure);
    } catch (e) {
      log('⚠️ Unexpected Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// DELETE request with token - محسّن لـ Android
  Future<Either<StatusRequest, dynamic>> deleteDataWithToken(
      String link, Map<String, dynamic> data, String token) async {
    try {
      log('🚀 DELETE Request with Token - Android');
      log('📍 URL: $link');
      log('📦 Data: ${jsonEncode(data)}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Flutter-Android/1.0',
        'Connection': 'keep-alive',
      };

      final response = await client
          .delete(
            Uri.parse(link),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      log('✅ Response Status: ${response.statusCode}');
      log('📝 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (response.body.isEmpty) {
          return const Right({'status': 'success', 'message': 'Deleted successfully'});
        }

        final resBody = jsonDecode(response.body);
        return Right(resBody);
      } else {
        log('❌ Server Error: ${response.statusCode} - ${response.reasonPhrase}');
        return const Left(StatusRequest.serverfailure);
      }
    } on SocketException catch (e) {
      log('🌐 Network Error: $e');
      return const Left(StatusRequest.offlinefailure);
    } on HttpException catch (e) {
      log('🔧 HTTP Error: $e');
      return const Left(StatusRequest.serverfailure);
    } on FormatException catch (e) {
      log('📋 JSON Format Error: $e');
      return const Left(StatusRequest.serverfailure);
    } catch (e) {
      log('⚠️ Unexpected Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  // دالة اختبار الاتصال
  Future<bool> testConnection() async {
    try {
      log('🧪 Testing Connection...');
      final response = await client
          .get(Uri.parse('https://httpbin.org/get'))
          .timeout(const Duration(seconds: 10));

      log('🧪 Test Result: ${response.statusCode == 200 ? 'SUCCESS' : 'FAILED'}');
      return response.statusCode == 200;
    } catch (e) {
      log('🧪 Test Connection Error: $e');
      return false;
    }
  }
}




// PostGetPage() {
  //   final ioc = HttpClient()
  //     ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  //   client = IOClient(ioc);
  // }



  /// PUT request with token (دالة جديدة للتحديث)
  // Future<Either<StatusRequest, dynamic>> putDataWithToken(
  //     String link, Map<String, dynamic> data, String token) async {
  //   try {
  //     log('PUT with Token URL: $link');
  //     log('PUT with Token Data: ${jsonEncode(data)}');

  //     var res = await client.put(
  //       Uri.parse(link),
  //       headers: ApiServices.headersWithToken(token),
  //       body: jsonEncode(data),
  //     );

  //     log('PUT Response Status: ${res.statusCode}');
  //     log('PUT Response Body: ${res.body}');

  //     if (res.statusCode == 200 || res.statusCode == 204) {
  //       if (res.body.isNotEmpty) {
  //         var resBody = jsonDecode(res.body);
  //         return Right(resBody);
  //       } else {
  //         return const Right({'success': true});
  //       }
  //     } else {
  //       return const Left(StatusRequest.serverfailure);
  //     }
  //   } catch (e) {
  //     log('PUT Error: $e');
  //     return const Left(StatusRequest.offlinefailure);
  //   }
  // }

  /// DELETE request with token (دالة جديدة للحذف)
  // Future<Either<StatusRequest, dynamic>> deleteDataWithToken(String link, String token) async {
  //   try {
  //     log('DELETE with Token URL: $link');

  //     var res = await client.delete(
  //       Uri.parse(link),
  //       headers: ApiServices.headersWithToken(token),
  //     );

  //     log('DELETE Response Status: ${res.statusCode}');
  //     log('DELETE Response Body: ${res.body}');

  //     if (res.statusCode == 200 || res.statusCode == 204) {
  //       if (res.body.isNotEmpty) {
  //         var resBody = jsonDecode(res.body);
  //         return Right(resBody);
  //       } else {
  //         return const Right({'success': true});
  //       }
  //     } else {
  //       return const Left(StatusRequest.serverfailure);
  //     }
  //   } catch (e) {
  //     log('DELETE Error: $e');
  //     return const Left(StatusRequest.offlinefailure);
  //   }
  // }

  /// PATCH request with token (دالة جديدة للتحديث الجزئي)
  // Future<Either<StatusRequest, dynamic>> patchDataWithToken(
  //     String link, Map<String, dynamic> data, String token) async {
  //   try {
  //     log('PATCH with Token URL: $link');
  //     log('PATCH with Token Data: ${jsonEncode(data)}');

  //     var res = await client.patch(
  //       Uri.parse(link),
  //       headers: ApiServices.headersWithToken(token),
  //       body: jsonEncode(data),
  //     );

  //     log('PATCH Response Status: ${res.statusCode}');
  //     log('PATCH Response Body: ${res.body}');

  //     if (res.statusCode == 200 || res.statusCode == 204) {
  //       if (res.body.isNotEmpty) {
  //         var resBody = jsonDecode(res.body);
  //         return Right(resBody);
  //       } else {
  //         return const Right({'success': true});
  //       }
  //     } else {
  //       return const Left(StatusRequest.serverfailure);
  //     }
  //   } catch (e) {
  //     log('PATCH Error: $e');
  //     return const Left(StatusRequest.offlinefailure);
  //   }
  // }

  // ================== دوال مساعدة للتوافق مع الإصدارات القديمة ==================

  /// دالة مساعدة للتحقق من حالة الاستجابة
//   bool _isSuccessStatusCode(int statusCode) {
//     return statusCode >= 200 && statusCode < 300;
//   }

//   /// دالة مساعدة للتعامل مع الاستجابات الفارغة
//   dynamic _handleEmptyResponse(String body) {
//     if (body.isEmpty) {
//       return {'success': true, 'message': 'Operation completed successfully'};
//     }
//     return jsonDecode(body);
//   }

//   /// دالة مساعدة لتسجيل الأخطاء
//   void _logError(String operation, dynamic error) {
//     log('$operation Error: $error');
//   }

//   /// دالة مساعدة لتسجيل الاستجابات
//   void _logResponse(String operation, int statusCode, String body) {
//     log('$operation Response Status: $statusCode');
//     log('$operation Response Body: $body');
//   }
// }







// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/io_client.dart';

// class PostGetPage {
//   late IOClient client;

//   PostGetPage() {
//     final ioc = HttpClient()
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

//     client = IOClient(ioc);
//   }

//   Future<Either<StatusRequest, Map<String, dynamic>>> postData(
//       String link, Map<String, dynamic> data) async {
//     try {
//       log('POST URL: $link');
//       log('POST Data: ${jsonEncode(data)}');

//       var res =
//           await client.post(Uri.parse(link), headers: ApiServices.headers, body: jsonEncode(data));

//       log('POST Response Status: ${res.statusCode}');
//       log('POST Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('POST Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

// //================================================================================================//
//   Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
//     try {
//       var res = await client.get(Uri.parse(link), headers: ApiServices.headersWithToken(token));

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('GET Error: $e');
//       return const Left(StatusRequest.failure);
//     }
//   }
// }

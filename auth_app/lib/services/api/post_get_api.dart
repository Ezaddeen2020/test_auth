import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:dartz/dartz.dart';
import 'package:http/io_client.dart';

class PostGetPage {
  late IOClient client;

  PostGetPage() {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    client = IOClient(ioc);
  }

  // ================== الدوال الأصلية - بدون تغيير ==================

  /// POST request without token (الدالة الأصلية)
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
      String link, Map<String, dynamic> data) async {
    try {
      log('POST URL: $link');
      log('POST Data: ${jsonEncode(data)}');

      var res = await client.post(
        Uri.parse(link),
        headers: ApiServices.headers,
        body: jsonEncode(data),
      );

      log('POST Response Status: ${res.statusCode}');
      log('POST Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = jsonDecode(res.body);
        return Right(resBody);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('POST Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// GET request with token (الدالة الأصلية)
  Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
    try {
      log('GET with Token URL: $link');

      var res = await client.get(
        Uri.parse(link),
        headers: ApiServices.headersWithToken(token),
      );

      log('GET Response Status: ${res.statusCode}');
      log('GET Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = jsonDecode(res.body);
        return Right(resBody);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('GET Error: $e');
      return const Left(StatusRequest.failure);
    }
  }

  // ================== الدوال الجديدة المضافة بأمان ==================

  /// POST request with token (دالة جديدة للتحويلات)
  Future<Either<StatusRequest, dynamic>> postDataWithToken(
      String link, Map<String, dynamic> data, String token) async {
    try {
      log('POST with Token URL: $link');
      log('POST with Token Data: ${jsonEncode(data)}');

      var res = await client.post(
        Uri.parse(link),
        headers: ApiServices.headersWithToken(token),
        body: jsonEncode(data),
      );

      log('POST with Token Response Status: ${res.statusCode}');
      log('POST with Token Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = jsonDecode(res.body);
        return Right(resBody);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('POST with Token Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// PUT request with token (دالة جديدة للتحديث)
  Future<Either<StatusRequest, dynamic>> putDataWithToken(
      String link, Map<String, dynamic> data, String token) async {
    try {
      log('PUT with Token URL: $link');
      log('PUT with Token Data: ${jsonEncode(data)}');

      var res = await client.put(
        Uri.parse(link),
        headers: ApiServices.headersWithToken(token),
        body: jsonEncode(data),
      );

      log('PUT Response Status: ${res.statusCode}');
      log('PUT Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 204) {
        if (res.body.isNotEmpty) {
          var resBody = jsonDecode(res.body);
          return Right(resBody);
        } else {
          return const Right({'success': true});
        }
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('PUT Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// DELETE request with token (دالة جديدة للحذف)
  Future<Either<StatusRequest, dynamic>> deleteDataWithToken(String link, String token) async {
    try {
      log('DELETE with Token URL: $link');

      var res = await client.delete(
        Uri.parse(link),
        headers: ApiServices.headersWithToken(token),
      );

      log('DELETE Response Status: ${res.statusCode}');
      log('DELETE Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 204) {
        if (res.body.isNotEmpty) {
          var resBody = jsonDecode(res.body);
          return Right(resBody);
        } else {
          return const Right({'success': true});
        }
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('DELETE Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  /// PATCH request with token (دالة جديدة للتحديث الجزئي)
  Future<Either<StatusRequest, dynamic>> patchDataWithToken(
      String link, Map<String, dynamic> data, String token) async {
    try {
      log('PATCH with Token URL: $link');
      log('PATCH with Token Data: ${jsonEncode(data)}');

      var res = await client.patch(
        Uri.parse(link),
        headers: ApiServices.headersWithToken(token),
        body: jsonEncode(data),
      );

      log('PATCH Response Status: ${res.statusCode}');
      log('PATCH Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 204) {
        if (res.body.isNotEmpty) {
          var resBody = jsonDecode(res.body);
          return Right(resBody);
        } else {
          return const Right({'success': true});
        }
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('PATCH Error: $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  // ================== دوال مساعدة للتوافق مع الإصدارات القديمة ==================

  /// دالة مساعدة للتحقق من حالة الاستجابة
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// دالة مساعدة للتعامل مع الاستجابات الفارغة
  dynamic _handleEmptyResponse(String body) {
    if (body.isEmpty) {
      return {'success': true, 'message': 'Operation completed successfully'};
    }
    return jsonDecode(body);
  }

  /// دالة مساعدة لتسجيل الأخطاء
  void _logError(String operation, dynamic error) {
    log('$operation Error: $error');
  }

  /// دالة مساعدة لتسجيل الاستجابات
  void _logResponse(String operation, int statusCode, String body) {
    log('$operation Response Status: $statusCode');
    log('$operation Response Body: $body');
  }
}







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

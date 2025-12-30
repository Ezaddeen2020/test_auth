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

      // إذا كان رمز الاستجابة 401، التوكن غير صالح
      if (response.statusCode == 401) {
        log('❌ Token expired or invalid');
        return const Left(StatusRequest.unauthorized);
      }

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

      // إذا كان رمز الاستجابة 401، التوكن غير صالح
      if (response.statusCode == 401) {
        log('❌ Token expired or invalid');
        return const Left(StatusRequest.unauthorized);
      }

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

      // إذا كان رمز الاستجابة 401، التوكن غير صالح
      if (response.statusCode == 401) {
        log('❌ Token expired or invalid');
        return const Left(StatusRequest.unauthorized);
      }

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

  /// التحقق من صلاحية التوكن
  Future<bool> validateToken(String token) async {
    try {
      log('🔍 Validating token...');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Flutter-Android/1.0',
      };

      // استخدام endpoint بسيط للتحقق من صلاحية التوكن
      final response = await client
          .get(
            Uri.parse('https://qitaf3.dynalias.net:44322/echo/api/Account/validate-token'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      log('🔍 Token validation result: ${response.statusCode}');

      // إذا كان رمز الاستجابة 200، التوكن صالح
      return response.statusCode == 200;
    } catch (e) {
      log('🔍 Token validation error: $e');
      return false;
    }
  }
}

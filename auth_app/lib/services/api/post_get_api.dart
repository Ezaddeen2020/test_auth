// import 'dart:convert';
// import 'dart:developer';

// import 'package:auth_app/classes/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;

// class PostGetPage {
//   Future<Either<StatusRequest, Map<String, dynamic>>> getData(String link) async {
//     try {
//       var res = await http.get(Uri.parse(link));
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('error:$e');
//       return const Left(StatusRequest.failure);
//     }
//   }

//   Future<Either<StatusRequest, Map<String, dynamic>>> postData(
//       String link, Map<String, dynamic> data) async {
//     try {
//       var res =
//           await http.post(Uri.parse(link), headers: ApiServices.headers, body: jsonEncode(data));
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);

//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('Error $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   Future<Either<StatusRequest, String>> getDataAsString(String link) async {
//     try {
//       var res = await http.get(Uri.parse(link), headers: ApiServices.headers);
//       // log(res.body);
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = res.body;
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('Error $e');
//       return const Left(StatusRequest.serverfailure);
//     }
//   }
// }

// services/api/post_get_api.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:dartz/dartz.dart';
import 'package:http/io_client.dart'; // ملاحظة: غيرنا استيراد http العادي
import 'package:http/http.dart' as http;

class PostGetPage {
  late IOClient client;

  PostGetPage() {
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // تجاوز الشهادة

    client = IOClient(ioc);
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getData(String link) async {
    try {
      var res = await client.get(Uri.parse(link), headers: ApiServices.headers);
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

  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
      String link, Map<String, dynamic> data) async {
    try {
      log('POST URL: $link');
      log('POST Data: ${jsonEncode(data)}');

      var res =
          await client.post(Uri.parse(link), headers: ApiServices.headers, body: jsonEncode(data));

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

  Future<Either<StatusRequest, Map<String, dynamic>>> getDataWithToken(
      String link, String token) async {
    try {
      var res = await client.get(Uri.parse(link), headers: ApiServices.headersWithToken(token));

      log('GET with Token Response Status: ${res.statusCode}');
      log('GET with Token Response Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = jsonDecode(res.body);
        return Right(resBody);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('GET with Token Error: $e');
      return const Left(StatusRequest.failure);
    }
  }

  Future<Either<StatusRequest, String>> getDataAsString(String link) async {
    try {
      var res = await client.get(Uri.parse(link), headers: ApiServices.headers);
      log('GET String Response Status: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        var resBody = res.body;
        return Right(resBody);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      log('GET String Error: $e');
      return const Left(StatusRequest.serverfailure);
    }
  }
}


// // lib/services/api/post_get_api.dart

// import 'dart:convert';
// import 'dart:developer';
// import 'package:auth_app/classes/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;

// class PostGetPage {
  
//   // GET request
//   Future<Either<StatusRequest, Map<String, dynamic>>> getData(String link) async {
//     try {
//       String token = Preferences.getString(Preferences.token);
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };
      
//       if (token.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $token';
//       }
      
//       var response = await http.get(
//         Uri.parse(link),
//         headers: headers,
//       );
      
//       log('GET Response Status: ${response.statusCode}');
//       log('GET Response Body: ${response.body}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       } else if (response.statusCode == 401) {
//         return const Left(StatusRequest.unauthorized);
//       } else if (response.statusCode == 422) {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody); // إرجاع أخطاء التحقق
//       } else if (response.statusCode >= 500) {
//         return const Left(StatusRequest.serverfailure);
//       } else {
//         return const Left(StatusRequest.failure);
//       }
//     } catch (e) {
//       log('GET Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   // POST request
//   Future<Either<StatusRequest, Map<String, dynamic>>> postData(
//       String link, Map<String, dynamic> data) async {
//     try {
//       String token = Preferences.getString(Preferences.token);
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };
      
//       if (token.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $token';
//       }
      
//       log('POST URL: $link');
//       log('POST Data: ${jsonEncode(data)}');
//       log('POST Headers: $headers');
      
//       var response = await http.post(
//         Uri.parse(link),
//         headers: headers,
//         body: jsonEncode(data),
//       );
      
//       log('POST Response Status: ${response.statusCode}');
//       log('POST Response Body: ${response.body}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       } else if (response.statusCode == 401) {
//         return const Left(StatusRequest.unauthorized);
//       } else if (response.statusCode == 422) {
//         // أخطاء التحقق من البيانات
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       } else if (response.statusCode >= 500) {
//         return const Left(StatusRequest.serverfailure);
//       } else {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       }
//     } catch (e) {
//       log('POST Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   // POST request with custom headers
//   Future<Either<StatusRequest, Map<String, dynamic>>> postDataWithHeaders(
//       String link, Map<String, dynamic> data, Map<String, String> customHeaders) async {
//     try {
//       log('POST URL: $link');
//       log('POST Data: ${jsonEncode(data)}');
//       log('POST Headers: $customHeaders');
      
//       var response = await http.post(
//         Uri.parse(link),
//         headers: customHeaders,
//         body: jsonEncode(data),
//       );
      
//       log('POST Response Status: ${response.statusCode}');
//       log('POST Response Body: ${response.body}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       } else if (response.statusCode == 401) {
//         return const Left(StatusRequest.unauthorized);
//       } else if (response.statusCode == 422) {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       } else if (response.statusCode >= 500) {
//         return const Left(StatusRequest.serverfailure);
//       } else {
//         var responseBody = jsonDecode(response.body);
//         return Right(responseBody);
//       }
//     } catch (e) {
//       log('POST Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }

//   // GET request as string
//   Future<Either<StatusRequest, String>> getDataAsString(String link) async {
//     try {
//       String token = Preferences.getString(Preferences.token);
//       Map<String, String> headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };
      
//       if (token.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $token';
//       }
      
//       var response = await http.get(
//         Uri.parse(link),
//         headers: headers,
//       );
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return Right(response.body);
//       } else if (response.statusCode == 401) {
//         return const Left(StatusRequest.unauthorized);
//       } else if (response.statusCode >= 500) {
//         return const Left(StatusRequest.serverfailure);
//       } else {
//         return const Left(StatusRequest.failure);
//       }
//     } catch (e) {
//       log('GET String Error: $e');
//       return const Left(StatusRequest.offlinefailure);
//     }
//   }
// }
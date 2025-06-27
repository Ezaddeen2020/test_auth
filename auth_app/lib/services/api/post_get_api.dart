// // services/api/post_get_api.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';

// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/io_client.dart'; // ملاحظة: غيرنا استيراد http العادي
// // import 'package:http/http.dart' as http;

// class PostGetPage {
//   late IOClient client;

//   PostGetPage() {
//     final ioc = HttpClient()
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true; // تجاوز الشهادة

//     client = IOClient(ioc);
//   }

//   Future<Either<StatusRequest, Map<String, dynamic>>> getData(String link) async {
//     try {
//       var res = await client.get(Uri.parse(link), headers: ApiServices.headers);
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

//   Future<Either<StatusRequest, Map<String, dynamic>>> getDataWithToken(
//       String link, String token) async {
//     try {
//       var res = await client.get(Uri.parse(link), headers: ApiServices.headersWithToken(token));

//       log('GET with Token Response Status: ${res.statusCode}');
//       log('GET with Token Response Body: ${res.body}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = jsonDecode(res.body);
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('GET with Token Error: $e');
//       return const Left(StatusRequest.failure);
//     }
//   }

//   Future<Either<StatusRequest, String>> getDataAsString(String link) async {
//     try {
//       var res = await client.get(Uri.parse(link), headers: ApiServices.headers);
//       log('GET String Response Status: ${res.statusCode}');

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         var resBody = res.body;
//         return Right(resBody);
//       } else {
//         return const Left(StatusRequest.serverfailure);
//       }
//     } catch (e) {
//       log('GET String Error: $e');
//       return const Left(StatusRequest.serverfailure);
//     }
//   }
// }

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

  // Future<Either<StatusRequest, Map<String, dynamic>>> getDataWithToken(
  //     String link, String token) async {
  Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
    try {
      print("\n=== 📡 FULL REQUEST DEBUG ===");
      print("URL: $link");
      print("Token: $token");
      print("Headers: ${ApiServices.headersWithToken(token)}");
      print("Timestamp: ${DateTime.now()}");
      print("========================");

      var res = await client.get(Uri.parse(link), headers: ApiServices.headersWithToken(token));

      print("\n=== 📥 RESPONSE DEBUG ===");
      print("Status Code: ${res.statusCode}");
      print("Response Body: ${res.body}");
      print("========================\n");

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
}

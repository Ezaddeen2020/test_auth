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

//================================================================================================//
  Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
    try {
      var res = await client.get(Uri.parse(link), headers: ApiServices.headersWithToken(token));

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



// import 'dart:convert';
// import 'dart:developer';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:dartz/dartz.dart';
// import 'package:http/http.dart' as http;

// class PostGetPage {
//   late http.Client client;

//   PostGetPage() {
//     // ✅ استخدام http.Client مباشرة بدون تخطي الشهادات
//     client = http.Client();
//   }

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

// //================================================================================================//
//   Future<Either<StatusRequest, dynamic>> getDataWithToken(String link, String token) async {
//     try {
//       var res = await client.get(
//         Uri.parse(link),
//         headers: ApiServices.headersWithToken(token),
//       );

//       log('GET URL: $link');
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
// }


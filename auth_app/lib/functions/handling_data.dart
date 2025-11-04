import 'dart:developer';

import 'package:auth_app/functions/status_request.dart';
import 'package:dartz/dartz.dart';

void logMessage(String tag, String message) {
  log('$tag: $message');
}

Future<Map<String, dynamic>> handleEitherResult(
  Future<Either<StatusRequest, dynamic>> future,
  String successTag,
  String failureMessage,
) async {
  try {
    final result = await future;
    return result.fold(
      (failure) {
        logMessage('API Error', failure.toString());
        
        // إذا كان الخطأ بسبب انتهاء صلاحية التوكن
        if (failure == StatusRequest.unauthorized) {
          return {
            'status': 'unauthorized',
            'message': 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
          };
        }
        
        return {
          'status': 'failure',
          'message': failureMessage,
        };
      },
      (data) {
        logMessage(successTag, data.toString());
        return {
          'status': 'success',
          'data': data,
        };
      },
    );
  } catch (e) {
    logMessage('API Exception', e.toString());
    return {'status': 'failure', 'message': 'حدث خطأ غير متوقع'};
  }
}

// تحويل استجابة Map إلى StatusRequest
StatusRequest handleResult(Map<String, dynamic> response) {
  if (response['status'] == 'failure') {
    return StatusRequest.failure;
  } else {
    return StatusRequest.success;
  }
}

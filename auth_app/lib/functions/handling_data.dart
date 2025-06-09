import 'package:auth_app/functions/status_request.dart';

handlingData(response) {
  // if the type is from StatusRequest(left) otherwise it return the Map(Right)
  if (response is StatusRequest) {
    return response;
  } else {
    return StatusRequest.success;
  }
}


// lib/classes/handling_data.dart

// import 'status_request.dart';

// StatusRequest handlingData(response) {
//   if (response is StatusRequest) {
//     return response;
//   } else if (response is Map<String, dynamic>) {
//     // التحقق من وجود مفاتيح النجاح
//     if (response.containsKey('user') || 
//         response.containsKey('token') || 
//         response.containsKey('message')) {
//       return StatusRequest.success;
//     }
//     // التحقق من وجود أخطاء
//     else if (response.containsKey('errors') || 
//              response.containsKey('error')) {
//       return StatusRequest.failure;
//     }
//     // إذا كانت الاستجابة فارغة أو غير متوقعة
//     else {
//       return StatusRequest.failure;
//     }
//   } else {
//     return StatusRequest.failure;
//   }
// }
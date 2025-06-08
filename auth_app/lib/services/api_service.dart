// class ApiServices {
//   static String server = "http://192.168.187.143";

//   static const headers = {'Accept': '*/*', 'Content-type': 'application/json'};

//   static String login = "$server/index.php?act=login";
//   static String register = "$server/index.php?act=register";
//   static String logout = "$server/index.php?act=logout";
// }

// services/api_service.dart
class ApiServices {
  // تحديث الخادم الرئيسي
  static String server = "https://qitaf3.dynalias.net:44322";

  static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

  // Authentication endpoints
  static String login = "$server/api/Account/login";
  static String register = "$server/api/Account/register";

  // Test endpoints
  static String test = "$server/api/SalesDataVTec/Test";
  static String echo = "$server/echo/api/StockSAPWPOS1";

  // Stock endpoints - الروابط الجديدة
  static String stockInfo(String stockCode) => "$server/echo/api/StockSAPWPOS1/$stockCode";
  static String salesData = "$server/api/SalesDataVTec";
  static String salesDataTest = "$server/api/SalesDataVTec/Test";

  // Headers مع Bearer Token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Headers مع Content-Type مختلف إذا لزم الأمر
  static Map<String, String> headersWithTokenAndForm(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token',
    };
  }
}

// // lib/services/api_service.dart

// class ApiServices {
//   // Base URL - تأكد من تغيير هذا إلى عنوان الخادم الخاص بك
//   static const String baseUrl = "http://10.0.2.2:8000/api"; // للمحاكي
//   // static const String baseUrl = "http://192.168.1.100:8000/api"; // للجهاز الحقيقي
//   // static const String baseUrl = "https://yourserver.com/api"; // للخادم المباشر

//   // Auth endpoints
//   static const String login = "$baseUrl/login";
//   static const String register = "$baseUrl/register";
//   static const String logout = "$baseUrl/logout";
//   static const String verifyEmail = "$baseUrl/verify-email";
//   static const String resendVerification = "$baseUrl/resend-verification";
//   static const String forgotPassword = "$baseUrl/forgot-password";
//   static const String resetPassword = "$baseUrl/reset-password";

//   // User endpoints
//   static const String profile = "$baseUrl/user";
//   static const String updateProfile = "$baseUrl/user/update";

//   // Default headers
//   static Map<String, String> get headers => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   // Headers with token
//   static Map<String, String> headersWithToken(String token) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $token',
//   };
// }
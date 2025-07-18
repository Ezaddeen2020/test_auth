class ApiServices {
  // أضف /echo في الـ base URL
  static String server = "https://qitaf3.dynalias.net:44322/echo";

  static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

  // Authentication endpoints
  static String login = "$server/api/Account/login";
  static String register = "$server/api/Account/register";
  static String testApi = "$server/api/SalesDataVTec/Test";
  static String getStockItem(String code) {
    return "$server/api/StockSAPWPOS1/$code";
  }

  // Headers مع Bearer Token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}





// // services/api_service.dart
// class ApiServices {
//   // تحديث الخادم الرئيسي
//   static String server = "https://qitaf3.dynalias.net:44322";
//   static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

//   // Authentication endpoints
//   static String login = "$server/api/Account/login";
//   static String register = "$server/api/Account/register";

//   // Test endpoints
//   // static String test = "$server/api/SalesDataVTec/Test";
//   // static String echo = "$server/echo/api/StockSAPWPOS1";

//   // // Stock endpoints - الروابط الجديدة
//   // static String stockInfo(String stockCode) => "$server/echo/api/StockSAPWPOS1/$stockCode";
//   // static String salesData = "$server/api/SalesDataVTec";
//   // static String salesDataTest = "$server/api/SalesDataVTec/Test";

//   // Headers مع Bearer Token
//   static Map<String, String> headersWithToken(String token) {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // Headers مع Content-Type مختلف إذا لزم الأمر
//   static Map<String, String> headersWithTokenAndForm(String token) {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/x-www-form-urlencoded',
//       'Authorization': 'Bearer $token',
//     };
//   }
// }

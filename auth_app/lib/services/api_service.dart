// class ApiServices {
//   // أضف /echo في الـ base URL
//   static String server = "https://qitaf3.dynalias.net:44322/echo";

//   static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

//   // Authentication endpoints
//   static String login = "$server/api/Account/login";
//   static String register = "$server/api/Account/register";
//   static String testApi = "$server/api/SalesDataVTec/Test";

//   // Stock endpoints
//   static String getStockItem(String code) {
//     return "$server/api/StockSAPWPOS1/$code";
//   }

//   // Transfer endpoints
//   static String getTransfersList(int page, int pageSize) {
//     return "$server/api/TransferApi/TransfersList?page=$page&pageSize=$pageSize";
//   }

//   static String getTransferDetails(int transferId) {
//     return "$server/api/TransferApi/TransferDetails/$transferId";
//   }

//   static String sendTransfer() {
//     return "$server/api/TransferApi/SendTransfer";
//   }

//   static String receiveTransfer() {
//     return "$server/api/TransferApi/ReceiveTransfer";
//   }

//   static String postTransferToSAP() {
//     return "$server/api/TransferApi/PostToSAP";
//   }

//   static String createTransfer() {
//     return "$server/api/TransferApi/CreateTransfer";
//   }

//   static String searchTransfers(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/TransferApi/SearchTransfers?$queryString";
//   }

//   // أو إذا كنت تستخدم نمط آخر:
//   static String getTransferDetailsEndpoint(int transferId) {
//     return "/api/TransferApi/transfer-details?id=$transferId";
//   }

//   // Headers مع Bearer Token
//   static Map<String, String> headersWithToken(String token) {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }
// }

// services/api_service.dart - Updated Version

class ApiServices {
  // أضف /echo في الـ base URL
  static String server = "https://qitaf3.dynalias.net:44322/echo";

  static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

  // Authentication endpoints
  static String login = "$server/api/Account/login";
  static String register = "$server/api/Account/register";
  static String testApi = "$server/api/SalesDataVTec/Test";

  // Stock endpoints
  static String getStockItem(String code) {
    return "$server/api/StockSAPWPOS1/$code";
  }

  // Transfer endpoints
  static String getTransfersList(int page, int pageSize) {
    return "$server/api/TransferApi/TransfersList?page=$page&pageSize=$pageSize";
  }

  // دالة محدثة لجلب تفاصيل التحويل - ديناميكي
  static String getTransferDetails(int transferId) {
    return "$server/api/TransferApi/transfer-details?id=$transferId";
  }

  static String sendTransfer() {
    return "$server/api/TransferApi/SendTransfer";
  }

  static String receiveTransfer() {
    return "$server/api/TransferApi/ReceiveTransfer";
  }

  static String postTransferToSAP() {
    return "$server/api/TransferApi/PostToSAP";
  }

  static String createTransfer() {
    return "$server/api/TransferApi/CreateTransfer";
  }

  static String searchTransfers(Map<String, dynamic> params) {
    String queryString =
        params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
    return "$server/api/TransferApi/SearchTransfers?$queryString";
  }

  // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
  static String upsertTransferLine() {
    return "$server/api/TransferApi/UpsertLine";
  }

  // حذف سطر تحويل
  static String deleteTransferLine() {
    return "$server/api/TransferApi/DeleteLine";
  }

  static Map<String, String> headersWithToken(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

// services/api_service.dart - Updated Version

// class ApiServices {
//   // أضف /echo في الـ base URL
//   static String server = "https://qitaf3.dynalias.net:44322/echo";

//   static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

//   // Authentication endpoints
//   static String login = "$server/api/Account/login";
//   static String register = "$server/api/Account/register";
//   static String testApi = "$server/api/SalesDataVTec/Test";

//   // Stock endpoints
//   static String getStockItem(String code) {
//     return "$server/api/StockSAPWPOS1/$code";
//   }

//   // Transfer endpoints
//   static String getTransfersList(int page, int pageSize) {
//     return "$server/api/TransferApi/TransfersList?page=$page&pageSize=$pageSize";
//   }

//   // دالة محدثة لجلب تفاصيل التحويل - ديناميكي
//   static String getTransferDetails(int transferId) {
//     return "$server/api/TransferApi/transfer-details?id=$transferId";
//   }

//   static String sendTransfer() {
//     return "$server/api/TransferApi/SendTransfer";
//   }

//   static String receiveTransfer() {
//     return "$server/api/TransferApi/ReceiveTransfer";
//   }

//   static String postTransferToSAP() {
//     return "$server/api/TransferApi/PostToSAP";
//   }

//   static String createTransfer() {
//     return "$server/api/TransferApi/CreateTransfer";
//   }

//   static String searchTransfers(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/TransferApi/SearchTransfers?$queryString";
//   }
//     // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
//   static String upsertTransferLine() {
//     return "$server/api/TransferApi/UpsertLine";
//   }

//    // حذف سطر تحويل
//   static String deleteTransferLine() {
//     return "$server/api/TransferApi/DeleteLine";
//   }

//   // Headers مع Bearer Token
//   static Map<String, String> headersWithToken(String token) {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }
// }


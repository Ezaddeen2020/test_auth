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

//   // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
//   static String upsertTransferLine() {
//     return "$server/api/TransferApi/UpsertLine";
//   }

//   // حذف سطر تحويل
//   static String deleteTransferLine() {
//     return "$server/api/TransferApi/DeleteLine";
//   }

//   // تحديث معلومات التحويل (الهيدر)
//   static String updateTransferHeader() {
//     return "$server/api/TransferApi/UpdateHeader";
//   }

//   // الحصول على الوحدات المتاحة لصنف معين
//   static String getItemUnits(String itemCode) {
//     return "$server/api/Items/Units/$itemCode";
//   }

//   // البحث عن الأصناف
//   static String searchItems(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/Items/Search?$queryString";
//   }

//   // الحصول على معلومات صنف معين
//   static String getItemDetails(String itemCode) {
//     return "$server/api/Items/Details/$itemCode";
//   }

//   // التحقق من كمية المخزون المتاحة
//   static String checkStockQuantity(String itemCode, String warehouseCode) {
//     return "$server/api/Stock/Check?itemCode=$itemCode&warehouseCode=$warehouseCode";
//   }

//   // إلغاء التحويل
//   static String cancelTransfer() {
//     return "$server/api/TransferApi/Cancel";
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

// محدث: api_service.dart - إصلاح endpoints الوحدات

// class ApiServices {
//   static String server = "https://qitaf3.dynalias.net:44322/echo";
//   static const headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

//   // ... باقي الكود كما هو ...

//   /// 🔧 تم تحديث endpoint جلب الوحدات - الإصدار المحدث
//   /// يجب تجريب هذه الـ endpoints حسب الأولوية
//   static String getItemUnits(String itemCode) {
//     // الـ endpoint الأساسي المحتمل (من التحويلات)
//     return "$server/api/TransferApi/ItemUnits/$itemCode";
//   }

//   /// 🔧 endpoints بديلة للوحدات - يجب تجريبها بالترتيب

//   // البديل الأول: من قسم الأصناف
//   // static String getItemUnitsFromItems(String itemCode) {
//   //   return "$server/api/Items/Units/$itemCode";
//   // }

//   // // البديل الثاني: من قسم المخزون
//   // static String getItemUnitsFromStock(String itemCode) {
//   //   return "$server/api/StockSAPWPOS1/Units/$itemCode";
//   // }

//   // // البديل الثالث: مع query parameter
//   // static String getItemUnitsWithQuery(String itemCode) {
//   //   return "$server/api/TransferApi/GetItemUnits?itemCode=${Uri.encodeComponent(itemCode)}";
//   // }

//   // // البديل الرابع: مع code parameter
//   // static String getItemUnitsWithCode(String itemCode) {
//   //   return "$server/api/TransferApi/ItemUnits?code=${Uri.encodeComponent(itemCode)}";
//   // }

//   // // البديل الخامس: endpoint عام للوحدات
//   // static String getUnits(String itemCode) {
//   //   return "$server/api/Units/$itemCode";
//   // }

//   // // البديل السادس: في حالة كان الـ endpoint يتطلب POST بدلاً من GET
//   // static String getItemUnitsPost() {
//   //   return "$server/api/TransferApi/GetItemUnits";
//   // }

//   // /// دالة لإرجاع جميع الـ endpoints المحتملة للوحدات
//   // static List<String> getAllUnitEndpoints(String itemCode) {
//   //   return [
//   //     getItemUnits(itemCode),
//   //     getItemUnitsFromItems(itemCode),
//   //     getItemUnitsFromStock(itemCode),
//   //     getItemUnitsWithQuery(itemCode),
//   //     getItemUnitsWithCode(itemCode),
//   //     getUnits(itemCode),
//   //   ];
//   // }

// //  static String getItemUnits(String itemCode) {
// //     // الـ endpoint الأساسي المحتمل (من التحويلات)
// //     return "$server/api/TransferApi/ItemUnits/$itemCode";
// //   }

//   /// 🔧 endpoints بديلة للوحدات - يجب تجريبها بالترتيب

//   // البديل الأول: من قسم الأصناف
//   static String getItemUnitsFromItems(String itemCode) {
//     return "$server/api/Items/Units/$itemCode";
//   }

//   // البديل الثاني: من قسم المخزون
//   static String getItemUnitsFromStock(String itemCode) {
//     return "$server/api/StockSAPWPOS1/Units/$itemCode";
//   }

//   // البديل الثالث: مع query parameter
//   static String getItemUnitsWithQuery(String itemCode) {
//     return "$server/api/TransferApi/GetItemUnits?itemCode=${Uri.encodeComponent(itemCode)}";
//   }

//   // البديل الرابع: مع code parameter
//   static String getItemUnitsWithCode(String itemCode) {
//     return "$server/api/TransferApi/ItemUnits?code=${Uri.encodeComponent(itemCode)}";
//   }

//   // البديل الخامس: endpoint عام للوحدات
//   static String getUnits(String itemCode) {
//     return "$server/api/Units/$itemCode";
//   }

//   // البديل السادس: في حالة كان الـ endpoint يتطلب POST بدلاً من GET
//   static String getItemUnitsPost() {
//     return "$server/api/TransferApi/GetItemUnits";
//   }

//   /// دالة لإرجاع جميع الـ endpoints المحتملة للوحدات
//   static List<String> getAllUnitEndpoints(String itemCode) {
//     return [
//       getItemUnits(itemCode),
//       getItemUnitsFromItems(itemCode),
//       getItemUnitsFromStock(itemCode),
//       getItemUnitsWithQuery(itemCode),
//       getItemUnitsWithCode(itemCode),
//       getUnits(itemCode),
//     ];
//   }

//   /// دالة للحصول على الـ endpoint الأكثر احتمالاً للعمل
//   /// بناءً على التجربة والاختبار
//   static String getPreferredUnitEndpoint(String itemCode) {
//     // يمكن تغيير هذا بناءً على أي endpoint يعمل بالفعل
//     return getItemUnits(itemCode);
//   }

//   //   // البحث عن الأصناف
//   static String searchItems(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/Items/Search?$queryString";
//   }

//     static String updateTransferHeader() {
//     return "$server/api/TransferApi/UpdateHeader";
//   }

// //   static String receiveTransfer() {
// //     return "$server/api/TransferApi/ReceiveTransfer";
// //   }

//   /// دالة للحصول على الـ endpoint الأكثر احتمالاً للعمل
//   // /// بناءً على التجربة والاختبار
//   // static String getPreferredUnitEndpoint(String itemCode) {
//   //   // يمكن تغيير هذا بناءً على أي endpoint يعمل بالفعل
//   //   return getItemUnits(itemCode);
//   // }

//   // Transfer endpoints
//   static String getTransfersList(int page, int pageSize) {
//     return "$server/api/TransferApi/TransfersList?page=$page&pageSize=$pageSize";
//   }

//   // دالة محدثة لجلب تفاصيل التحويل - ديناميكي
//   static String getTransferDetails(int transferId) {
//     return "$server/api/TransferApi/transfer-details?id=$transferId";
//   }

//     static String createTransfer() {
//     return "$server/api/TransferApi/CreateTransfer";
//   }

// //   // حذف سطر تحويل
//   static String deleteTransferLine() {
//     return "$server/api/TransferApi/DeleteLine";
//   }

//   static String searchTransfers(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/TransferApi/SearchTransfers?$queryString";
//   }

//   static String postTransferToSAP() {
//     return "$server/api/TransferApi/PostToSAP";
//   }

//   // الحصول على معلومات صنف معين
//   static String getItemDetails(String itemCode) {
//     return "$server/api/Items/Details/$itemCode";
//   }

//   // التحقق من كمية المخزون المتاحة
//   static String checkStockQuantity(String itemCode, String warehouseCode) {
//     return "$server/api/Stock/Check?itemCode=$itemCode&warehouseCode=$warehouseCode";
//   }

//   // إلغاء التحويل
//   static String cancelTransfer() {
//     return "$server/api/TransferApi/Cancel";
//   }

//   static String sendTransfer() {
//     return "$server/api/TransferApi/SendTransfer";
//   }

//   static String receiveTransfer() {
//     return "$server/api/TransferApi/ReceiveTransfer";
//   }

//     // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
//   static String upsertTransferLine() {
//     return "$server/api/TransferApi/UpsertLine";
//   }
//   // ... باقي الكود كما هو ...
// }

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

//   // Transfer endpoints - محدث حسب نمط MVC
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

//   // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
//   static String upsertTransferLine() {
//     return "$server/api/TransferApi/UpsertLine";
//   }

//   // حذف سطر تحويل
//   static String deleteTransferLine() {
//     return "$server/api/TransferApi/DeleteLine";
//   }

//   // تحديث معلومات التحويل (الهيدر)
//   static String updateTransferHeader() {
//     return "$server/api/TransferApi/UpdateHeader";
//   }

//   // ============= endpoints الوحدات المصححة - حسب نمط الشركة =============

//   // static String getItemUnits(String itemCode) {
//   //   // النمط المحتمل: Transfer/GetUnits مع POST data
//   //   return "$server/Uom/GetUoms?itemCode=$itemCode";
//   // }

//     static String getItemUnits(String itemCode) {
//     return "$server/Uom/GetUoms?itemCode=${Uri.encodeComponent(itemCode)}";
//   }
// // https://qitaf3.dynalias.net:44322/echo/Uom/GetUoms?itemCode=INV03610
//   /// endpoints بديلة محتملة بناءً على النمط المرئي
//   // static String getItemUnitsAlternative1(String itemCode) {
//   //   // إذا كان يستخدم GET مع parameter
//   //   return "$server/Transfer/GetUnits?itemCode=$itemCode";
//   // }

//   // static String getItemUnitsAlternative2(String itemCode) {
//   //   // إذا كان يستخدم action مختلف
//   //   return "$server/Transfer/GetItemUnits?code=$itemCode";
//   // }

//   static String getItemUnitsAlternative3(String itemCode) {
//     // نمط RESTful
//     return "$server/Transfer/Items/$itemCode/Units";
//   }

//   static String getItemUnitsAlternative4(String itemCode) {
//     // نمط مع route parameter
//     return "$server/Transfer/Units/$itemCode";
//   }

//   /// دالة POST للوحدات - الأكثر احتمالاً
//   static String getItemUnitsPost() {
//     return "$server/Transfer/GetUnits";
//   }

//   /// دالة للحصول على الوحدات مع معرف التحويل
//   static String getItemUnitsWithTransferId(int transferId, String itemCode) {
//     return "$server/Transfer/GetUnits?transferId=$transferId&itemCode=$itemCode";
//   }

//   /// endpoints محتملة أخرى
//   static List<String> getPossibleUnitEndpoints(String itemCode, {int? transferId}) {
//     List<String> endpoints = [
//       // POST endpoints (الأكثر احتمالاً)
//       "$server/Transfer/GetUnits",
//       "$server/Transfer/GetItemUnits",
//       "$server/Transfer/Units",

//       // GET endpoints
//       "$server/Transfer/GetUnits?itemCode=$itemCode",
//       "$server/Transfer/GetItemUnits?code=$itemCode",
//       "$server/Transfer/Units/$itemCode",
//       "$server/Transfer/Items/$itemCode/Units",
//     ];

//     // إضافة endpoints مع transferId إذا كان متوفر
//     if (transferId != null) {
//       endpoints.addAll([
//         "$server/Transfer/GetUnits?transferId=$transferId&itemCode=$itemCode",
//         "$server/Transfer/GetItemUnits?transferId=$transferId&itemCode=$itemCode",
//       ]);
//     }

//     return endpoints;
//   }

//   // /// الـ endpoint الصحيح للوحدات - بناءً على نمط MVC للشركة
//   // static String getItemUnits(String itemCode) {
//   //   // استخدام نمط MVC Controller مثل Transfer/Edit
//   //   return "$server/Transfer/GetItemUnits/$itemCode";
//   // }

//   /// endpoints بديلة مصححة حسب نمط الشركة

//   // البديل الأول: استخدام controller منفصل للوحدات
//   static String getItemUnitsFromItems(String itemCode) {
//     return "$server/Items/GetUnits/$itemCode";
//   }

//   // البديل الثاني: من controller المخزون
//   static String getItemUnitsFromStock(String itemCode) {
//     return "$server/Stock/GetItemUnits/$itemCode";
//   }

//   // البديل الثالث: استخدام action منفصل في Transfer controller
//   static String getItemUnitsFromTransfer(String itemCode) {
//     return "$server/Transfer/Units/$itemCode";
//   }

//   // البديل الرابع: endpoint مع query parameter
//   static String getItemUnitsWithQuery(String itemCode) {
//     return "$server/Transfer/GetUnits?itemCode=${Uri.encodeComponent(itemCode)}";
//   }

//   // البديل الخامس: استخدام API controller (إذا كان موجود)
//   static String getItemUnitsApi(String itemCode) {
//     return "$server/api/Transfer/GetItemUnits/$itemCode";
//   }

//   // البديل السادس: نمط RESTful إذا كان مدعوم
//   static String getItemUnitsRest(String itemCode) {
//     return "$server/api/items/$itemCode/units";
//   }

//   // // البديل السابع: POST request للوحدات
//   // static String getItemUnitsPost() {
//   //   return "$server/Transfer/GetItemUnits";
//   // }

//   // البديل الثامن: endpoint الوحدات العام
//   static String getUnitsGeneral(String itemCode) {
//     return "$server/Units/Get/$itemCode";
//   }

//   /// دالة لإرجاع جميع الـ endpoints المحتملة للوحدات - مصححة
//   static List<String> getAllUnitEndpoints(String itemCode) {
//     return [
//       getItemUnits(itemCode), // Transfer/GetItemUnits/{code}
//       getItemUnitsFromTransfer(itemCode), // Transfer/Units/{code}
//       getItemUnitsWithQuery(itemCode), // Transfer/GetUnits?itemCode={code}
//       getItemUnitsFromItems(itemCode), // Items/GetUnits/{code}
//       getItemUnitsFromStock(itemCode), // Stock/GetItemUnits/{code}
//       getItemUnitsApi(itemCode), // api/Transfer/GetItemUnits/{code}
//       getItemUnitsRest(itemCode), // api/items/{code}/units
//       getUnitsGeneral(itemCode), // Units/Get/{code}
//     ];
//   }

//   /// دالة للحصول على الـ endpoint الأكثر احتمالاً للعمل
//   /// بناءً على نمط الشركة (MVC)
//   static String getPreferredUnitEndpoint(String itemCode) {
//     // الأولوية للـ endpoint الذي يشبه نمط Transfer/Edit
//     return getItemUnits(itemCode); // Transfer/GetItemUnits/{code}
//   }

//   // =============== باقي الـ endpoints مصححة ===============

//   // البحث عن الأصناف - مصحح
//   static String searchItems(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/Items/Search?$queryString";
//   }

//   // الحصول على معلومات صنف معين - مصحح
//   static String getItemDetails(String itemCode) {
//     return "$server/Items/Details/$itemCode";
//   }

//   // التحقق من كمية المخزون المتاحة - مصحح
//   static String checkStockQuantity(String itemCode, String warehouseCode) {
//     return "$server/Stock/CheckQuantity?itemCode=$itemCode&warehouseCode=$warehouseCode";
//   }

//   // إلغاء التحويل
//   static String cancelTransfer() {
//     return "$server/api/TransferApi/Cancel";
//   }

//   // ==================== الدالة المفقودة - Headers مع Token ====================

//   /// Headers مع Bearer Token - الدالة المطلوبة
//   static Map<String, String> headersWithToken(String token) {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // ==================== دوال مساعدة للتشخيص ====================

//   /// دالة لتجريب endpoint معين وإرجاع النتيجة
//   static String testEndpoint(String basePattern, String itemCode, {String? action}) {
//     action = action ?? 'GetItemUnits';
//     return basePattern.replaceAll('{action}', action).replaceAll('{itemCode}', itemCode);
//   }

//   /// دالة لتوليد endpoints محتملة بناءً على الأنماط المختلفة
//   static List<String> generatePossibleEndpoints(String itemCode) {
//     List<String> patterns = [
//       '$server/Transfer/GetItemUnits/$itemCode',
//       '$server/Transfer/Units/$itemCode',
//       '$server/Transfer/GetUnits?itemCode=$itemCode',
//       '$server/api/Transfer/GetItemUnits/$itemCode',
//       '$server/api/Transfer/Units/$itemCode',
//       '$server/Items/GetUnits/$itemCode',
//       '$server/Items/Units/$itemCode',
//       '$server/Stock/GetItemUnits/$itemCode',
//       '$server/Units/Get/$itemCode',
//       '$server/api/items/$itemCode/units',
//     ];

//     return patterns;
//   }
// }

// تحديث ApiServices مع الـ endpoint الصحيح
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

  // Transfer endpoints - محدث حسب نمط MVC
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
    return "https://qitaf3.dynalias.net:44322/echo2/api/TransferApi/DeleteLine";
  }

  // تحديث معلومات التحويل (الهيدر)
  static String updateTransferHeader() {
    return "$server/api/TransferApi/UpdateHeader";
  }

  // ============= الـ endpoint الصحيح للوحدات =============
  static String getItemUnits(String itemCode) {
    return "$server/Uom/GetUoms?itemCode=${Uri.encodeComponent(itemCode)}";
  }

  // البحث عن الأصناف
  static String searchItems(Map<String, dynamic> params) {
    String queryString =
        params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
    return "$server/Items/Search?$queryString";
  }

  // الحصول على معلومات صنف معين
  static String getItemDetails(String itemCode) {
    return "$server/Items/Details/$itemCode";
  }

  // التحقق من كمية المخزون المتاحة
  static String checkStockQuantity(String itemCode, String warehouseCode) {
    return "$server/Stock/CheckQuantity?itemCode=$itemCode&warehouseCode=$warehouseCode";
  }

  // إلغاء التحويل
  static String cancelTransfer() {
    return "$server/api/TransferApi/Cancel";
  }

  // Headers مع Bearer Token
  static Map<String, String> headersWithToken(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== الطرق المفقودة المصححة ====================

  /// دالة لتوليد endpoints محتملة بناءً على الأنماط المختلفة - مُصححة
  static List<String> generatePossibleEndpoints(String itemCode) {
    List<String> patterns = [
      '$server/Uom/GetUoms?itemCode=${Uri.encodeComponent(itemCode)}', // الـ endpoint الصحيح
      '$server/Transfer/GetItemUnits/$itemCode',
      '$server/Transfer/Units/$itemCode',
      '$server/Transfer/GetUnits?itemCode=$itemCode',
      '$server/api/Transfer/GetItemUnits/$itemCode',
      '$server/api/Transfer/Units/$itemCode',
      '$server/Items/GetUnits/$itemCode',
      '$server/Items/Units/$itemCode',
      '$server/Stock/GetItemUnits/$itemCode',
      '$server/Units/Get/$itemCode',
      '$server/api/items/$itemCode/units',
    ];

    return patterns;
  }

  /// دالة للحصول على جميع الـ endpoints المحتملة للوحدات - مُصححة
  static List<String> getAllUnitEndpoints(String itemCode) {
    return [
      getItemUnits(itemCode), // الـ endpoint الصحيح أولاً
      '$server/Transfer/GetItemUnits/$itemCode',
      '$server/Transfer/Units/$itemCode',
      '$server/Transfer/GetUnits?itemCode=$itemCode',
      '$server/Items/GetUnits/$itemCode',
      '$server/Stock/GetItemUnits/$itemCode',
      '$server/api/Transfer/GetItemUnits/$itemCode',
      '$server/api/items/$itemCode/units',
      '$server/Units/Get/$itemCode',
    ];
  }

  /// دالة للحصول على الـ endpoint الأكثر احتمالاً للعمل
  static String getPreferredUnitEndpoint(String itemCode) {
    return getItemUnits(itemCode); // استخدام الـ endpoint الصحيح
  }

  /// دالة POST للوحدات
  static String getItemUnitsPost() {
    return "$server/Uom/GetUoms"; // للـ POST requests
  }

  /// دالة لاختبار endpoint معين
  static String testEndpoint(String basePattern, String itemCode, {String? action}) {
    action = action ?? 'GetUoms';
    return basePattern.replaceAll('{action}', action).replaceAll('{itemCode}', itemCode);
  }
}


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

//   // دالة موحدة لإدارة أسطر التحويل (إضافة/تعديل)
//   static String upsertTransferLine() {
//     return "$server/api/TransferApi/UpsertLine";
//   }

//   // حذف سطر تحويل
//   static String deleteTransferLine() {
//     return "$server/api/TransferApi/DeleteLine";
//   }

//   // تحديث معلومات التحويل (الهيدر)
//   static String updateTransferHeader() {
//     return "$server/api/TransferApi/UpdateHeader";
//   }

//   // 🔧 تم تحديث endpoint جلب الوحدات - تجريب عدة احتمالات
//   static String getItemUnits(String itemCode) {
//     // جرب هذه الـ endpoints المختلفة حتى تجد الصحيح:

//     // الاحتمال الأول: endpoint مباشر للوحدات
//     return "$server/api/TransferApi/ItemUnits/$itemCode";

//     // إذا لم يعمل، جرب هذا:
//     // return "$server/api/Items/Units/$itemCode";

//     // أو هذا:
//     // return "$server/api/StockSAPWPOS1/Units/$itemCode";

//     // أو هذا للوحدات من التحويل:
//     // return "$server/api/TransferApi/GetItemUnits?itemCode=$itemCode";
//   }

//   // 🔧 endpoints بديلة لجلب الوحدات
//   static String getItemUnitsAlternative1(String itemCode) {
//     return "$server/api/Items/Units/$itemCode";
//   }

//   static String getItemUnitsAlternative2(String itemCode) {
//     return "$server/api/StockSAPWPOS1/Units/$itemCode";
//   }

//   static String getItemUnitsAlternative3(String itemCode) {
//     return "$server/api/TransferApi/GetItemUnits?itemCode=$itemCode";
//   }

//   static String getItemUnitsAlternative4(String itemCode) {
//     return "$server/api/TransferApi/ItemUnits?code=$itemCode";
//   }

//   // البحث عن الأصناف
//   static String searchItems(Map<String, dynamic> params) {
//     String queryString =
//         params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}').join('&');
//     return "$server/api/Items/Search?$queryString";
//   }

//   // الحصول على معلومات صنف معين
//   static String getItemDetails(String itemCode) {
//     return "$server/api/Items/Details/$itemCode";
//   }

//   // التحقق من كمية المخزون المتاحة
//   static String checkStockQuantity(String itemCode, String warehouseCode) {
//     return "$server/api/Stock/Check?itemCode=$itemCode&warehouseCode=$warehouseCode";
//   }

//   // إلغاء التحويل
//   static String cancelTransfer() {
//     return "$server/api/TransferApi/Cancel";
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

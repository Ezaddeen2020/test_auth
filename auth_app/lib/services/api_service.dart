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

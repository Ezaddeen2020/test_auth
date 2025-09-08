import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/product/product_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:get/get.dart';

class TransferApi {
  final PostGetPage postGetPage;

  TransferApi(this.postGetPage);

  //====================== جلب قائمة التحويلات مع تقسيم الصفحات =============================== //
  Future<Map<String, dynamic>> getTransfersList({
    int page = 1,
    int pageSize = 20,
  }) async {
    // الحصول على التوكن من التخزين المحلي
    String token = Preferences.getString('auth_token');

    // التحقق من أن المستخدم مسجل الدخول
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    // تسجيل رسالة في سجل الأحداث (لأغراض التتبع)
    logMessage('Transfer', 'Getting transfers list - Page: $page, PageSize: $pageSize');

    // تنفيذ الطلب ومعالجة النتيجة
    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransfersList(page, pageSize),
        token,
      ),
      'Transfers List Retrieved Successfully',
      'فشل في جلب قائمة التحويلات',
    );
  }

  ///////// 🟩 //////////جلب تفاصيل تحويل معين باستخدام transferId
  Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting transfer details for ID: $transferId');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransferDetails(transferId),
        token,
      ),
      'Transfer Details Retrieved Successfully',
      'فشل في جلب تفاصيل التحويل',
    );
  }

  ///// 🟩 ////إرسال تحويل
  Future<Map<String, dynamic>> sendTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Sending transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.sendTransfer(),
        {'transferId': transferId},
        token,
      ),
      'Transfer Sent Successfully',
      'فشل في إرسال التحويل',
    );
  }

  //// 🟩 ///// استلام تحويل
  Future<Map<String, dynamic>> receiveTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Receiving transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.receiveTransfer(),
        {'transferId': transferId},
        token,
      ),
      'Transfer Received Successfully',
      'فشل في استلام التحويل',
    );
  }

  ////// 🟩 /////ترحيل تحويل إلى SAP
  Future<Map<String, dynamic>> postToSAP(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Posting transfer to SAP with ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.postTransferToSAP(),
        {'transferId': transferId},
        token,
      ),
      'Transfer Posted to SAP Successfully',
      'فشل في ترحيل التحويل إلى SAP',
    );
  }

  ///// 🟩 //// البحث عن تحويلات بناءً على معايير متعددة
  Future<Map<String, dynamic>> searchTransfers({
    String? ref,
    String? whscodeFrom,
    String? whscodeTo,
    String? creatby,
    bool? isSended,
    bool? aproveRecive,
    bool? sapPost,
    int page = 1,
    int pageSize = 20,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    // تجهيز المعايير المطلوبة للبحث
    Map<String, dynamic> searchParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (ref != null && ref.isNotEmpty) searchParams['ref'] = ref;
    if (whscodeFrom != null && whscodeFrom.isNotEmpty) searchParams['whscodeFrom'] = whscodeFrom;
    if (whscodeTo != null && whscodeTo.isNotEmpty) searchParams['whscodeTo'] = whscodeTo;
    if (creatby != null && creatby.isNotEmpty) searchParams['creatby'] = creatby;
    if (isSended != null) searchParams['isSended'] = isSended;
    if (aproveRecive != null) searchParams['aproveRecive'] = aproveRecive;
    if (sapPost != null) searchParams['sapPost'] = sapPost;

    logMessage('Transfer', 'Searching transfers with params: $searchParams');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.searchTransfers(searchParams),
        token,
      ),
      'Transfer Search Results Retrieved Successfully',
      'فشل في البحث عن التحويلات',
    );
  }

  /// 🟩 إضافة أو تعديل سطر تحويل - FIXED VERSION
  Future<Map<String, dynamic>> upsertTransferLine({
    required int docEntry,
    int? lineNum, // يمكن أن يكون null للإضافة الجديدة
    required String itemCode,
    required String description,
    required double quantity,
    required double price,
    required double lineTotal,
    required String uomCode,
    String? uomCode2,
    double? invQty,
    int? baseQty1,
    int? ugpEntry,
    int? uomEntry,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    // تجهيز بيانات السطر حسب الاستجابة المطلوبة
    Map<String, dynamic> lineData = {
      'docEntry': docEntry,
      'itemCode': itemCode.trim(),
      'dscription': description.trim(), // تصحيح اسم الحقل حسب النموذج
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'uomCode': uomCode.trim(),
    };

    // إضافة الحقول الاختيارية فقط إذا كانت موجودة
    if (uomCode2 != null && uomCode2.isNotEmpty) {
      lineData['uomCode2'] = uomCode2.trim();
    }

    if (invQty != null) {
      lineData['invQty'] = invQty;
    }

    if (baseQty1 != null) {
      lineData['baseQty1'] = baseQty1;
    }

    if (ugpEntry != null) {
      lineData['ugpEntry'] = ugpEntry;
    }

    if (uomEntry != null) {
      lineData['uomEntry'] = uomEntry;
    }

    // تحديد نوع العملية بناءً على lineNum
    bool isNewLine = lineNum == null || lineNum <= 0;

    if (isNewLine) {
      // للإضافة الجديدة - لا نرسل lineNum أو نرسله كـ 0
      // بعض الـ APIs تتطلب عدم إرسال lineNum للإضافة الجديدة
      logMessage('Transfer', 'Adding new line to docEntry: $docEntry');
    } else {
      // للتعديل - نرسل lineNum الحقيقي
      lineData['lineNum'] = lineNum;
      logMessage('Transfer', 'Updating existing line - docEntry: $docEntry, lineNum: $lineNum');
    }

    try {
      final response = await handleEitherResult(
        postGetPage.postDataWithToken(
          ApiServices.upsertTransferLine(),
          lineData,
          token,
        ),
        isNewLine ? 'Line Added Successfully' : 'Line Updated Successfully',
        isNewLine ? 'فشل في إضافة السطر' : 'فشل في تعديل السطر',
      );

      // معالجة الاستجابة حسب النموذج المرفق
      if (response['status'] == 'success') {
        // التأكد من وجود البيانات المطلوبة في الاستجابة
        final data = response['data'];
        if (data != null) {
          return {
            'status': 'success',
            'message': response['message'],
            'data': {
              'success': true,
              'message': data['message'] ?? (isNewLine ? 'تم الحفظ بنجاح' : 'تم التحديث بنجاح'),
              'docEntry': data['docEntry'] ?? docEntry,
              'lineNum': data['lineNum'], // سيكون الرقم الجديد للإضافة أو نفس الرقم للتعديل
            }
          };
        }
      }

      return response;
    } catch (e) {
      logMessage('Transfer', 'Error in upsertTransferLine: ${e.toString()}');
      return {'status': 'error', 'message': 'حدث خطأ غير متوقع: ${e.toString()}'};
    }
  }

  /// 🟩 حذف سطر تحويل معين
  // Future<Map<String, dynamic>> deleteTransferLine({
  //   required int docEntry,
  //   required int lineNum,
  // }) async {
  //   String token = Preferences.getString('auth_token');
  //   if (token.isEmpty) {
  //     return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
  //   }

  //   Map<String, dynamic> deleteData = {
  //     'docEntry': docEntry,
  //     'lineNum': lineNum,
  //   };

  //   logMessage('Transfer', 'Deleting line with docEntry: $docEntry, lineNum: $lineNum');

  //   return handleEitherResult(
  //     postGetPage.postDataWithToken(
  //       ApiServices.deleteTransferLine(),
  //       deleteData,
  //       token,
  //     ),
  //     'Line Deleted Successfully',
  //     'فشل في حذف السطر',
  //   );
  // }

  Future<Map<String, dynamic>> deleteTransferLine({
    required int docEntry,
    required int lineNum,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> deleteData = {
      'docEntry': docEntry,
      'lineNum': lineNum,
    };

    logMessage(
        'Transfer', 'Deleting line with DELETE method - docEntry: $docEntry, lineNum: $lineNum');

    return handleEitherResult(
      postGetPage.deleteDataWithToken(
        // استخدام DELETE method
        "https://qitaf3.dynalias.net:44322/echo2/api/TransferApi/DeleteLine",
        deleteData,
        token,
      ),
      'Line Deleted Successfully',
      'فشل في حذف السطر',
    );
  }

  /// 🟩 إنشاء تحويل جديد
  Future<Map<String, dynamic>> createTransfer({
    required String whscodeFrom,
    required String whscodeTo,
    String? driverName,
    String? driverCode,
    String? driverMobil,
    String? careNum,
    String? note,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> transferData = {
      'whscodeFrom': whscodeFrom.trim(),
      'whscodeTo': whscodeTo.trim(),
    };

    if (driverName != null && driverName.isNotEmpty) transferData['driverName'] = driverName.trim();
    if (driverCode != null && driverCode.isNotEmpty) transferData['driverCode'] = driverCode.trim();
    if (driverMobil != null && driverMobil.isNotEmpty)
      transferData['driverMobil'] = driverMobil.trim();
    if (careNum != null && careNum.isNotEmpty) transferData['careNum'] = careNum.trim();
    if (note != null && note.isNotEmpty) transferData['note'] = note.trim();

    logMessage('Transfer', 'Creating new transfer: $transferData');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.createTransfer(),
        transferData,
        token,
      ),
      'Transfer Created Successfully',
      'فشل في إنشاء التحويل',
    );
  }

  /// 🟩 تحديث معلومات الهيدر لتحويل معين
  Future<Map<String, dynamic>> updateTransferHeader({
    required int transferId,
    String? driverName,
    String? driverCode,
    String? driverMobil,
    String? careNum,
    String? note,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> updateData = {
      'transferId': transferId,
    };

    if (driverName != null) updateData['driverName'] = driverName.trim();
    if (driverCode != null) updateData['driverCode'] = driverCode.trim();
    if (driverMobil != null) updateData['driverMobil'] = driverMobil.trim();
    if (careNum != null) updateData['careNum'] = careNum.trim();
    if (note != null) updateData['note'] = note.trim();

    logMessage('Transfer', 'Updating transfer header for ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.updateTransferHeader(),
        updateData,
        token,
      ),
      'Transfer Header Updated Successfully',
      'فشل في تحديث معلومات التحويل',
    );
  }

  /// 🟩 جلب الوحدات المتوفرة لصنف معين
  // Future<Map<String, dynamic>> getItemUnits(String itemCode) async {
  //   String token = Preferences.getString('auth_token');
  //   if (token.isEmpty) {
  //     return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
  //   }

  //   logMessage('Transfer', 'Getting units for item: $itemCode');

  //   return handleEitherResult(
  //     postGetPage.getDataWithToken(
  //       ApiServices.getItemUnits(itemCode.trim()),
  //       token,
  //     ),
  //     'Item Units Retrieved Successfully',
  //     'فشل في جلب وحدات الصنف',
  //   );
  // }

  /// 🟩 جلب الوحدات المتوفرة لصنف معين - محدث ومحسن
  /// يستخدم endpoints مصححة حسب نمط MVC للشركة
  /// 🟩 جلب الوحدات المتوفرة لصنف معين - محدث بناءً على نمط الموقع
  Future<Map<String, dynamic>> getItemUnits(String itemCode) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting units for item: $itemCode');

    // استخدام الـ endpoint الصحيح من الاستجابة المقدمة
    String endpoint = "${ApiServices.server}/Uom/GetUoms?itemCode=${Uri.encodeComponent(itemCode)}";

    try {
      return handleEitherResult(
        postGetPage.getDataWithToken(endpoint, token),
        'Item Units Retrieved Successfully',
        'فشل في جلب وحدات الصنف',
      );
    } catch (e) {
      logMessage('Transfer', 'Error getting item units: ${e.toString()}');
      return {'status': 'error', 'message': 'فشل في جلب وحدات الصنف: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> testSpecificEndpoint(String itemCode, String endpoint,
      {Map<String, dynamic>? postData}) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    try {
      logMessage('Transfer', 'Testing specific endpoint: $endpoint');
      logMessage('Transfer', 'POST data: ${postData?.toString() ?? 'None (GET request)'}');

      var response;
      if (postData != null) {
        // POST request
        response = await postGetPage.postDataWithToken(endpoint, postData, token);
      } else {
        // GET request
        response = await postGetPage.getDataWithToken(endpoint, token);
      }

      // تحليل النتيجة بتفصيل أكثر
      return response.fold(
        (failure) {
          logMessage('Transfer', 'Endpoint test failed: $failure');
          return {
            'status': 'error',
            'message': 'فشل الطلب: $failure',
            'endpoint': endpoint,
            'method': postData != null ? 'POST' : 'GET',
          };
        },
        (success) {
          logMessage(
              'Transfer', 'Endpoint test success: ${success.toString().substring(0, 200)}...');
          return {
            'status': 'success',
            'data': success,
            'endpoint': endpoint,
            'method': postData != null ? 'POST' : 'GET',
            'responseSize': success.toString().length,
          };
        },
      );
    } catch (e) {
      logMessage('Transfer', 'Exception testing endpoint $endpoint: ${e.toString()}');
      return {
        'status': 'exception',
        'message': e.toString(),
        'endpoint': endpoint,
        'method': postData != null ? 'POST' : 'GET',
      };
    }
  }

  /// محاولة جلب الوحدات باستخدام POST request (نمط MVC)
  Future<Map<String, dynamic>> _getItemUnitsWithPostMVC(String itemCode, String token) async {
    List<String> postEndpoints = [
      "${ApiServices.server}/Transfer/GetItemUnits",
      "${ApiServices.server}/Transfer/GetUnits",
      "${ApiServices.server}/api/Transfer/GetItemUnits",
      "${ApiServices.server}/Items/GetUnits",
    ];

    for (String endpoint in postEndpoints) {
      try {
        logMessage('Transfer', 'Trying POST to: $endpoint');

        var result = await handleEitherResult(
          postGetPage.postDataWithToken(
            endpoint,
            {'itemCode': itemCode.trim()},
            token,
          ),
          'Item Units Retrieved Successfully via POST',
          'فشل في جلب وحدات الصنف عبر POST',
        );

        if (result['status'] == 'success' && result['data'] != null) {
          logMessage('Transfer', 'POST success from: $endpoint');
          return result;
        }
      } catch (e) {
        logMessage('Transfer', 'POST failed for $endpoint: ${e.toString()}');
        continue;
      }
    }

    return {'status': 'error', 'message': 'جميع POST requests فشلت'};
  }

  /// استخراج الوحدات من بيانات التحويل الموجودة
  /// يستخدم GetX للوصول إلى Controller
  Future<Map<String, dynamic>> _extractUnitsFromTransferData(String itemCode) async {
    try {
      // محاولة الحصول على ProductManagementController إذا كان موجود
      ProductManagementController? controller;
      try {
        controller = Get.find<ProductManagementController>();
      } catch (e) {
        // إذا لم يكن الـ controller موجود، لا نستطيع استخراج البيانات
        logMessage('Transfer', 'ProductManagementController not found, skipping data extraction');
        return {'status': 'error', 'message': 'لا يمكن الوصول إلى بيانات التحويل'};
      }

      // البحث في البيانات المحملة حالياً
      if (controller.transferLines.isNotEmpty) {
        for (TransferLine line in controller.transferLines) {
          if (line.itemCode == itemCode) {
            // إنشاء قائمة وحدات من المعلومات الموجودة
            List<Map<String, dynamic>> extractedUnits = [];

            // الوحدة الأساسية من البيانات الموجودة
            if (line.uomCode != null && line.uomCode!.isNotEmpty) {
              extractedUnits.add({
                'uomCode': line.uomCode,
                'uomName': line.uomCode,
                'baseQty': line.baseQty1 ?? 1,
                'uomEntry': line.uomEntry ?? 1,
                'ugpEntry': line.ugpEntry ?? 1,
              });
            }

            // الوحدة الثانوية إذا كانت مختلفة
            if (line.uomCode2 != null &&
                line.uomCode2!.isNotEmpty &&
                line.uomCode2 != line.uomCode) {
              extractedUnits.add({
                'uomCode': line.uomCode2,
                'uomName': line.uomCode2,
                'baseQty': 1,
                'uomEntry': (line.uomEntry ?? 1) + 1,
                'ugpEntry': line.ugpEntry ?? 1,
              });
            }

            if (extractedUnits.isNotEmpty) {
              logMessage('Transfer',
                  'Extracted ${extractedUnits.length} units from transfer data for $itemCode');
              return {
                'status': 'success',
                'data': extractedUnits,
                'message': 'تم استخراج الوحدات من بيانات التحويل الموجودة'
              };
            }
          }
        }
      }

      return {'status': 'error', 'message': 'لم يتم العثور على الصنف في بيانات التحويل'};
    } catch (e) {
      return {'status': 'error', 'message': 'خطأ في استخراج الوحدات: ${e.toString()}'};
    }
  }

  /// دالة تجريبية لاختبار جميع endpoints الوحدات (محدثة لنمط MVC)
  Future<Map<String, dynamic>> testAllUnitEndpointsMVC(String itemCode) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> results = {};
    List<String> endpoints = ApiServices.generatePossibleEndpoints(itemCode);

    logMessage('Transfer', 'Testing ${endpoints.length} MVC endpoints for item: $itemCode');

    for (int i = 0; i < endpoints.length; i++) {
      try {
        logMessage('Transfer', 'Testing MVC endpoint ${i + 1}: ${endpoints[i]}');

        var result = await postGetPage.getDataWithToken(endpoints[i], token);

        results['mvc_endpoint_${i + 1}'] = {
          'url': endpoints[i],
          'status': result.isRight() ? 'success' : 'error',
          'hasData': result.fold(
            (failure) => false,
            (response) => response != null && response.toString().isNotEmpty,
          ),
          'responseSize': result.fold(
            (failure) => 0,
            (response) => response.toString().length,
          ),
        };

        // إذا نجح endpoint، احفظه كمفضل
        if (result.isRight()) {
          result.fold(
            (failure) => null,
            (response) => {
              if (response != null)
                {
                  results['successful_endpoint'] = endpoints[i],
                  logMessage('Transfer', 'Found working endpoint: ${endpoints[i]}')
                }
            },
          );
        }
      } catch (e) {
        results['mvc_endpoint_${i + 1}'] = {
          'url': endpoints[i],
          'status': 'exception',
          'error': e.toString(),
        };
      }
    }

    return {'status': 'success', 'data': results};
  }

  /// دالة لحفظ الـ endpoint الذي يعمل في الإعدادات المحلية
  void saveWorkingEndpoint(String itemCode, String workingEndpoint) {
    // يمكن حفظ الـ endpoint الذي يعمل للاستخدام المستقبلي
    Preferences.setString('working_units_endpoint_pattern', workingEndpoint);
    logMessage('Transfer', 'Saved working endpoint pattern: $workingEndpoint');
  }

  /// دالة للحصول على الـ endpoint المحفوظ مسبقاً
  String? getSavedWorkingEndpoint(String itemCode) {
    String? savedPattern = Preferences.getString('working_units_endpoint_pattern');
    if (savedPattern.isNotEmpty) {
      // استبدال placeholder بكود الصنف الحقيقي
      return savedPattern.replaceAll(RegExp(r'/[^/]+$'), '/$itemCode');
    }
    return null;
  }

  /// 🟩 البحث عن الأصناف حسب الكود أو الاسم
  Future<Map<String, dynamic>> searchItems({
    String? itemCode,
    String? itemName,
    int page = 1,
    int pageSize = 20,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> searchParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (itemCode != null && itemCode.isNotEmpty) searchParams['itemCode'] = itemCode.trim();
    if (itemName != null && itemName.isNotEmpty) searchParams['itemName'] = itemName.trim();

    logMessage('Transfer', 'Searching items with params: $searchParams');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.searchItems(searchParams),
        token,
      ),
      'Items Search Results Retrieved Successfully',
      'فشل في البحث عن الأصناف',
    );
  }

  Future<Map<String, dynamic>> _getItemUnitsWithPost(String itemCode, String token) async {
    try {
      return await handleEitherResult(
        postGetPage.postDataWithToken(
          ApiServices.getItemUnitsPost(),
          {'itemCode': itemCode.trim()},
          token,
        ),
        'Item Units Retrieved Successfully via POST',
        'فشل في جلب وحدات الصنف عبر POST',
      );
    } catch (e) {
      return {'status': 'error', 'message': 'POST request failed: ${e.toString()}'};
    }
  }

  /// دالة تجريبية لاختبار جميع endpoints الوحدات
  /// يمكن استخدامها لمعرفة أي endpoint يعمل
  Future<Map<String, dynamic>> testAllUnitEndpoints(String itemCode) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> results = {};
    List<String> endpoints = ApiServices.getAllUnitEndpoints(itemCode);

    for (int i = 0; i < endpoints.length; i++) {
      try {
        logMessage('Transfer', 'Testing endpoint ${i + 1}: ${endpoints[i]}');

        var result = await postGetPage.getDataWithToken(endpoints[i], token);

        results['endpoint_${i + 1}'] = {
          'url': endpoints[i],
          'status': result.isRight() ? 'success' : 'error',
          'hasData': result.fold(
            (failure) => false,
            (response) => response.data != null && response.data.toString().isNotEmpty,
          ),
        };
      } catch (e) {
        results['endpoint_${i + 1}'] = {
          'url': endpoints[i],
          'status': 'exception',
          'error': e.toString(),
        };
      }
    }

    return {'status': 'success', 'data': results};
  }

  /// 🟩 جلب تفاصيل صنف معين
  Future<Map<String, dynamic>> getItemDetails(String itemCode) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting item details for: $itemCode');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getItemDetails(itemCode.trim()),
        token,
      ),
      'Item Details Retrieved Successfully',
      'فشل في جلب تفاصيل الصنف',
    );
  }

  /// 🟩 التحقق من كمية المخزون المتاحة لصنف في مستودع محدد
  Future<Map<String, dynamic>> checkStockQuantity({
    required String itemCode,
    required String warehouseCode,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Checking stock for item: $itemCode in warehouse: $warehouseCode');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.checkStockQuantity(itemCode.trim(), warehouseCode.trim()),
        token,
      ),
      'Stock Quantity Retrieved Successfully',
      'فشل في جلب كمية المخزون',
    );
  }

  /// 🟩 إلغاء تحويل محدد
  Future<Map<String, dynamic>> cancelTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Cancelling transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.cancelTransfer(),
        {'transferId': transferId},
        token,
      ),
      'Transfer Cancelled Successfully',
      'فشل في إلغاء التحويل',
    );
  }
}


// import 'package:auth_app/functions/handling_data.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:auth_app/services/api_service.dart';

// class TransferApi {
//   final PostGetPage postGetPage;

//   TransferApi(this.postGetPage);

//   // جلب قائمة التحويلات مع Pagination
//   Future<Map<String, dynamic>> getTransfersList({
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting transfers list - Page: $page, PageSize: $pageSize');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getTransfersList(page, pageSize),
//         token,
//       ),
//       'Transfers List Retrieved Successfully',
//       'فشل في جلب قائمة التحويلات',
//     );
//   }

//   // جلب تفاصيل تحويل محدد - محدثة للعمل ديناميكياً مع أي transferId
//   Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting transfer details for ID: $transferId');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getTransferDetails(transferId), // يتم تمرير transferId ديناميكياً
//         token,
//       ),
//       'Transfer Details Retrieved Successfully',
//       'فشل في جلب تفاصيل التحويل',
//     );
//   }

//   // إرسال التحويل
//   Future<Map<String, dynamic>> sendTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Sending transfer with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.sendTransfer(),
//         {'transferId': transferId},
//         token,
//       ),
//       'Transfer Sent Successfully',
//       'فشل في إرسال التحويل',
//     );
//   }

//   // استلام التحويل
//   Future<Map<String, dynamic>> receiveTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Receiving transfer with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.receiveTransfer(),
//         {'transferId': transferId},
//         token,
//       ),
//       'Transfer Received Successfully',
//       'فشل في استلام التحويل',
//     );
//   }

//   // ترحيل إلى SAP
//   Future<Map<String, dynamic>> postToSAP(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Posting transfer to SAP with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.postTransferToSAP(),
//         {'transferId': transferId},
//         token,
//       ),
//       'Transfer Posted to SAP Successfully',
//       'فشل في ترحيل التحويل إلى SAP',
//     );
//   }

//   // البحث في التحويلات
//   Future<Map<String, dynamic>> searchTransfers({
//     String? ref,
//     String? whscodeFrom,
//     String? whscodeTo,
//     String? creatby,
//     bool? isSended,
//     bool? aproveRecive,
//     bool? sapPost,
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> searchParams = {
//       'page': page,
//       'pageSize': pageSize,
//     };

//     if (ref != null && ref.isNotEmpty) searchParams['ref'] = ref;
//     if (whscodeFrom != null && whscodeFrom.isNotEmpty) searchParams['whscodeFrom'] = whscodeFrom;
//     if (whscodeTo != null && whscodeTo.isNotEmpty) searchParams['whscodeTo'] = whscodeTo;
//     if (creatby != null && creatby.isNotEmpty) searchParams['creatby'] = creatby;
//     if (isSended != null) searchParams['isSended'] = isSended;
//     if (aproveRecive != null) searchParams['aproveRecive'] = aproveRecive;
//     if (sapPost != null) searchParams['sapPost'] = sapPost;

//     logMessage('Transfer', 'Searching transfers with params: $searchParams');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.searchTransfers(searchParams),
//         token,
//       ),
//       'Transfer Search Results Retrieved Successfully',
//       'فشل في البحث عن التحويلات',
//     );
//   }

//   // إدارة سطر التحويل (إضافة/تعديل)
//   Future<Map<String, dynamic>> upsertTransferLine({
//     required int docEntry,
//     int? lineNum, // إذا كان null أو 0 أو -1 = إضافة جديدة
//     required String itemCode,
//     required String description,
//     required double quantity,
//     required double price,
//     required double lineTotal,
//     required String uomCode,
//     String? uomCode2,
//     double? invQty,
//     int? baseQty1,
//     int? ugpEntry,
//     int? uomEntry,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     // تحضير البيانات للإرسال
//     Map<String, dynamic> lineData = {
//       'docEntry': docEntry,
//       'itemCode': itemCode,
//       'description': description,
//       'quantity': quantity,
//       'price': price,
//       'lineTotal': lineTotal,
//       'uomCode': uomCode,
//       'uomCode2': uomCode2,
//       'invQty': invQty,
//       'baseQty1': baseQty1,
//       'ugpEntry': ugpEntry,
//       'uomEntry': uomEntry,
//     };

//     // تحديد نوع العملية بناءً على lineNum
//     if (lineNum != null && lineNum > 0) {
//       // عملية تعديل - إضافة lineNum
//       lineData['lineNum'] = lineNum;
//       logMessage('Transfer', 'Updating existing line with lineNum: $lineNum');
//     } else {
//       // عملية إضافة جديدة - عدم إرسال lineNum أو إرسال -1
//       lineData['lineNum'] = -1;
//       logMessage('Transfer', 'Adding new line (lineNum will be generated)');
//     }

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.upsertTransferLine(),
//         lineData,
//         token,
//       ),
//       lineNum != null && lineNum > 0 ? 'Line Updated Successfully' : 'Line Added Successfully',
//       lineNum != null && lineNum > 0 ? 'فشل في تعديل السطر' : 'فشل في إضافة السطر',
//     );
//   }

//   // حذف سطر التحويل
//   Future<Map<String, dynamic>> deleteTransferLine({
//     required int docEntry,
//     required int lineNum,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> deleteData = {
//       'docEntry': docEntry,
//       'lineNum': lineNum,
//     };

//     logMessage('Transfer', 'Deleting line with docEntry: $docEntry, lineNum: $lineNum');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.deleteTransferLine(),
//         deleteData,
//         token,
//       ),
//       'Line Deleted Successfully',
//       'فشل في حذف السطر',
//     );
//   }

//   // إنشاء تحويل جديد
//   Future<Map<String, dynamic>> createTransfer({
//     required String whscodeFrom,
//     required String whscodeTo,
//     String? driverName,
//     String? driverCode,
//     String? driverMobil,
//     String? careNum,
//     String? note,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> transferData = {
//       'whscodeFrom': whscodeFrom,
//       'whscodeTo': whscodeTo,
//     };

//     if (driverName != null && driverName.isNotEmpty) transferData['driverName'] = driverName;
//     if (driverCode != null && driverCode.isNotEmpty) transferData['driverCode'] = driverCode;
//     if (driverMobil != null && driverMobil.isNotEmpty) transferData['driverMobil'] = driverMobil;
//     if (careNum != null && careNum.isNotEmpty) transferData['careNum'] = careNum;
//     if (note != null && note.isNotEmpty) transferData['note'] = note;

//     logMessage('Transfer', 'Creating new transfer: $transferData');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.createTransfer(),
//         transferData,
//         token,
//       ),
//       'Transfer Created Successfully',
//       'فشل في إنشاء التحويل',
//     );
//   }

//   // تحديث معلومات التحويل (الهيدر)
//   Future<Map<String, dynamic>> updateTransferHeader({
//     required int transferId,
//     String? driverName,
//     String? driverCode,
//     String? driverMobil,
//     String? careNum,
//     String? note,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> updateData = {
//       'transferId': transferId,
//     };

//     if (driverName != null) updateData['driverName'] = driverName;
//     if (driverCode != null) updateData['driverCode'] = driverCode;
//     if (driverMobil != null) updateData['driverMobil'] = driverMobil;
//     if (careNum != null) updateData['careNum'] = careNum;
//     if (note != null) updateData['note'] = note;

//     logMessage('Transfer', 'Updating transfer header for ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.updateTransferHeader(),
//         updateData,
//         token,
//       ),
//       'Transfer Header Updated Successfully',
//       'فشل في تحديث معلومات التحويل',
//     );
//   }

//   // الحصول على الوحدات المتاحة لصنف معين
//   Future<Map<String, dynamic>> getItemUnits(String itemCode) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting units for item: $itemCode');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getItemUnits(itemCode),
//         token,
//       ),
//       'Item Units Retrieved Successfully',
//       'فشل في جلب وحدات الصنف',
//     );
//   }

//   // البحث عن الأصناف
//   Future<Map<String, dynamic>> searchItems({
//     String? itemCode,
//     String? itemName,
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> searchParams = {
//       'page': page,
//       'pageSize': pageSize,
//     };

//     if (itemCode != null && itemCode.isNotEmpty) searchParams['itemCode'] = itemCode;
//     if (itemName != null && itemName.isNotEmpty) searchParams['itemName'] = itemName;

//     logMessage('Transfer', 'Searching items with params: $searchParams');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.searchItems(searchParams),
//         token,
//       ),
//       'Items Search Results Retrieved Successfully',
//       'فشل في البحث عن الأصناف',
//     );
//   }

//   // الحصول على معلومات صنف معين
//   Future<Map<String, dynamic>> getItemDetails(String itemCode) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting item details for: $itemCode');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getItemDetails(itemCode),
//         token,
//       ),
//       'Item Details Retrieved Successfully',
//       'فشل في جلب تفاصيل الصنف',
//     );
//   }

//   // التحقق من كمية المخزون المتاحة
//   Future<Map<String, dynamic>> checkStockQuantity({
//     required String itemCode,
//     required String warehouseCode,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Checking stock for item: $itemCode in warehouse: $warehouseCode');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.checkStockQuantity(itemCode, warehouseCode),
//         token,
//       ),
//       'Stock Quantity Retrieved Successfully',
//       'فشل في جلب كمية المخزون',
//     );
//   }

//   // إلغاء التحويل
//   Future<Map<String, dynamic>> cancelTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Cancelling transfer with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(
//         ApiServices.cancelTransfer(),
//         {'transferId': transferId},
//         token,
//       ),
//       'Transfer Cancelled Successfully',
//       'فشل في إلغاء التحويل',
//     );
//   }
// }

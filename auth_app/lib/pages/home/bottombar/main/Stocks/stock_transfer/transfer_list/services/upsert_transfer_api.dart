import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class UpsertTransferApi {
  final PostGetPage postGetPage;
  UpsertTransferApi(this.postGetPage);

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
}

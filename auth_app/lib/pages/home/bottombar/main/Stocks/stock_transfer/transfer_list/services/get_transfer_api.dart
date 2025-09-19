import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api_service.dart';

class GetTransferApi {
  final PostGetPage postGetPage;

  GetTransferApi(this.postGetPage);

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
}

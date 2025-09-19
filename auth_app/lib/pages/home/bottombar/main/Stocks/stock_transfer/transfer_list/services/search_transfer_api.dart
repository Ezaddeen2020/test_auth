import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class SearchTransferApi {
  final PostGetPage postGetPage;
  SearchTransferApi(this.postGetPage);

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
}

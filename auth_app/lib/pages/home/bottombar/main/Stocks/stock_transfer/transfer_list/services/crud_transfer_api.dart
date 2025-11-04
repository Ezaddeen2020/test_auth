import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class CrudTransferApi {
  final PostGetPage postGetPage;
  CrudTransferApi(this.postGetPage);

  Future<Map<String, dynamic>> createTransfer({
    required String whscodeFrom,
    required String whscodeTo,
    String? driverName,
    String? driverCode,
    String? driverMobil,
    String? careNum,
    String? note,
  }) async {
    String token = Preferences.getString(Preferences.token);
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> transferData = {
      'whscodeFrom': whscodeFrom.trim(),
      'whscodeTo': whscodeTo.trim(),
    };

    if (driverName != null && driverName.isNotEmpty) transferData['driverName'] = driverName.trim();
    if (driverCode != null && driverCode.isNotEmpty) transferData['driverCode'] = driverCode.trim();
    if (driverMobil != null && driverMobil.isNotEmpty) {
      transferData['driverMobil'] = driverMobil.trim();
    }
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
    String token = Preferences.getString(Preferences.token);
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
}

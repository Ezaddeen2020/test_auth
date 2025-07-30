// import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
// import 'transfer_controller_base.dart';

// /// الجزء الخاص بالأدوات المساعدة والإحصائيات
// mixin TransferUtilities on TransferControllerBase {
//   // تحديد التحويل المحدد
//   void selectTransfer(TransferModel transfer) {
//     selectedTransfer.value = transfer;
//   }

//   // مسح التحديد
//   void clearSelection() {
//     selectedTransfer.value = null;
//   }

//   // الحصول على قائمة المستودعات الفريدة (للفلاتر)
//   List<String> getUniqueWarehouses() {
//     Set<String> warehouses = {};
//     for (var transfer in transfers) {
//       warehouses.add(transfer.whscodeFrom.trim());
//       warehouses.add(transfer.whscodeTo.trim());
//     }
//     return warehouses.toList()..sort();
//   }

//   // الحصول على إحصائيات التحويلات
//   Map<String, int> getTransferStats() {
//     int pending = transfers.where((t) => !t.isSended).length;
//     int sent = transfers.where((t) => t.isSended && !t.aproveRecive).length;
//     int received = transfers.where((t) => t.aproveRecive && !t.sapPost).length;
//     int posted = transfers.where((t) => t.sapPost).length;

//     return {
//       'pending': pending,
//       'sent': sent,
//       'received': received,
//       'posted': posted,
//       'total': transfers.length,
//     };
//   }
// }

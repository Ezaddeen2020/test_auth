import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/controllers/printer_controller.dart';

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:get/get.dart';

// Binding للـ AuthController
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostGetPage>(() => PostGetPage());
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<PrinterController>(() => PrinterController(), fenix: true);
    Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);
    Get.lazyPut<StockController>(() => StockController(), fenix: true);
    Get.lazyPut<TransferNavigationController>(() => TransferNavigationController(), fenix: true);
    Get.lazyPut<TransferController>(() => TransferController(), fenix: true);
    Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);
  }
}

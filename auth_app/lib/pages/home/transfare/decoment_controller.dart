import 'package:get/get.dart';

class DecomentTransferController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var fromStore = ''.obs;
  var toStore = ''.obs;

  void setDate(DateTime date) {
    // للحفاظ على الوقت عند تغيير التاريخ
    final current = selectedDate.value;
    selectedDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      current.hour,
      current.minute,
    );
  }

  void setFromStore(String store) {
    fromStore.value = store;
  }

  void setToStore(String store) {
    toStore.value = store;
  }

  RxMap<String, bool> statusOptions = <String, bool>{
    'received': false,
    'transferred_accounts': false,
    'loaded': false,
  }.obs;

  void updateStatus(String key, bool value) {
    statusOptions[key] = value;
  }
}

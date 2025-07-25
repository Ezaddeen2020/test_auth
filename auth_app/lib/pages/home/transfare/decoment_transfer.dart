// // import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// // class DecomentTransfer extends StatelessWidget {
// //   DecomentTransfer({super.key});

// //   // final DecomentTransferController controller = Get.put(DecomentTransferController());
// //   final TransferController controller = Get.put(TransferController());
// //   final GlobalKey _fromStoreKey = GlobalKey();
// //   final GlobalKey _toStoreKey = GlobalKey();

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: controller.selectedDate.value,
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2100),
// //       locale: const Locale('ar', ''),
// //     );
// //     if (picked != null) controller.setDate(picked);
// //   }

// //   void _selectStore(
// //       BuildContext context, RxString storeRx, void Function(String) setStore, GlobalKey key) async {
// //     final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
// //     final Offset offset = renderBox.localToGlobal(Offset.zero);
// //     final Size size = renderBox.size;

// //     // جلب أسماء المستودعات من Controller
// //     final warehouseNames = controller.getWarehouseNames();

// //     if (warehouseNames.isEmpty) {
// //       Get.snackbar(
// //         'تنبيه',
// //         'لا توجد مستودعات متاحة',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //       );
// //       return;
// //     }

// //     final selected = await showMenu<String>(
// //       context: context,
// //       position: RelativeRect.fromLTRB(
// //           offset.dx, offset.dy + size.height, offset.dx + size.width, offset.dy),
// //       items: warehouseNames.map((name) =>
// //         PopupMenuItem(value: name, child: Text(name))
// //       ).toList(),
// //     );

// //     if (selected != null) setStore(selected);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: WillPopScope(
// //         onWillPop: () => controller.showExitConfirmation(),
// //         child: Scaffold(
// //           appBar: AppBar(
// //             title: Obx(() => Text(
// //               controller.isEditMode.value
// //                 ? 'تعديل مستند تحويل المخزون'
// //                 : 'مستند تحويل المخزون',
// //             )),
// //             centerTitle: true,
// //             elevation: 0,
// //             actions: [
// //               IconButton(
// //                 icon: const Icon(Icons.refresh),
// //                 onPressed: () => controller.resetForm(),
// //                 tooltip: 'إعادة تعيين',
// //               ),
// //             ],
// //           ),
// //           body: Obx(() {
// //             if (controller.isLoading.value) {
// //               return const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(),
// //                     SizedBox(height: 16),
// //                     Text('جاري التحميل...'),
// //                   ],
// //                 ),
// //               );
// //             }

// //             return SingleChildScrollView(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 children: [
// //                   _buildDateField(context),
// //                   const SizedBox(height: 16),
// //                   _buildStoreRow(context),
// //                   const SizedBox(height: 16),
// //                   ..._buildDriverFields(),
// //                   const SizedBox(height: 20),
// //                   _buildStatusSection(),
// //                   const SizedBox(height: 16),
// //                   _buildNotesField(),
// //                   const SizedBox(height: 20),
// //                   _buildActionButtons(),
// //                 ],
// //               ),
// //             );
// //           }),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDateField(BuildContext context) {
// //     return Card(
// //       elevation: 2,
// //       child: InkWell(
// //         onTap: () => _selectDate(context),
// //         borderRadius: BorderRadius.circular(12),
// //         child: Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey.shade300),
// //           ),
// //           child: Row(
// //             children: [
// //               const Icon(Icons.calendar_today, color: Colors.blue),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text('تاريخ المستند', style: TextStyle(fontSize: 12, color: Colors.grey)),
// //                     Obx(() {
// //                       final d = controller.selectedDate.value;
// //                       String period = d.hour >= 12 ? "م" : "ص";
// //                       int hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
// //                       return Text(
// //                         "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
// //                         "$hour12:${d.minute.toString().padLeft(2, '0')} $period",
// //                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //                       );
// //                     }),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStoreRow(BuildContext context) {
// //     return Row(
// //       children: [
// //         Expanded(
// //             child: _buildStoreField(
// //                 context, 'من مخزن', controller.fromStore, controller.setFromStore, _fromStoreKey)),
// //         const SizedBox(width: 12),
// //         const Icon(Icons.arrow_forward, color: Colors.blue, size: 24),
// //         const SizedBox(width: 12),
// //         Expanded(
// //             child: _buildStoreField(
// //                 context, 'إلى مخزن', controller.toStore, controller.setToStore, _toStoreKey)),
// //       ],
// //     );
// //   }

// //   Widget _buildStoreField(BuildContext context, String hint, RxString storeRx,
// //       void Function(String) setStore, GlobalKey key) {
// //     return Card(
// //       elevation: 2,
// //       child: InkWell(
// //         onTap: () => _selectStore(context, storeRx, setStore, key),
// //         borderRadius: BorderRadius.circular(12),
// //         child: Container(
// //           key: key,
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey.shade300),
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: Obx(() => Text(
// //                       storeRx.value.isEmpty ? hint : storeRx.value,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         color: storeRx.value.isEmpty ? Colors.grey : Colors.black87,
// //                         fontWeight: storeRx.value.isEmpty ? FontWeight.normal : FontWeight.w500,
// //                       ),
// //                     )),
// //               ),
// //               const Icon(Icons.arrow_drop_down, color: Colors.blue),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   List<Widget> _buildDriverFields() {
// //     return [
// //       _buildInputField('اسم السائق', Icons.person, controller.driverNameController),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم السائق', Icons.phone, controller.driverPhoneController,
// //                       textInputType: TextInputType.phone),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم السيارة', Icons.directions_car, controller.carNumberController),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم الاستلام', Icons.receipt, controller.receiptNumberController),
// //     ];
// //   }

// //   Widget _buildInputField(String label, IconData icon, TextEditingController controller,
// //                          {TextInputType? textInputType}) {
// //     return Card(
// //       elevation: 2,
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: textInputType,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           hintText: label,
// //           prefixIcon: Icon(icon, color: Colors.blue),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide.none,
// //           ),
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //         ),
// //         style: const TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //     );
// //   }

// //   Widget _buildStatusSection() {
// //     return Card(
// //       elevation: 2,
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           color: Colors.white,
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               'حالة المستند',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
// //             ),
// //             const SizedBox(height: 12),
// //             _buildCheckboxOption('تم الإرسال', 'loaded'),
// //             _buildCheckboxOption('تم الاستلام', 'received'),
// //             _buildCheckboxOption('مرحل إلى النظام', 'transferred_accounts'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCheckboxOption(String title, String value) {
// //     return Obx(() => CheckboxListTile(
// //           title: Text(
// //             title,
// //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //           ),
// //           value: controller.statusOptions[value] ?? false,
// //           onChanged: (bool? val) => controller.updateStatus(value, val ?? false),
// //           activeColor: Colors.blue,
// //           contentPadding: EdgeInsets.zero,
// //           controlAffinity: ListTileControlAffinity.leading,
// //         ));
// //   }

// //   Widget _buildNotesField() {
// //     return Card(
// //       elevation: 2,
// //       child: TextFormField(
// //         controller: controller.notesController,
// //         maxLines: 4,
// //         decoration: InputDecoration(
// //           labelText: 'الملاحظات',
// //           hintText: 'أدخل ملاحظاتك هنا...',
// //           prefixIcon: const Icon(Icons.note_alt, color: Colors.blue),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide.none,
// //           ),
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //           alignLabelWithHint: true,
// //         ),
// //         style: const TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //     );
// //   }

// //   Widget _buildActionButtons() {
// //     return Column(
// //       children: [
// //         // زر عرض سجل التعديلات (فقط في وضع التحديث)
// //         Obx(() {
// //           if (controller.isEditMode.value) {
// //             return Column(
// //               children: [
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: OutlinedButton.icon(
// //                     onPressed: () => _showEditHistory(Get.context!),
// //                     icon: const Icon(Icons.history, color: Colors.blue),
// //                     label: const Text(
// //                       'عرض سجل التعديلات',
// //                       style: TextStyle(fontSize: 16, color: Colors.blue),
// //                     ),
// //                     style: OutlinedButton.styleFrom(
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       side: const BorderSide(color: Colors.blue, width: 2),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //               ],
// //             );
// //           }
// //           return const SizedBox.shrink();
// //         }),

// //         // زر الحفظ
// //         SizedBox(
// //           width: double.infinity,
// //           child: Obx(() => ElevatedButton.icon(
// //             onPressed: controller.isLoading.value
// //                 ? null
// //                 : () => controller.saveDocument(),
// //             icon: controller.isLoading.value
// //                 ? const SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                       strokeWidth: 2,
// //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                     ),
// //                   )
// //                 : const Icon(Icons.save, color: Colors.white),
// //             label: Text(
// //               controller.isLoading.value
// //                   ? 'جاري الحفظ...'
// //                   : (controller.isEditMode.value ? 'تحديث' : 'حفظ'),
// //               style: const TextStyle(fontSize: 16, color: Colors.white),
// //             ),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: controller.isLoading.value ? Colors.grey : Colors.blue,
// //               padding: const EdgeInsets.symmetric(vertical: 16),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //           )),
// //         ),
// //       ],
// //     );
// //   }

// //   void _showEditHistory(BuildContext context) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) => DraggableScrollableSheet(
// //         initialChildSize: 0.7,
// //         maxChildSize: 0.9,
// //         minChildSize: 0.5,
// //         builder: (context, scrollController) => Container(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             children: [
// //               Container(
// //                 width: 40,
// //                 height: 4,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade300,
// //                   borderRadius: BorderRadius.circular(2),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               const Text(
// //                 'سجل التعديلات',
// //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 16),
// //               Expanded(
// //                 child: ListView.builder(
// //                   controller: scrollController,
// //                   itemCount: 5, // سيتم استبدالها ببيانات حقيقية لاحقاً
// //                   itemBuilder: (context, index) => _buildHistoryItem(index),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHistoryItem(int index) {
// //     final historyData = [
// //       {'action': 'إنشاء المستند', 'user': 'أحمد محمد', 'date': '2025-01-15 10:30 ص'},
// //       {'action': 'تحديث اسم السائق', 'user': 'سارة أحمد', 'date': '2025-01-15 11:15 ص'},
// //       {'action': 'تغيير حالة إلى مستلم', 'user': 'محمد علي', 'date': '2025-01-15 02:20 م'},
// //       {'action': 'إضافة ملاحظات', 'user': 'فاطمة خالد', 'date': '2025-01-15 03:45 م'},
// //       {'action': 'تحديث رقم السيارة', 'user': 'عبدالله سعد', 'date': '2025-01-15 04:10 م'},
// //     ];

// //     final item = historyData[index];
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: Colors.blue.shade100,
// //           child: const Icon(Icons.edit, color: Colors.blue, size: 20),
// //         ),
// //         title: Text(item['action']!, style: const TextStyle(fontWeight: FontWeight.w500)),
// //         subtitle: Text('بواسطة: ${item['user']}'),
// //         trailing: Text(
// //           item['date']!,
// //           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// // class DecomentTransfer extends StatelessWidget {
// //   DecomentTransfer({super.key});

// //   final TransferController controller = Get.put(TransferController());
// //   final GlobalKey _fromStoreKey = GlobalKey();
// //   final GlobalKey _toStoreKey = GlobalKey();

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: controller.selectedDate.value,
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2100),
// //       locale: const Locale('ar', ''),
// //     );
// //     if (picked != null) controller.setDate(picked);
// //   }

// //   void _selectStore(
// //       BuildContext context, RxString storeRx, void Function(String) setStore, GlobalKey key) async {
// //     final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
// //     final Offset offset = renderBox.localToGlobal(Offset.zero);
// //     final Size size = renderBox.size;

// //     // جلب أسماء المستودعات من Controller
// //     final warehouseNames = controller.getWarehouseNames();

// //     if (warehouseNames.isEmpty) {
// //       Get.snackbar(
// //         'تنبيه',
// //         'لا توجد مستودعات متاحة',
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.orange,
// //         colorText: Colors.white,
// //       );
// //       return;
// //     }

// //     final selected = await showMenu<String>(
// //       context: context,
// //       position: RelativeRect.fromLTRB(
// //           offset.dx, offset.dy + size.height, offset.dx + size.width, offset.dy),
// //       items: warehouseNames.map((name) =>
// //         PopupMenuItem(value: name, child: Text(name))
// //       ).toList(),
// //     );

// //     if (selected != null) setStore(selected);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: WillPopScope(
// //         onWillPop: () => controller.showExitConfirmation(),
// //         child: Scaffold(
// //           appBar: AppBar(
// //             title: Obx(() => Text(
// //               controller.isEditMode.value
// //                 ? 'تعديل مستند تحويل المخزون'
// //                 : 'مستند تحويل المخزون',
// //             )),
// //             centerTitle: true,
// //             elevation: 0,
// //             actions: [
// //               IconButton(
// //                 icon: const Icon(Icons.refresh),
// //                 onPressed: () => controller.resetForm(),
// //                 tooltip: 'إعادة تعيين',
// //               ),
// //             ],
// //           ),
// //           body: Obx(() {
// //             if (controller.isLoading.value) {
// //               return const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(),
// //                     SizedBox(height: 16),
// //                     Text('جاري التحميل...'),
// //                   ],
// //                 ),
// //               );
// //             }

// //             return SingleChildScrollView(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 children: [
// //                   _buildDateField(context),
// //                   const SizedBox(height: 16),
// //                   _buildStoreRow(context),
// //                   const SizedBox(height: 16),
// //                   ..._buildDriverFields(),
// //                   const SizedBox(height: 20),
// //                   _buildStatusSection(),
// //                   const SizedBox(height: 16),
// //                   _buildNotesField(),
// //                   const SizedBox(height: 20),
// //                   _buildActionButtons(),
// //                 ],
// //               ),
// //             );
// //           }),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDateField(BuildContext context) {
// //     return Card(
// //       elevation: 2,
// //       child: InkWell(
// //         onTap: () => _selectDate(context),
// //         borderRadius: BorderRadius.circular(12),
// //         child: Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey.shade300),
// //           ),
// //           child: Row(
// //             children: [
// //               const Icon(Icons.calendar_today, color: Colors.blue),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text('تاريخ المستند', style: TextStyle(fontSize: 12, color: Colors.grey)),
// //                     Obx(() {
// //                       final d = controller.selectedDate.value;
// //                       String period = d.hour >= 12 ? "م" : "ص";
// //                       int hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
// //                       return Text(
// //                         "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
// //                         "$hour12:${d.minute.toString().padLeft(2, '0')} $period",
// //                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //                       );
// //                     }),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStoreRow(BuildContext context) {
// //     return Row(
// //       children: [
// //         Expanded(
// //             child: _buildStoreField(
// //                 context, 'من مخزن', controller.fromStore, controller.setFromStore, _fromStoreKey)),
// //         const SizedBox(width: 12),
// //         const Icon(Icons.arrow_forward, color: Colors.blue, size: 24),
// //         const SizedBox(width: 12),
// //         Expanded(
// //             child: _buildStoreField(
// //                 context, 'إلى مخزن', controller.toStore, controller.setToStore, _toStoreKey)),
// //       ],
// //     );
// //   }

// //   Widget _buildStoreField(BuildContext context, String hint, RxString storeRx,
// //       void Function(String) setStore, GlobalKey key) {
// //     return Card(
// //       elevation: 2,
// //       child: InkWell(
// //         onTap: () => _selectStore(context, storeRx, setStore, key),
// //         borderRadius: BorderRadius.circular(12),
// //         child: Container(
// //           key: key,
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: Colors.grey.shade300),
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: Obx(() => Text(
// //                       storeRx.value.isEmpty ? hint : storeRx.value,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         color: storeRx.value.isEmpty ? Colors.grey : Colors.black87,
// //                         fontWeight: storeRx.value.isEmpty ? FontWeight.normal : FontWeight.w500,
// //                       ),
// //                     )),
// //               ),
// //               const Icon(Icons.arrow_drop_down, color: Colors.blue),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   List<Widget> _buildDriverFields() {
// //     return [
// //       _buildInputField('اسم السائق', Icons.person, controller.driverNameController),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم السائق', Icons.phone, controller.driverPhoneController,
// //                       textInputType: TextInputType.phone),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم السيارة', Icons.directions_car, controller.carNumberController),
// //       const SizedBox(height: 16),
// //       _buildInputField('رقم الاستلام', Icons.receipt, controller.receiptNumberController),
// //     ];
// //   }

// //   Widget _buildInputField(String label, IconData icon, TextEditingController controllerField,
// //                          {TextInputType? textInputType}) {
// //     return Card(
// //       elevation: 2,
// //       child: TextFormField(
// //         controller: controllerField,
// //         keyboardType: textInputType,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           hintText: label,
// //           prefixIcon: Icon(icon, color: Colors.blue),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide.none,
// //           ),
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //         ),
// //         style: const TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //     );
// //   }

// //   Widget _buildStatusSection() {
// //     return Card(
// //       elevation: 2,
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           color: Colors.white,
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               'حالة المستند',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
// //             ),
// //             const SizedBox(height: 12),
// //             _buildCheckboxOption('تم الإرسال', 'loaded'),
// //             _buildCheckboxOption('تم الاستلام', 'received'),
// //             _buildCheckboxOption('مرحل إلى النظام', 'transferred_accounts'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCheckboxOption(String title, String value) {
// //     return Obx(() => CheckboxListTile(
// //           title: Text(
// //             title,
// //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //           ),
// //           value: controller.documentStatusOptions[value] ?? false,
// //           onChanged: (bool? val) => controller.updateStatus(value, val ?? false),
// //           activeColor: Colors.blue,
// //           contentPadding: EdgeInsets.zero,
// //           controlAffinity: ListTileControlAffinity.leading,
// //         ));
// //   }

// //   Widget _buildNotesField() {
// //     return Card(
// //       elevation: 2,
// //       child: TextFormField(
// //         controller: controller.notesController,
// //         maxLines: 4,
// //         decoration: InputDecoration(
// //           labelText: 'الملاحظات',
// //           hintText: 'أدخل ملاحظاتك هنا...',
// //           prefixIcon: const Icon(Icons.note_alt, color: Colors.blue),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide.none,
// //           ),
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //           alignLabelWithHint: true,
// //         ),
// //         style: const TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //     );
// //   }

// //   Widget _buildActionButtons() {
// //     return Column(
// //       children: [
// //         // زر عرض سجل التعديلات (فقط في وضع التحديث)
// //         Obx(() {
// //           if (controller.isEditMode.value) {
// //             return Column(
// //               children: [
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: OutlinedButton.icon(
// //                     onPressed: () => _showEditHistory(context),
// //                     icon: const Icon(Icons.history, color: Colors.blue),
// //                     label: const Text(
// //                       'عرض سجل التعديلات',
// //                       style: TextStyle(fontSize: 16, color: Colors.blue),
// //                     ),
// //                     style: OutlinedButton.styleFrom(
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       side: const BorderSide(color: Colors.blue, width: 2),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //               ],
// //             );
// //           }
// //           return const SizedBox.shrink();
// //         }),

// //         // زر الحفظ
// //         SizedBox(
// //           width: double.infinity,
// //           child: Obx(() => ElevatedButton.icon(
// //             onPressed: controller.isLoading.value
// //                 ? null
// //                 : () => controller.saveDocument(),
// //             icon: controller.isLoading.value
// //                 ? const SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                       strokeWidth: 2,
// //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                     ),
// //                   )
// //                 : const Icon(Icons.save, color: Colors.white),
// //             label: Text(
// //               controller.isLoading.value
// //                   ? 'جاري الحفظ...'
// //                   : (controller.isEditMode.value ? 'تحديث' : 'حفظ'),
// //               style: const TextStyle(fontSize: 16, color: Colors.white),
// //             ),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: controller.isLoading.value ? Colors.grey : Colors.blue,
// //               padding: const EdgeInsets.symmetric(vertical: 16),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //           )),
// //         ),
// //       ],
// //     );
// //   }

// //   void _showEditHistory(BuildContext context) {
// //     // جلب البيانات عند فتح النافذة
// //     controller.getTransferHistory();

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) => DraggableScrollableSheet(
// //         initialChildSize: 0.7,
// //         maxChildSize: 0.9,
// //         minChildSize: 0.5,
// //         builder: (context, scrollController) => Container(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             children: [
// //               Container(
// //                 width: 40,
// //                 height: 4,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade300,
// //                   borderRadius: BorderRadius.circular(2),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   const Icon(Icons.history, color: Colors.blue),
// //                   const SizedBox(width: 8),
// //                   const Text(
// //                     'سجل التعديلات',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   const Spacer(),
// //                   Obx(() => controller.isLoadingHistory.value
// //                       ? const SizedBox(
// //                           width: 20,
// //                           height: 20,
// //                           child: CircularProgressIndicator(strokeWidth: 2),
// //                         )
// //                       : Text(
// //                           '${controller.transferHistory.length} عملية',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.grey.shade600,
// //                           ),
// //                         ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               Expanded(
// //                 child: Obx(() {
// //                   if (controller.isLoadingHistory.value) {
// //                     return const Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           CircularProgressIndicator(),
// //                           SizedBox(height: 16),
// //                           Text('جاري تحميل سجل التعديلات...'),
// //                         ],
// //                       ),
// //                     );
// //                   }

// //                   if (controller.transferHistory.isEmpty) {
// //                     return Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(
// //                             Icons.history_outlined,
// //                             size: 60,
// //                             color: Colors.grey.shade400,
// //                           ),
// //                           const SizedBox(height: 16),
// //                           Text(
// //                             'لا يوجد سجل تعديلات',
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               color: Colors.grey.shade600,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Text(
// //                             'لم يتم إجراء أي تعديلات على هذا التحويل حتى الآن',
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               color: Colors.grey.shade500,
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   }

// //                   return ListView.builder(
// //                     controller: scrollController,
// //                     itemCount: controller.transferHistory.length,
// //                     itemBuilder: (context, index) => _buildHistoryItem(
// //                       controller.transferHistory[index]
// //                     ),
// //                   );
// //                 }),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHistoryItem(dynamic historyItem) {
// //     Color actionColor;
// //     IconData actionIcon;

// //     switch (historyItem.actionColor) {
// //       case 'green':
// //         actionColor = Colors.green;
// //         actionIcon = Icons.add_circle_outline;
// //         break;
// //       case 'blue':
// //         actionColor = Colors.blue;
// //         actionIcon = Icons.edit_outlined;
// //         break;
// //       case 'red':
// //         actionColor = Colors.red;
// //         actionIcon = Icons.delete_outline;
// //         break;
// //       case 'orange':
// //         actionColor = Colors.orange;
// //         actionIcon = Icons.send_outlined;
// //         break;
// //       case 'purple':
// //         actionColor = Colors.purple;
// //         actionIcon = Icons.inbox_outlined;
// //         break;
// //       case 'indigo':
// //         actionColor = Colors.indigo;
// //         actionIcon = Icons.upload_outlined;
// //         break;
// //       default:
// //         actionColor = Colors.grey;
// //         actionIcon = Icons.info_outline;
// //     }

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       elevation: 1,
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: actionColor.withOpacity(0.1),
// //           child: Icon(actionIcon, color: actionColor, size: 20),
// //         ),
// //         title: Text(
// //           historyItem.action,
// //           style: const TextStyle(fontWeight: FontWeight.w500),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('بواسطة: ${historyItem.userName}'),
// //             if (historyItem.detailedDescription != historyItem.action)
// //               Padding(
// //                 padding: const EdgeInsets.only(top: 4),
// //                 child: Text(
// //                   historyItem.detailedDescription,
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: Colors.grey.shade600,
// //                     fontStyle: FontStyle.italic,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             Text(
// //               historyItem.formattedDate,
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: Colors.grey.shade600,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: actionColor.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Text(
// //                 historyItem.actionIcon,
// //                 style: TextStyle(fontSize: 10, color: actionColor),
// //               ),
// //             ),
// //           ],
// //         ),
// //         isThreeLine: historyItem.detailedDescription != historyItem.action,
// //       ),
// //     );
// //   }
// // }

// import 'package:auth_app/pages/home/transfare/decoment_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DecomentTransfer extends StatelessWidget {
//   DecomentTransfer({super.key});

//   final DecomentTransferController controller = Get.put(DecomentTransferController());
//   final GlobalKey _fromStoreKey = GlobalKey();
//   final GlobalKey _toStoreKey = GlobalKey();

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: controller.selectedDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       locale: const Locale('ar', ''),
//     );
//     if (picked != null) controller.setDate(picked);
//   }

//   void _selectStore(
//       BuildContext context, RxString storeRx, void Function(String) setStore, GlobalKey key) async {
//     final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
//     final Offset offset = renderBox.localToGlobal(Offset.zero);
//     final Size size = renderBox.size;

//     final selected = await showMenu<String>(
//       context: context,
//       position: RelativeRect.fromLTRB(
//           offset.dx, offset.dy + size.height, offset.dx + size.width, offset.dy),
//       items: List.generate(
//           4, (i) => PopupMenuItem(value: 'مخزن ${i + 1}', child: Text('مخزن ${i + 1}'))),
//     );

//     if (selected != null) setStore(selected);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('  مستند تحويل المخزون'),
//           centerTitle: true,
//           elevation: 0,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               _buildDateField(context),
//               const SizedBox(height: 16),
//               _buildStoreRow(context),
//               const SizedBox(height: 16),
//               ..._buildDriverFields(),
//               const SizedBox(height: 20),
//               _buildStatusSection(),
//               const SizedBox(height: 16),
//               _buildNotesField(),
//               const SizedBox(height: 20),
//               _buildActionButtons(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateField(BuildContext context) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () => _selectDate(context),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.calendar_today, color: Colors.blue),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('تاريخ المستند', style: TextStyle(fontSize: 12, color: Colors.grey)),
//                     Obx(() {
//                       final d = controller.selectedDate.value;
//                       String period = d.hour >= 12 ? "م" : "ص";
//                       int hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
//                       return Text(
//                         "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
//                         "$hour12:${d.minute.toString().padLeft(2, '0')} $period",
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStoreRow(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//             child: _buildStoreField(
//                 context, 'من مخزن', controller.fromStore, controller.setFromStore, _fromStoreKey)),
//         const SizedBox(width: 12),
//         Expanded(
//             child: _buildStoreField(
//                 context, 'إلى مخزن', controller.toStore, controller.setToStore, _toStoreKey)),
//       ],
//     );
//   }

//   Widget _buildStoreField(BuildContext context, String hint, RxString storeRx,
//       void Function(String) setStore, GlobalKey key) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () => _selectStore(context, storeRx, setStore, key),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           key: key,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Obx(() => Text(
//                       storeRx.value.isEmpty ? hint : storeRx.value,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: storeRx.value.isEmpty ? Colors.grey : Colors.black87,
//                         fontWeight: storeRx.value.isEmpty ? FontWeight.normal : FontWeight.w500,
//                       ),
//                     )),
//               ),
//               const Icon(Icons.arrow_drop_down, color: Colors.blue),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildDriverFields() {
//     return [
//       _buildInputField('اسم السائق', Icons.person),
//       const SizedBox(height: 16),
//       _buildInputField('رقم السائق', Icons.phone),
//       const SizedBox(height: 16),
//       _buildInputField('رقم السيارة', Icons.directions_car),
//       const SizedBox(height: 16),
//       _buildInputField('رقم الاستلام', Icons.receipt),
//     ];
//   }

//   Widget _buildInputField(String label, IconData icon) {
//     return Card(
//       elevation: 2,
//       child: TextFormField(
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: label,
//           prefixIcon: Icon(icon, color: Colors.blue),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         style: const TextStyle(fontSize: 16, color: Colors.black87),
//       ),
//     );
//   }

//   Widget _buildStatusSection() {
//     return Card(
//       elevation: 2,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'حالة المستند',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
//             ),
//             const SizedBox(height: 12),
//             _buildCheckboxOption('مستلم', 'received'),
//             _buildCheckboxOption('مرحل حسابات', 'transferred_accounts'),
//             _buildCheckboxOption('تم التحميل', 'loaded'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCheckboxOption(String title, String value) {
//     return Obx(() => CheckboxListTile(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//           value: controller.statusOptions[value] ?? false,
//           onChanged: (bool? val) => controller.updateStatus(value, val ?? false),
//           activeColor: Colors.blue,
//           contentPadding: EdgeInsets.zero,
//           controlAffinity: ListTileControlAffinity.leading,
//         ));
//   }

//   Widget _buildNotesField() {
//     return Card(
//       elevation: 2,
//       child: TextFormField(
//         maxLines: 4,
//         decoration: InputDecoration(
//           labelText: 'الملاحظات',
//           hintText: 'أدخل ملاحظاتك هنا...',
//           prefixIcon: const Icon(Icons.note_alt, color: Colors.blue),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           alignLabelWithHint: true,
//         ),
//         style: const TextStyle(fontSize: 16, color: Colors.black87),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         // زر عرض سجل التعديلات
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             onPressed: () => _showEditHistory(Get.context!),
//             icon: const Icon(Icons.history, color: Colors.blue),
//             label: const Text(
//               'عرض سجل التعديلات',
//               style: TextStyle(fontSize: 16, color: Colors.blue),
//             ),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               side: const BorderSide(color: Colors.blue, width: 2),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         // زر الحفظ
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: () => _saveDocument(Get.context!),
//             icon: const Icon(Icons.save, color: Colors.white),
//             label: const Text(
//               'حفظ ',
//               style: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showEditHistory(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (context, scrollController) => Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'سجل التعديلات',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: 5, // مثال على البيانات
//                   itemBuilder: (context, index) => _buildHistoryItem(index),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryItem(int index) {
//     final historyData = [
//       {'action': 'إنشاء المستند', 'user': 'أحمد محمد', 'date': '2024-01-15 10:30 ص'},
//       {'action': 'تحديث اسم السائق', 'user': 'سارة أحمد', 'date': '2024-01-15 11:15 ص'},
//       {'action': 'تغيير حالة إلى مستلم', 'user': 'محمد علي', 'date': '2024-01-15 02:20 م'},
//       {'action': 'إضافة ملاحظات', 'user': 'فاطمة خالد', 'date': '2024-01-15 03:45 م'},
//       {'action': 'تحديث رقم السيارة', 'user': 'عبدالله سعد', 'date': '2024-01-15 04:10 م'},
//     ];

//     final item = historyData[index];
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.blue.shade100,
//           child: const Icon(Icons.edit, color: Colors.blue, size: 20),
//         ),
//         title: Text(item['action']!, style: const TextStyle(fontWeight: FontWeight.w500)),
//         subtitle: Text('بواسطة: ${item['user']}'),
//         trailing: Text(
//           item['date']!,
//           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//         ),
//       ),
//     );
//   }

//   void _saveDocument(BuildContext context) {
//     // منطق حفظ المستند
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('تم حفظ التعديلات بنجاح'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }

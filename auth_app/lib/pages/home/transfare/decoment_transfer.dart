import 'package:auth_app/pages/home/transfare/decoment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DecomentTransfer extends StatelessWidget {
  DecomentTransfer({super.key});

  final DecomentTransferController controller = Get.put(DecomentTransferController());
  final GlobalKey _fromStoreKey = GlobalKey();
  final GlobalKey _toStoreKey = GlobalKey();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ar', ''),
    );
    if (picked != null) controller.setDate(picked);
  }

  void _selectStore(
      BuildContext context, RxString storeRx, void Function(String) setStore, GlobalKey key) async {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + size.width, offset.dy),
      items: List.generate(
          4, (i) => PopupMenuItem(value: 'مخزن ${i + 1}', child: Text('مخزن ${i + 1}'))),
    );

    if (selected != null) setStore(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('  مستند تحويل المخزون'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDateField(context),
              const SizedBox(height: 16),
              _buildStoreRow(context),
              const SizedBox(height: 16),
              ..._buildDriverFields(),
              const SizedBox(height: 20),
              _buildStatusSection(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاريخ المستند', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Obx(() {
                      final d = controller.selectedDate.value;
                      String period = d.hour >= 12 ? "م" : "ص";
                      int hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
                      return Text(
                        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
                        "$hour12:${d.minute.toString().padLeft(2, '0')} $period",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildStoreField(
                context, 'من مخزن', controller.fromStore, controller.setFromStore, _fromStoreKey)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStoreField(
                context, 'إلى مخزن', controller.toStore, controller.setToStore, _toStoreKey)),
      ],
    );
  }

  Widget _buildStoreField(BuildContext context, String hint, RxString storeRx,
      void Function(String) setStore, GlobalKey key) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _selectStore(context, storeRx, setStore, key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          key: key,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => Text(
                      storeRx.value.isEmpty ? hint : storeRx.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: storeRx.value.isEmpty ? Colors.grey : Colors.black87,
                        fontWeight: storeRx.value.isEmpty ? FontWeight.normal : FontWeight.w500,
                      ),
                    )),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDriverFields() {
    return [
      _buildInputField('اسم السائق', Icons.person),
      const SizedBox(height: 16),
      _buildInputField('رقم السائق', Icons.phone),
      const SizedBox(height: 16),
      _buildInputField('رقم السيارة', Icons.directions_car),
      const SizedBox(height: 16),
      _buildInputField('رقم الاستلام', Icons.receipt),
    ];
  }

  Widget _buildInputField(String label, IconData icon) {
    return Card(
      elevation: 2,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة المستند',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            _buildCheckboxOption('مستلم', 'received'),
            _buildCheckboxOption('مرحل حسابات', 'transferred_accounts'),
            _buildCheckboxOption('تم التحميل', 'loaded'),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title, String value) {
    return Obx(() => CheckboxListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          value: controller.statusOptions[value] ?? false,
          onChanged: (bool? val) => controller.updateStatus(value, val ?? false),
          activeColor: Colors.blue,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ));
  }

  Widget _buildNotesField() {
    return Card(
      elevation: 2,
      child: TextFormField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'الملاحظات',
          hintText: 'أدخل ملاحظاتك هنا...',
          prefixIcon: const Icon(Icons.note_alt, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignLabelWithHint: true,
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر عرض سجل التعديلات
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showEditHistory(Get.context!),
            icon: const Icon(Icons.history, color: Colors.blue),
            label: const Text(
              'عرض سجل التعديلات',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // زر الحفظ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveDocument(Get.context!),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'حفظ ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'سجل التعديلات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 5, // مثال على البيانات
                  itemBuilder: (context, index) => _buildHistoryItem(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final historyData = [
      {'action': 'إنشاء المستند', 'user': 'أحمد محمد', 'date': '2024-01-15 10:30 ص'},
      {'action': 'تحديث اسم السائق', 'user': 'سارة أحمد', 'date': '2024-01-15 11:15 ص'},
      {'action': 'تغيير حالة إلى مستلم', 'user': 'محمد علي', 'date': '2024-01-15 02:20 م'},
      {'action': 'إضافة ملاحظات', 'user': 'فاطمة خالد', 'date': '2024-01-15 03:45 م'},
      {'action': 'تحديث رقم السيارة', 'user': 'عبدالله سعد', 'date': '2024-01-15 04:10 م'},
    ];

    final item = historyData[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.edit, color: Colors.blue, size: 20),
        ),
        title: Text(item['action']!, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('بواسطة: ${item['user']}'),
        trailing: Text(
          item['date']!,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  void _saveDocument(BuildContext context) {
    // منطق حفظ المستند
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التعديلات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}




// import 'package:auth_app/pages/home/transfare/decoment_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// // استيراد المتحكم (يجب أن يكون في ملف منفصل)
// // import 'document_transfer_controller.dart';

// class DocumentTransferPage extends StatelessWidget {
//   final DocumentTransferController controller = Get.put(DocumentTransferController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             SizedBox(height: 20),
//             _buildFormCard(),
//             SizedBox(height: 20),
//             _buildFiltersSection(),
//             SizedBox(height: 20),
//             _buildDocumentsList(),
//           ],
//         ),
//       ),
//     );
//   }

//   // بناء شريط التطبيق
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: Text(
//         'تعديل مستند التحويل',
//         style: TextStyle(
//           color: Colors.black87,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         Obx(() => controller.isLoading.value
//             ? Padding(
//                 padding: EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               )
//             : IconButton(
//                 icon: Icon(Icons.download, color: Colors.blue),
//                 onPressed: controller.exportData,
//               )),
//       ],
//     );
//   }

//   // بناء الهيدر
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue[600]!, Colors.blue[400]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.assignment, color: Colors.white, size: 32),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'نظام إدارة التحويل',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'تسجيل ومتابعة مستندات التحويل',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Obx(() => Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '${controller.documentsList.length} مستند',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   // بناء بطاقة النموذج
//   Widget _buildFormCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'معلومات التحويل',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue[700],
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildFormFields(),
//               // SizedBox(height: 20),
//               // _buildStatusCheckboxes(),
//               SizedBox(height: 20),
//               _buildActionButtons(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // بناء حقول النموذج
//   Widget _buildFormFields() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//                 child: _buildTextField(
//                     'من المخزن', controller.fromWarehouseController, Icons.warehouse)),
//             SizedBox(width: 12),
//             Expanded(
//                 child: _buildTextField(
//                     'إلى المخزن', controller.toWarehouseController, Icons.warehouse_outlined)),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//                 child: _buildTextField(
//                     'رقم السيارة', controller.carNumberController, Icons.directions_car)),
//             SizedBox(width: 12),
//             Expanded(
//                 child:
//                     _buildTextField('جوال السائق', controller.driverPhoneController, Icons.phone)),
//           ],
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//                 child:
//                     _buildTextField('اسم السائق', controller.driverNameController, Icons.person)),
//             SizedBox(width: 12),
//             Expanded(
//                 child: _buildTextField(
//                     'رقم المستند', controller.documentNumberController, Icons.description)),
//           ],
//         ),
//         SizedBox(height: 16),
//         _buildDatePicker(),
//         SizedBox(height: 16),
//         _buildTextField('ملاحظات', controller.notesController, Icons.notes, maxLines: 3),
//       ],
//     );
//   }

//   // بناء حقل نص
//   Widget _buildTextField(String label, TextEditingController controller, IconData icon,
//       {int maxLines = 1}) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blue[600]),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'هذا الحقل مطلوب';
//         }
//         return null;
//       },
//     );
//   }

//   // بناء منتقي التاريخ
//   Widget _buildDatePicker() {
//     return Obx(() => InkWell(
//           onTap: () => controller.selectDate(Get.context!),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey[300]!),
//               borderRadius: BorderRadius.circular(8),
//               color: Colors.grey[50],
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_today, color: Colors.blue[600]),
//                 SizedBox(width: 12),
//                 Text(
//                   'تاريخ المستند: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 Spacer(),
//                 Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
//               ],
//             ),
//           ),
//         ));
//   }

//   // بناء خانات الاختيار للحالة
//   // Widget _buildStatusCheckboxes() {
//   //   return Container(
//   //     padding: EdgeInsets.all(16),
//   //     decoration: BoxDecoration(
//   //       color: Colors.blue[50],
//   //       borderRadius: BorderRadius.circular(8),
//   //       border: Border.all(color: Colors.blue[200]!),
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           'حالة المستند',
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             fontWeight: FontWeight.bold,
//   //             color: Colors.blue[700],
//   //           ),
//   //         ),
//   //         SizedBox(height: 12),
//   //         Row(
//   //           children: [
//   //             Expanded(
//   //               child: Obx(() => CheckboxListTile(
//   //                     title: Text('مستلم', style: TextStyle(fontSize: 14)),
//   //                     value: controller.isReceived.value,
//   //                     onChanged: (value) => controller.isReceived.value = value ?? false,
//   //                     activeColor: Colors.green,
//   //                     dense: true,
//   //                   )),
//   //             ),
//   //             Expanded(
//   //               child: Obx(() => CheckboxListTile(
//   //                     title: Text('مركب (حسابات)', style: TextStyle(fontSize: 14)),
//   //                     value: controller.isDelivered.value,
//   //                     onChanged: (value) => controller.isDelivered.value = value ?? false,
//   //                     activeColor: Colors.orange,
//   //                     dense: true,
//   //                   )),
//   //             ),
//   //             Expanded(
//   //               child: Obx(() => CheckboxListTile(
//   //                     title: Text('تم التحصيل', style: TextStyle(fontSize: 14)),
//   //                     value: controller.isCompleted.value,
//   //                     onChanged: (value) => controller.isCompleted.value = value ?? false,
//   //                     activeColor: Colors.blue,
//   //                     dense: true,
//   //                   )),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // بناء أزرار الإجراءات
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: Obx(() => ElevatedButton.icon(
//                 onPressed: controller.isLoading.value ? null : controller.saveDocument,
//                 icon: controller.isLoading.value
//                     ? SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : Icon(Icons.save),
//                 label: Text(controller.isLoading.value ? 'جاري الحفظ...' : 'حفظ المستند'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[600],
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               )),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: controller.clearForm,
//             icon: Icon(Icons.clear),
//             label: Text('مسح النموذج'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.red[600],
//               side: BorderSide(color: Colors.red[600]!),
//               padding: EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // بناء قسم الفلاتر
//   Widget _buildFiltersSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           ListTile(
//             leading: Icon(Icons.filter_list, color: Colors.blue[600]),
//             title: Text('فلاتر البحث', style: TextStyle(fontWeight: FontWeight.bold)),
//             trailing: Obx(() => IconButton(
//                   icon: Icon(controller.showFilters.value ? Icons.expand_less : Icons.expand_more),
//                   onPressed: controller.toggleFilters,
//                 )),
//           ),
//           Obx(() => AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 height: controller.showFilters.value ? null : 0,
//                 child: controller.showFilters.value ? _buildFiltersContent() : SizedBox.shrink(),
//               )),
//         ],
//       ),
//     );
//   }

//   // بناء محتوى الفلاتر
//   Widget _buildFiltersContent() {
//     return Padding(
//       padding: EdgeInsets.all(14),
//       child: Column(
//         children: [
//           // شريط البحث
//           TextField(
//             onChanged: (value) => controller.searchQuery.value = value,
//             // textDirection: TextDirection.rtl,
//             decoration: InputDecoration(
//               hintText: 'البحث في المستندات...',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//           ),
//           SizedBox(height: 16),
//           // فلاتر الحالة والتاريخ
//           Row(
//             children: [
//               Expanded(
//                 child: Obx(() => DropdownButtonFormField<String>(
//                       value: controller.selectedStatusFilter.value,
//                       decoration: InputDecoration(
//                         labelText: 'فلتر الحالة',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                       ),
//                       items: controller.statusFilterOptions.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           controller.selectedStatusFilter.value = newValue;
//                         }
//                       },
//                     )),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Obx(() => DropdownButtonFormField<String>(
//                       value: controller.selectedDateFilter.value,
//                       decoration: InputDecoration(
//                         labelText: 'فلتر التاريخ',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                       ),
//                       items: controller.dateFilterOptions.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           controller.selectedDateFilter.value = newValue;
//                         }
//                       },
//                     )),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           // زر إعادة تعيين الفلاتر
//           ElevatedButton.icon(
//             onPressed: controller.resetFilters,
//             icon: Icon(Icons.refresh),
//             label: Text('إعادة تعيين الفلاتر'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[600],
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // بناء قائمة المستندات
//   Widget _buildDocumentsList() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.list_alt, color: Colors.blue[600]),
//                 SizedBox(width: 8),
//                 Text(
//                   'قائمة المستندات',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue[700],
//                   ),
//                 ),
//                 Spacer(),
//                 Obx(() => Chip(
//                       label: Text('${controller.filteredDocuments.length}'),
//                       backgroundColor: Colors.blue[100],
//                     )),
//               ],
//             ),
//           ),
//           Divider(height: 1),
//           Obx(() => controller.filteredDocuments.isEmpty
//               ? _buildEmptyState()
//               : ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: controller.filteredDocuments.length,
//                   itemBuilder: (context, index) {
//                     final doc = controller.filteredDocuments[index];
//                     return _buildDocumentItem(doc);
//                   },
//                 )),
//         ],
//       ),
//     );
//   }

//   // بناء حالة فارغة
//   Widget _buildEmptyState() {
//     return Container(
//       padding: EdgeInsets.all(40),
//       child: Column(
//         children: [
//           Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
//           SizedBox(height: 16),
//           Text(
//             'لا توجد مستندات تطابق معايير البحث',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // بناء عنصر المستند
//   Widget _buildDocumentItem(DocumentTransfer doc) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.white,
//       ),
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor: _getStatusColor(doc),
//           child: Icon(
//             Icons.description,
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           'مستند #${doc.documentNumber}',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Text(
//           '${doc.fromWarehouse} ← ${doc.toWarehouse}',
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               DateFormat('dd/MM/yyyy').format(doc.transferDate),
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 12,
//               ),
//             ),
//             SizedBox(width: 8),
//             PopupMenuButton<String>(
//               onSelected: (value) => _handleDocumentAction(value, doc),
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Text('تعديل'),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('حذف'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDocumentDetailRow('السائق:', doc.driverName, Icons.person),
//                 _buildDocumentDetailRow('رقم الجوال:', doc.driverPhone, Icons.phone),
//                 _buildDocumentDetailRow('رقم السيارة:', doc.carNumber, Icons.directions_car),
//                 if (doc.notes.isNotEmpty)
//                   _buildDocumentDetailRow('ملاحظات:', doc.notes, Icons.notes),
//                 SizedBox(height: 16),
//                 _buildStatusRow(doc),
//                 SizedBox(height: 16),
//                 _buildDocumentActions(doc),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // بناء صف تفاصيل المستند
//   Widget _buildDocumentDetailRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey[600]),
//           SizedBox(width: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(color: Colors.grey[800]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // بناء صف الحالة
//   Widget _buildStatusRow(DocumentTransfer doc) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'حالة المستند:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               _buildStatusChip('مستلم', doc.isReceived, Colors.green),
//               SizedBox(width: 8),
//               _buildStatusChip('مركب', doc.isDelivered, Colors.orange),
//               SizedBox(width: 8),
//               _buildStatusChip('مكتمل', doc.isCompleted, Colors.blue),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // بناء شريحة الحالة
//   Widget _buildStatusChip(String label, bool isActive, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: isActive ? color : Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: isActive ? Colors.white : Colors.grey[600],
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // بناء إجراءات المستند
//   Widget _buildDocumentActions(DocumentTransfer doc) {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _toggleDocumentStatus(doc, 'received'),
//             icon: Icon(
//               doc.isReceived ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 18,
//             ),
//             label: Text('مستلم', style: TextStyle(fontSize: 12)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: doc.isReceived ? Colors.green : Colors.grey[300],
//               foregroundColor: doc.isReceived ? Colors.white : Colors.grey[700],
//               padding: EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _toggleDocumentStatus(doc, 'delivered'),
//             icon: Icon(
//               doc.isDelivered ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 18,
//             ),
//             label: Text('مركب', style: TextStyle(fontSize: 12)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: doc.isDelivered ? Colors.orange : Colors.grey[300],
//               foregroundColor: doc.isDelivered ? Colors.white : Colors.grey[700],
//               padding: EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _toggleDocumentStatus(doc, 'completed'),
//             icon: Icon(
//               doc.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 18,
//             ),
//             label: Text('مكتمل', style: TextStyle(fontSize: 12)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: doc.isCompleted ? Colors.blue : Colors.grey[300],
//               foregroundColor: doc.isCompleted ? Colors.white : Colors.grey[700],
//               padding: EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // الحصول على لون الحالة
//   Color _getStatusColor(DocumentTransfer doc) {
//     if (doc.isCompleted) return Colors.blue;
//     if (doc.isDelivered) return Colors.orange;
//     if (doc.isReceived) return Colors.green;
//     return Colors.grey;
//   }

//   // التعامل مع إجراءات المستند
//   void _handleDocumentAction(String action, DocumentTransfer doc) {
//     switch (action) {
//       case 'edit':
//         _loadDocumentForEdit(doc);
//         break;
//       case 'delete':
//         _showDeleteConfirmation(doc);
//         break;
//     }
//   }

//   // تحميل المستند للتعديل
//   void _loadDocumentForEdit(DocumentTransfer doc) {
//     controller.fromWarehouseController.text = doc.fromWarehouse;
//     controller.toWarehouseController.text = doc.toWarehouse;
//     controller.carNumberController.text = doc.carNumber;
//     controller.driverPhoneController.text = doc.driverPhone;
//     controller.driverNameController.text = doc.driverName;
//     controller.documentNumberController.text = doc.documentNumber;
//     controller.notesController.text = doc.notes;
//     controller.selectedDate.value = doc.transferDate;
//     controller.isReceived.value = doc.isReceived;
//     controller.isDelivered.value = doc.isDelivered;
//     controller.isCompleted.value = doc.isCompleted;

//     // التمرير إلى النموذج
//     Scrollable.ensureVisible(
//       controller.formKey.currentContext!,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );

//     Get.snackbar(
//       'تم التحميل',
//       'تم تحميل بيانات المستند للتعديل',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
//   }

//   // عرض تأكيد الحذف
//   void _showDeleteConfirmation(DocumentTransfer doc) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف مستند #${doc.documentNumber}؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               controller.deleteDocument(doc.id);
//               Get.back();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // تبديل حالة المستند
//   void _toggleDocumentStatus(DocumentTransfer doc, String statusType) {
//     bool currentValue;
//     switch (statusType) {
//       case 'received':
//         currentValue = doc.isReceived;
//         break;
//       case 'delivered':
//         currentValue = doc.isDelivered;
//         break;
//       case 'completed':
//         currentValue = doc.isCompleted;
//         break;
//       default:
//         return;
//     }

//     controller.updateDocumentStatus(doc.id, statusType, !currentValue);
//   }
// }

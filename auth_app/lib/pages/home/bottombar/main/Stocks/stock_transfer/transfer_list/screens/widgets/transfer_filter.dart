// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';

// class TransferFilterDialog {
//   static void show(BuildContext context, TransferController controller) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('فلترة التحويلات'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // فلتر الحالة
//               Obx(() => DropdownButtonFormField<String>(
//                     value: controller.selectedStatusFilter.value,
//                     decoration: const InputDecoration(
//                       labelText: 'الحالة',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
//                       DropdownMenuItem(value: 'pending', child: Text('قيد التحضير')),
//                       DropdownMenuItem(value: 'sent', child: Text('تم الإرسال')),
//                       DropdownMenuItem(value: 'received', child: Text('تم الاستلام')),
//                       DropdownMenuItem(value: 'posted', child: Text('مُرحّل إلى SAP')),
//                     ],
//                     onChanged: (value) => controller.updateStatusFilter(value!),
//                   )),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               controller.resetFilters();
//               Get.back();
//             },
//             child: const Text('إعادة تعيين'),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2196F3),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('تطبيق'),
//           ),
//         ],
//       ),
//     );
//   }
// }

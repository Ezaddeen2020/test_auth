// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';

// class TransferSearchBar extends StatelessWidget {
//   final TransferController controller;

//   const TransferSearchBar({
//     super.key,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         controller: controller.searchController,
//         onChanged: controller.updateSearch,
//         decoration: InputDecoration(
//           hintText: 'البحث في التحويلات...',
//           prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
//           suffixIcon: Obx(() {
//             if (controller.searchQuery.value.isNotEmpty) {
//               return IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   controller.searchController.clear();
//                   controller.updateSearch('');
//                 },
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF2196F3)),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//       ),
//     );
//   }
// }

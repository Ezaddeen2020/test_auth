// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../auth/controllers/auth_controller.dart';

// class HomePage extends StatelessWidget {
//   final AuthController authController = Get.find<AuthController>();

//   HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الصفحة الرئيسية'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _showLogoutDialog(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'مرحباً، ${authController.getCurrentUser()?.name ?? 'المستخدم'}',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'تم تسجيل الدخول بنجاح',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'معلومات الـ Token:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         authController.authToken ?? 'لم يتم العثور على Token',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'monospace',
//                         ),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // زر اختبار الـ API
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: authController.testApiWithToken,
//                 child: const Text('اختبار الـ API'),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // زر تسجيل الخروج
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => _showLogoutDialog(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                 ),
//                 child: const Text('تسجيل الخروج'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('تسجيل الخروج'),
//           content: const Text('هل تريد تسجيل الخروج؟'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('إلغاء'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 authController.logout();
//               },
//               child: const Text('تأكيد'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // نفترض getCurrentUser() ترجع المستخدم المسجل
    UserModel? currentUser = authController.getCurrentUser();

    // إذا صادفنا null بشكل غير متوقع، يمكن التعامل معه
    if (currentUser == null) {
      // هذه حالة استثنائية، ربما نعيد توجيه المستخدم لتسجيل الدخول
      Future.microtask(() => Get.offAllNamed('/login'));
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // المحتوى الطبيعي للصفحة هنا
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // محتوى الصفحة كما كان
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مرحباً!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'البريد الإلكتروني: ${currentUser.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // باقي الصفحة كما هو...
          ],
        ),
      ),
    );
  }

  // تابع تسجيل الخروج كما لديك
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
              Get.offAllNamed('/login'); // إعادة توجيه لتسجيل الدخول بعد تسجيل الخروج
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: const [Text('Home_page')],
//       ),
//     );
//   }
// }

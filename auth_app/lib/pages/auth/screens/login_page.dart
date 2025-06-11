import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: authController.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Logo
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 30),

                // Welcome Text
                const Text(
                  'مرحباً بك',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'سجل دخولك للمتابعة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // Username Field
                CustomTextField(
                  controller: authController.usernameController,
                  label: 'اسم المستخدم',
                  hint: 'أدخل اسم المستخدم',
                  icon: Icons.person,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستخدم';
                    }
                    if (value.length < 3) {
                      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                Obx(() => CustomTextField(
                      controller: authController.passwordController,
                      label: 'كلمة المرور',
                      hint: 'أدخل كلمة المرور',
                      icon: Icons.lock,
                      obscureText: !authController.isPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                    )),

                const SizedBox(height: 30),

                // Login Button
                Obx(() => CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: authController.login,
                      isLoading: authController.isLoading.value,
                    )),

                const SizedBox(height: 30),

                // معلومات الاختبار
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'بيانات الاختبار:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اسم المستخدم: mms',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'كلمة المرور: Awad2015*',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // API Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'معلومات الـ API:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Server: qitaf3.dynalias.net:44322',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Login API: /api/Account/login',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Test API: /api/SalesDataVTec/Test',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

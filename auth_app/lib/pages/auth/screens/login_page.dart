import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/pages/auth/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Proper RTL support for Arabic
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: authController.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Enhanced Logo with gradient and animation potential
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Enhanced Welcome Text
                  const Text(
                    'مرحباً بعودتك',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'سعداء برؤيتك مرة أخرى، سجل دخولك للمتابعة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Enhanced Username Field
                  _buildEnhancedTextField(
                    controller: authController.usernameController,
                    label: 'اسم المستخدم',
                    hint: 'أدخل اسم المستخدم الخاص بك',
                    icon: Icons.person_rounded,
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

                  const SizedBox(height: 24),

                  // Enhanced Password Field
                  Obx(() => _buildEnhancedTextField(
                        controller: authController.passwordController,
                        label: 'كلمة المرور',
                        hint: 'أدخل كلمة المرور',
                        icon: Icons.lock_rounded,
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
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF64748B),
                          ),
                          onPressed: authController.togglePasswordVisibility,
                        ),
                      )),

                  const SizedBox(height: 16),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced Login Button
                  Obx(() => _buildEnhancedButton(
                        text: 'تسجيل الدخول',
                        onPressed: authController.login,
                        isLoading: authController.isLoading.value,
                        isPrimary: true,
                      )),

                  const SizedBox(height: 32),

                  // Divider with "أو" text
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Social Login Buttons (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onPressed: () {
                            // Handle Google login
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onPressed: () {
                            // Handle Apple login
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Enhanced Sign Up Link
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => SignUpPage(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: 22,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : const Color(0xFF374151),
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF374151),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),

        // من أي مكان في التطبيق
      ),
    );
  }
}

// import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
// import 'package:auth_app/pages/auth/screens/signup_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../widgets/custom_text_field.dart';
// import '../../../widgets/custom_button.dart';

// class LoginPage extends StatelessWidget {
//   final AuthController authController = Get.find<AuthController>();

//   LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: authController.loginFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50),

//                 // Logo
//                 Container(
//                   height: 100,
//                   width: 100,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     size: 50,
//                     color: Colors.blue,
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Welcome Text
//                 const Text(
//                   'مرحباً بك',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   'سجل دخولك للمتابعة',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Username Field
//                 CustomTextField(
//                   controller: authController.usernameController,
//                   label: 'اسم المستخدم',
//                   hint: 'أدخل اسم المستخدم',
//                   icon: Icons.person,
//                   keyboardType: TextInputType.text,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال اسم المستخدم';
//                     }
//                     if (value.length < 3) {
//                       return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // Password Field
//                 Obx(() => CustomTextField(
//                       controller: authController.passwordController,
//                       label: 'كلمة المرور',
//                       hint: 'أدخل كلمة المرور',
//                       icon: Icons.lock,
//                       obscureText: !authController.isPasswordVisible.value,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'يرجى إدخال كلمة المرور';
//                         }
//                         if (value.length < 6) {
//                           return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
//                         }
//                         return null;
//                       },
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           authController.isPasswordVisible.value
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed: authController.togglePasswordVisibility,
//                       ),
//                     )),

//                 const SizedBox(height: 30),

//                 // Login Button
//                 Obx(() => CustomButton(
//                       text: 'تسجيل الدخول',
//                       onPressed: authController.login,
//                       isLoading: authController.isLoading.value,
//                     )),
//                 const SizedBox(height: 30),

//                 // Login Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'لديك حساب بالفعل؟ ',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Get.toNamed('/signup');
//                         Get.to(
//                           () => SignUpPage(),
//                           transition: Transition.fadeIn,
//                           // duration: const Duration(milliseconds: 600),
//                         );
//                       },
//                       child: const Text(
//                         ' انشاء حساب',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

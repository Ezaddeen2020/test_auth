// import 'package:auth_app/widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../../../classes/auth_validators.dart';
// import '../../../widgets/custom_text_field.dart';

// class SignUpPage extends StatelessWidget {
//   final AuthController authController = Get.find<AuthController>();

//   SignUpPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             // key: authController.signupFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),

//                 // Logo or App Icon
//                 Container(
//                   height: 80,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person_add,
//                     size: 40,
//                     color: Colors.green,
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Welcome Text
//                 const Text(
//                   'إنشاء حساب جديد',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   'املأ البيانات للبدء',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Name Field
//                 CustomTextField(
//                   controller: authController.usernameController,
//                   label: 'الاسم الكامل',
//                   hint: 'أدخل اسمك الكامل',
//                   icon: Icons.person,
//                   validator: AuthValidators.validateName,
//                 ),

//                 const SizedBox(height: 20),

//                 // Email Field
//                 // CustomTextField(
//                 //   controller: authController.emailController,
//                 //   label: 'البريد الإلكتروني',
//                 //   hint: 'أدخل بريدك الإلكتروني',
//                 //   icon: Icons.email,
//                 //   keyboardType: TextInputType.emailAddress,
//                 //   validator: AuthValidators.validateEmail,
//                 // ),

//                 const SizedBox(height: 20),

//                 // Password Field
//                 Obx(() => CustomTextField(
//                       controller: authController.passwordController,
//                       label: 'كلمة المرور',
//                       hint: 'أدخل كلمة المرور',
//                       icon: Icons.lock,
//                       obscureText: !authController.isPasswordVisible.value,
//                       validator: AuthValidators.validatePassword,
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

//                 // Terms and Conditions
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: true,
//                       onChanged: (value) {
//                         // Handle terms acceptance
//                       },
//                     ),
//                     Expanded(
//                       child: Text(
//                         'أوافق على الشروط والأحكام وسياسة الخصوصية',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),

//                 // Sign Up Button
//                 Obx(() => CustomButton(
//                       text: 'إنشاء حساب',
//                       onPressed: authController.signUp,
//                       isLoading: authController.isLoading.value,
//                       backgroundColor: Colors.green,
//                     )),

//                 const SizedBox(height: 30),

//                 // Login Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'لديك حساب بالفعل؟  ',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: const Text(
//                         'تسجيل الدخول',
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../classes/auth_validators.dart';

class SignUpPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Proper RTL support for Arabic
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Enhanced Logo with gradient and shadow
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced Welcome Text with better typography
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'املأ البيانات أدناه للبدء في رحلتك معنا',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Enhanced Name Field with better styling
                  _buildEnhancedTextField(
                    controller: authController.usernameController,
                    label: 'الاسم الكامل',
                    hint: 'أدخل اسمك الكامل',
                    icon: Icons.person_rounded,
                    validator: AuthValidators.validateName,
                  ),

                  const SizedBox(height: 24),

                  // Enhanced Password Field
                  Obx(() => _buildEnhancedTextField(
                        controller: authController.passwordController,
                        label: 'كلمة المرور',
                        hint: 'أدخل كلمة مرور قوية',
                        icon: Icons.lock_rounded,
                        obscureText: !authController.isPasswordVisible.value,
                        validator: AuthValidators.validatePassword,
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

                  const SizedBox(height: 32),

                  // Enhanced Terms and Conditions with better styling
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          child: Checkbox(
                            value: true,
                            onChanged: (value) {
                              // Handle terms acceptance
                            },
                            activeColor: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(text: 'أوافق على '),
                                TextSpan(
                                  text: 'الشروط والأحكام',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' و '),
                                TextSpan(
                                  text: 'سياسة الخصوصية',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced Sign Up Button
                  Obx(() => _buildEnhancedButton(
                        text: 'إنشاء حساب',
                        onPressed: authController.signUp,
                        isLoading: authController.isLoading.value,
                        isPrimary: true,
                      )),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 24),

                  // Enhanced Login Link
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟ ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
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
                colors: [Color(0xFF10B981), Color(0xFF059669)],
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
              color: const Color(0xFF10B981).withOpacity(0.3),
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
}




// lib/views/pages/signup_page.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../validators/auth_validators.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/custom_button.dart';

// class SignUpPage extends StatelessWidget {
//   final AuthController authController = Get.find<AuthController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: const Text(
//           'إنشاء حساب جديد',
//           style: TextStyle(color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: authController.signupFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),

//                 // Logo or App Icon
//                 Container(
//                   height: 80,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person_add,
//                     size: 40,
//                     color: Colors.green,
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Welcome Text
//                 const Text(
//                   'أهلاً وسهلاً',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   'املأ البيانات للبدء',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Name Field
//                 CustomTextField(
//                   controller: authController.nameController,
//                   label: 'الاسم الكامل',
//                   hint: 'أدخل اسمك الكامل',
//                   icon: Icons.person,
//                   validator: AuthValidators.validateName,
//                 ),

//                 const SizedBox(height: 20),

//                 // Email Field
//                 CustomTextField(
//                   controller: authController.emailController,
//                   label: 'البريد الإلكتروني',
//                   hint: 'أدخل بريدك الإلكتروني',
//                   icon: Icons.email,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: AuthValidators.validateEmail,
//                 ),

//                 const SizedBox(height: 20),

//                 // Password Field
//                 Obx(() => CustomTextField(
//                       controller: authController.passwordController,
//                       label: 'كلمة المرور',
//                       hint: 'أدخل كلمة المرور (8 أحرف على الأقل)',
//                       icon: Icons.lock,
//                       obscureText: !authController.isPasswordVisible.value,
//                       validator: AuthValidators.validatePassword,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           authController.isPasswordVisible.value
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed: authController.togglePasswordVisibility,
//                       ),
//                     )),

//                 const SizedBox(height: 20),

//                 // Confirm Password Field
//                 Obx(() => CustomTextField(
//                       controller: authController.confirmPasswordController,
//                       label: 'تأكيد كلمة المرور',
//                       hint: 'أعد إدخال كلمة المرور',
//                       icon: Icons.lock_outline,
//                       obscureText: !authController.isConfirmPasswordVisible.value,
//                       validator: (value) => AuthValidators.validateConfirmPassword(
//                         value,
//                         authController.passwordController.text,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           authController.isConfirmPasswordVisible.value
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed: authController.toggleConfirmPasswordVisibility,
//                       ),
//                     )),

//                 const SizedBox(height: 30),

//                 // Terms and Conditions
//                 Obx(() => Row(
//                   children: [
//                     Checkbox(
//                       value: authController.acceptTerms.value,
//                       onChanged: (value) {
//                         authController.acceptTerms.value = value ?? false;
//                       },
//                       activeColor: Colors.green,
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           authController.acceptTerms.value = !authController.acceptTerms.value;
//                         },
//                         child: Text(
//                           'أوافق على الشروط والأحكام وسياسة الخصوصية',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),

//                 const SizedBox(height: 30),

//                 // Sign Up Button
//                 Obx(() => CustomButton(
//                       text: 'إنشاء حساب',
//                       onPressed: authController.acceptTerms.value 
//                           ? authController.signUp
//                           : null,
//                       isLoading: authController.isLoading.value,
//                       backgroundColor: Colors.green,
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
//                         Get.back();
//                       },
//                       child: const Text(
//                         'تسجيل الدخول',
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../validators/auth_validators.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/custom_button.dart';

// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
//   final AuthController authController = Get.find<AuthController>();
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _acceptTerms = false;

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: [
//               Color(0xFF4facfe),
//               Color(0xFF00f2fe),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Custom App Bar
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.arrow_back_ios_rounded,
//                           color: Colors.white,
//                         ),
//                         onPressed: () {
//                           Get.back();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: SlideTransition(
//                       position: _slideAnimation,
//                       child: Form(
//                         key: authController.signupFormKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 20),

//                             // Logo with Hero Animation
//                             Hero(
//                               tag: 'app_logo',
//                               child: Container(
//                                 height: 100,
//                                 width: 100,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.15),
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 20,
//                                       offset: const Offset(0, 10),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.person_add_rounded,
//                                   size: 50,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 30),

//                             // Welcome Text with Glass Effect
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.2),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Column(
//                                 children: [
//                                   const Text(
//                                     'إنشاء حساب جديد',
//                                     style: TextStyle(
//                                       fontSize: 28,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                       shadows: [
//                                         Shadow(
//                                           offset: Offset(0, 2),
//                                           blurRadius: 4,
//                                           color: Colors.black26,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'املأ البيانات للبدء',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white.withOpacity(0.8),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(height: 40),

//                             // Form Container with Glass Effect
//                             Container(
//                               padding: const EdgeInsets.all(24),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.95),
//                                 borderRadius: BorderRadius.circular(24),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 20,
//                                     offset: const Offset(0, 10),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   // Name Field
//                                   CustomTextField(
//                                     controller: authController.nameController,
//                                     label: 'الاسم الكامل',
//                                     hint: 'أدخل اسمك الكامل',
//                                     icon: Icons.person_rounded,
//                                     validator: AuthValidators.validateName,
//                                   ),

//                                   const SizedBox(height: 20),

//                                   // Email Field
//                                   CustomTextField(
//                                     controller: authController.emailController,
//                                     label: 'البريد الإلكتروني',
//                                     hint: 'أدخل بريدك الإلكتروني',
//                                     icon: Icons.email_rounded,
//                                     keyboardType: TextInputType.emailAddress,
//                                     validator: AuthValidators.validateEmail,
//                                   ),

//                                   const SizedBox(height: 20),

//                                   // Password Field
//                                   Obx(() => CustomTextField(
//                                         controller: authController.passwordController,
//                                         label: 'كلمة المرور',
//                                         hint: 'أدخل كلمة المرور',
//                                         icon: Icons.lock_rounded,
//                                         obscureText: !authController.isPasswordVisible.value,
//                                         validator: AuthValidators.validatePassword,
//                                         suffixIcon: IconButton(
//                                           icon: Icon(
//                                             authController.isPasswordVisible.value
//                                                 ? Icons.visibility_rounded
//                                                 : Icons.visibility_off_rounded,
//                                             color: Color(0xFF4facfe),
//                                           ),
//                                           onPressed: authController.togglePasswordVisibility,
//                                         ),
//                                       )),

//                                   const SizedBox(height: 20),

//                                   // Confirm Password Field
//                                   Obx(() => CustomTextField(
//                                         controller: authController.confirmPasswordController,
//                                         label: 'تأكيد كلمة المرور',
//                                         hint: 'أعد إدخال كلمة المرور',
//                                         icon: Icons.lock_outline_rounded,
//                                         obscureText: !authController.isConfirmPasswordVisible.value,
//                                         validator: (value) =>
//                                             AuthValidators.validateConfirmPassword(
//                                           value,
//                                           authController.passwordController.text,
//                                         ),
//                                         suffixIcon: IconButton(
//                                           icon: Icon(
//                                             authController.isConfirmPasswordVisible.value
//                                                 ? Icons.visibility_rounded
//                                                 : Icons.visibility_off_rounded,
//                                             color: Color(0xFF4facfe),
//                                           ),
//                                           onPressed: authController.toggleConfirmPasswordVisibility,
//                                         ),
//                                       )),

//                                   const SizedBox(height: 24),

//                                   // Terms and Conditions
//                                   Container(
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.withOpacity(0.05),
//                                       borderRadius: BorderRadius.circular(12),
//                                       border: Border.all(
//                                         color: Colors.grey.withOpacity(0.1),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Transform.scale(
//                                           scale: 1.2,
//                                           child: Checkbox(
//                                             value: _acceptTerms,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 _acceptTerms = value ?? false;
//                                               });
//                                             },
//                                             activeColor: Color(0xFF4facfe),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(4),
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: Text(
//                                             'أوافق على الشروط والأحكام وسياسة الخصوصية',
//                                             style: TextStyle(
//                                               color: Colors.grey[700],
//                                               fontSize: 14,
//                                               height: 1.4,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   const SizedBox(height: 32),

//                                   // Sign Up Button
//                                   Obx(() => Container(
//                                         width: double.infinity,
//                                         height: 56,
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
//                                           ),
//                                           borderRadius: BorderRadius.circular(16),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Color(0xFF4facfe).withOpacity(0.3),
//                                               blurRadius: 12,
//                                               offset: const Offset(0, 6),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Material(
//                                           color: Colors.transparent,
//                                           child: InkWell(
//                                             borderRadius: BorderRadius.circular(16),
//                                             onTap: (_acceptTerms && !authController.isLoading.value)
//                                                 ? authController.signUp
//                                                 : null,
//                                             child: Center(
//                                               child: authController.isLoading.value
//                                                   ? const SizedBox(
//                                                       height: 24,
//                                                       width: 24,
//                                                       child: CircularProgressIndicator(
//                                                         color: Colors.white,
//                                                         strokeWidth: 2,
//                                                       ),
//                                                     )
//                                                   : Text(
//                                                       'إنشاء حساب',
//                                                       style: TextStyle(
//                                                         color: _acceptTerms
//                                                             ? Colors.white
//                                                             : Colors.white.withOpacity(0.5),
//                                                         fontSize: 18,
//                                                         fontWeight: FontWeight.w600,
//                                                       ),
//                                                     ),
//                                             ),
//                                           ),
//                                         ),
//                                       )),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(height: 30),

//                             // Login Link
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.2),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'لديك حساب بالفعل؟ ',
//                                     style: TextStyle(
//                                       color: Colors.white.withOpacity(0.8),
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Get.back();
//                                     },
//                                     child: const Text(
//                                       'تسجيل الدخول',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:auth_app/views/pages/signup_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../validators/auth_validators.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/custom_button.dart';

// class LoginPage extends StatelessWidget {
//   final AuthController authController = Get.put(AuthController());

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

//                 // Logo or App Icon
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

//                 const SizedBox(height: 10),

//                 // Forgot Password
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // Handle forgot password
//                     },
//                     child: const Text(
//                       'نسيت كلمة المرور؟',
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Login Button
//                 Obx(() => CustomButton(
//                       text: 'تسجيل الدخول',
//                       onPressed: authController.login,
//                       isLoading: authController.isLoading.value,
//                     )),

//                 const SizedBox(height: 30),

//                 // Divider
//                 Row(
//                   children: [
//                     const Expanded(child: Divider()),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'أو',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ),
//                     const Expanded(child: Divider()),
//                   ],
//                 ),

//                 const SizedBox(height: 30),

//                 // Sign Up Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'ليس لديك حساب؟ ',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Get.to(() => SignUpPage());
//                       },
//                       child: const Text(
//                         'إنشاء حساب',
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

// views/pages/login_page.dart - محدثة لتتوافق مع API الجديد
import 'package:auth_app/views/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../validators/auth_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

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

                // Logo or App Icon
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

                // تغيير حقل البريد الإلكتروني إلى اسم المستخدم
                CustomTextField(
                  controller: authController.nameController, // تغيير من emailController
                  label: 'اسم المستخدم', // تغيير النص
                  hint: 'أدخل اسم المستخدم', // تغيير النص
                  icon: Icons.person, // تغيير الأيقونة
                  keyboardType: TextInputType.text, // تغيير نوع الكيبورد
                  validator: (value) {
                    // تغيير validator
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستخدم';
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
                      validator: AuthValidators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                    )),

                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                Obx(() => CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: authController.login,
                      isLoading: authController.isLoading.value,
                    )),

                const SizedBox(height: 30),

                // معلومات للاختبار
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'بيانات الاختبار:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اسم المستخدم: mms',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'كلمة المرور: Awad2015*',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟ ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SignUpPage());
                      },
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:auth_app/pages/signup_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../validators/auth_validators.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/custom_button.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
//   final AuthController authController = Get.put(AuthController());
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

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
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF667eea),
//               Color(0xFF764ba2),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: Form(
//                   key: authController.loginFormKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 60),

//                       // Logo with Hero Animation
//                       Hero(
//                         tag: 'app_logo',
//                         child: Container(
//                           height: 120,
//                           width: 120,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.lock_person_rounded,
//                             size: 60,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // Welcome Text with Glass Effect
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.2),
//                             width: 1,
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'مرحباً بك',
//                               style: TextStyle(
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 shadows: [
//                                   Shadow(
//                                     offset: Offset(0, 2),
//                                     blurRadius: 4,
//                                     color: Colors.black26,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'سجل دخولك للمتابعة',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white.withOpacity(0.8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 50),

//                       // Form Container with Glass Effect
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.95),
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             // Email Field
//                             CustomTextField(
//                               controller: authController.emailController,
//                               label: 'البريد الإلكتروني',
//                               hint: 'أدخل بريدك الإلكتروني',
//                               icon: Icons.email_rounded,
//                               keyboardType: TextInputType.emailAddress,
//                               validator: AuthValidators.validateEmail,
//                             ),

//                             const SizedBox(height: 20),

//                             // Password Field
//                             Obx(() => CustomTextField(
//                                   controller: authController.passwordController,
//                                   label: 'كلمة المرور',
//                                   hint: 'أدخل كلمة المرور',
//                                   icon: Icons.lock_rounded,
//                                   obscureText: !authController.isPasswordVisible.value,
//                                   validator: AuthValidators.validatePassword,
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       authController.isPasswordVisible.value
//                                           ? Icons.visibility_rounded
//                                           : Icons.visibility_off_rounded,
//                                       color: Color(0xFF667eea),
//                                     ),
//                                     onPressed: authController.togglePasswordVisibility,
//                                   ),
//                                 )),

//                             const SizedBox(height: 16),

//                             // Forgot Password
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () {
//                                   // Handle forgot password
//                                 },
//                                 style: TextButton.styleFrom(
//                                   foregroundColor: Color(0xFF667eea),
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 child: const Text('نسيت كلمة المرور؟'),
//                               ),
//                             ),

//                             const SizedBox(height: 24),

//                             // Login Button
//                             Obx(() => Container(
//                                   width: double.infinity,
//                                   height: 56,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                                     ),
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Color(0xFF667eea).withOpacity(0.3),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 6),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       borderRadius: BorderRadius.circular(16),
//                                       onTap: authController.isLoading.value
//                                           ? null
//                                           : authController.login,
//                                       child: Center(
//                                         child: authController.isLoading.value
//                                             ? const SizedBox(
//                                                 height: 24,
//                                                 width: 24,
//                                                 child: CircularProgressIndicator(
//                                                   color: Colors.white,
//                                                   strokeWidth: 2,
//                                                 ),
//                                               )
//                                             : const Text(
//                                                 'تسجيل الدخول',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                       ),
//                                     ),
//                                   ),
//                                 )),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // Divider
//                       Row(
//                         children: [
//                           Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               'أو',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
//                         ],
//                       ),

//                       const SizedBox(height: 40),

//                       // Sign Up Link
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.2),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'ليس لديك حساب؟ ',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontSize: 16,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(
//                                   () => SignUpPage(),
//                                   transition: Transition.rightToLeftWithFade,
//                                   duration: const Duration(milliseconds: 400),
//                                 );
//                               },
//                               child: const Text(
//                                 'إنشاء حساب',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

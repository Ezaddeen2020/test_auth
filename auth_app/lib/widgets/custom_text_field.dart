// import 'package:flutter/material.dart';

// class CustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final Widget? suffixIcon;
//   final VoidCallback? onTap;
//   final bool readOnly;

//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.icon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.suffixIcon,
//     this.onTap,
//     this.readOnly = false,
//   }) : super(key: key);

//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool _isFocused = false;
//   bool _hasError = false;
//   String? _errorText;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onFocusChange(bool hasFocus) {
//     setState(() {
//       _isFocused = hasFocus;
//     });
//     if (hasFocus) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8, right: 4),
//           child: Text(
//             widget.label,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//           ),
//         ),

//         // Text Field Container
//         AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color:
//                         _isFocused ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
//                     blurRadius: _isFocused ? 8 : 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Focus(
//                 onFocusChange: _onFocusChange,
//                 child: TextFormField(
//                   controller: widget.controller,
//                   obscureText: widget.obscureText,
//                   keyboardType: widget.keyboardType,
//                   readOnly: widget.readOnly,
//                   onTap: widget.onTap,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: widget.hint,
//                     hintStyle: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 15,
//                       fontWeight: FontWeight.w400,
//                     ),
//                     prefixIcon: Container(
//                       margin: const EdgeInsets.all(12),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _isFocused
//                             ? Colors.blue.withOpacity(0.1)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         widget.icon,
//                         color: _isFocused ? Colors.blue[600] : Colors.grey[600],
//                         size: 20,
//                       ),
//                     ),
//                     suffixIcon: widget.suffixIcon,
//                     filled: true,
//                     fillColor:
//                         _isFocused ? Colors.blue.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.grey.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.grey.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.blue[600]!,
//                         width: 2,
//                       ),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.red[400]!,
//                         width: 1,
//                       ),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Colors.red[600]!,
//                         width: 2,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 16,
//                     ),
//                     errorStyle: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   validator: (value) {
//                     final error = widget.validator?.call(value);
//                     setState(() {
//                       _hasError = error != null;
//                       _errorText = error;
//                     });
//                     return error;
//                   },
//                 ),
//               ),
//             );
//           },
//         ),

//         // Error message with animation
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           height: _hasError ? 24 : 0,
//           child: _hasError
//               ? Padding(
//                   padding: const EdgeInsets.only(top: 4, right: 4),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 16,
//                         color: Colors.red[600],
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           _errorText ?? '',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.red[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final bool obscureText;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//   final TextInputType keyboardType;

//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.icon,
//     this.obscureText = false,
//     this.suffixIcon,
//     this.validator,
//     this.keyboardType = TextInputType.text,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         suffixIcon: suffixIcon,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.blue, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//     );
//   }
// }

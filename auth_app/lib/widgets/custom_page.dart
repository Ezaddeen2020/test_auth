// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // Custom Page Transitions
// class CustomPageTransitions {
//   // Slide transition from right to left with fade
//   static Transition get slideRightToLeftWithFade => Transition.rightToLeftWithFade;

//   // Slide transition from left to right with fade
//   static Transition get slideLeftToRightWithFade => Transition.leftToRightWithFade;

//   // Custom fade transition
//   static Transition get fadeTransition => Transition.fade;

//   // Custom zoom transition
//   static Transition get zoomTransition => Transition.zoom;
// }

// // Custom Page Route with enhanced transitions
// class CustomPageRoute<T> extends PageRouteBuilder<T> {
//   final Widget child;
//   final AxisDirection direction;
//   final Duration duration;

//   CustomPageRoute({
//     required this.child,
//     this.direction = AxisDirection.left,
//     this.duration = const Duration(milliseconds: 400),
//   }) : super(
//           transitionDuration: duration,
//           reverseTransitionDuration: duration,
//           pageBuilder: (context, animation, secondaryAnimation) => child,
//         );

//   @override
//   Widget buildTransitions(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation, Widget child) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: _getBeginOffset(direction),
//         end: Offset.zero,
//       ).animate(CurvedAnimation(
//         parent: animation,
//         curve: Curves.easeInOutCubic,
//       )),
//       child: FadeTransition(
//         opacity: animation,
//         child: child,
//       ),
//     );
//   }

//   Offset _getBeginOffset(AxisDirection direction) {
//     switch (direction) {
//       case AxisDirection.up:
//         return const Offset(0, 1);
//       case AxisDirection.down:
//         return const Offset(0, -1);
//       case AxisDirection.right:
//         return const Offset(-1, 0);
//       case AxisDirection.left:
//         return const Offset(1, 0);
//     }
//   }
// }

// // Smooth navigation helper
// class SmoothNavigation {
//   static void navigateToPage(
//     Widget page, {
//     Transition transition = Transition.rightToLeftWithFade,
//     Duration duration = const Duration(milliseconds: 400),
//     bool clearStack = false,
//   }) {
//     if (clearStack) {
//       Get.offAll(
//         () => page,
//         transition: transition,
//         duration: duration,
//       );
//     } else {
//       Get.to(
//         () => page,
//         transition: transition,
//         duration: duration,
//       );
//     }
//   }

//   static void navigateBack() {
//     Get.back();
//   }

//   static void navigateReplace(
//     Widget page, {
//     Transition transition = Transition.rightToLeftWithFade,
//     Duration duration = const Duration(milliseconds: 400),
//   }) {
//     Get.off(
//       () => page,
//       transition: transition,
//       duration: duration,
//     );
//   }
// }

// // Enhanced Animation Helper
// class AnimationHelper {
//   // Create fade in animation
//   static AnimationController createFadeController({
//     required TickerProvider vsync,
//     Duration duration = const Duration(milliseconds: 600),
//   }) {
//     return AnimationController(duration: duration, vsync: vsync);
//   }

//   // Create slide animation
//   static AnimationController createSlideController({
//     required TickerProvider vsync,
//     Duration duration = const Duration(milliseconds: 400),
//   }) {
//     return AnimationController(duration: duration, vsync: vsync);
//   }

//   // Create scale animation
//   static AnimationController createScaleController({
//     required TickerProvider vsync,
//     Duration duration = const Duration(milliseconds: 300),
//   }) {
//     return AnimationController(duration: duration, vsync: vsync);
//   }

//   // Staggered animation helper
//   static List<Animation<double>> createStaggeredAnimations({
//     required AnimationController controller,
//     required int count,
//     Duration delay = const Duration(milliseconds: 100),
//   }) {
//     List<Animation<double>> animations = [];

//     for (int i = 0; i < count; i++) {
//       final start = (i * delay.inMilliseconds) / controller.duration!.inMilliseconds;
//       final end = ((i * delay.inMilliseconds) + 300) / controller.duration!.inMilliseconds;

//       animations.add(
//         Tween<double>(begin: 0.0, end: 1.0).animate(
//           CurvedAnimation(
//             parent: controller,
//             curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
//           ),
//         ),
//       );
//     }

//     return animations;
//   }
// }

// // Loading Animation Widget
// class LoadingAnimation extends StatefulWidget {
//   final Color color;
//   final double size;

//   const LoadingAnimation({
//     Key? key,
//     this.color = Colors.blue,
//     this.size = 24.0,
//   }) : super(key: key);

//   @override
//   _LoadingAnimationState createState() => _LoadingAnimationState();
// }

// class _LoadingAnimationState extends State<LoadingAnimation> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: widget.size,
//           height: widget.size,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.0,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               widget.color.withOpacity(0.3 + (0.7 * _animation.value)),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Pulse Animation Widget
// class PulseAnimation extends StatefulWidget {
//   final Widget child;
//   final Duration duration;
//   final double minScale;
//   final double maxScale;

//   const PulseAnimation({
//     Key? key,
//     required this.child,
//     this.duration = const Duration(milliseconds: 1000),
//     this.minScale = 0.95,
//     this.maxScale = 1.05,
//   }) : super(key: key);

//   @override
//   _PulseAnimationState createState() => _PulseAnimationState();
// }

// class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(duration: widget.duration, vsync: this);
//     _animation = Tween<double>(
//       begin: widget.minScale,
//       end: widget.maxScale,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _animation.value,
//           child: widget.child,
//         );
//       },
//     );
//   }
// }

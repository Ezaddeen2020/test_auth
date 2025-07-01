// // lib/widgets/connection_type_indicator.dart - النسخة المبسطة
// import 'package:auth_app/pages/configration/models/network_info_model.dart';
// import 'package:auth_app/pages/configration/controllers/network_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ConnectionTypeIndicator extends StatelessWidget {
//   const ConnectionTypeIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final NetworkController controller = Get.find();

//     return Obx(() {
//       final info = controller.networkInfo.value;
//       final statusColor = controller.getConnectionStatusColor();

//       // تحديد إذا كانت الشاشة صغيرة
//       final isSmallScreen = Get.width < 400;
//       final isVerySmallScreen = Get.width < 320;

//       return LayoutBuilder(
//         builder: (context, constraints) {
//           return Container(
//             constraints: BoxConstraints(
//               maxWidth: constraints.maxWidth,
//               minWidth: isSmallScreen ? 100 : 140,
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: isSmallScreen ? 8 : 12,
//               vertical: isSmallScreen ? 6 : 10,
//             ),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//               border: Border.all(
//                 color: statusColor.withOpacity(0.3),
//                 width: isSmallScreen ? 1 : 1.5,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   _getConnectionIcon(info.connectionType),
//                   color: statusColor,
//                   size: isSmallScreen ? 16 : 20,
//                 ),
//                 SizedBox(width: isSmallScreen ? 6 : 8),
//                 Flexible(
//                   child: Text(
//                     _getAdaptiveText(controller, isVerySmallScreen, isSmallScreen),
//                     style: TextStyle(
//                       fontSize: isVerySmallScreen
//                           ? 10
//                           : isSmallScreen
//                               ? 12
//                               : 14,
//                       fontWeight: FontWeight.w600,
//                       color: statusColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     });
//   }

//   String _getAdaptiveText(NetworkController controller, bool isVerySmall, bool isSmall) {
//     final originalText = controller.getConnectionStatusText();

//     if (isVerySmall) {
//       // للشاشات الصغيرة جداً (أقل من 320px)
//       if (originalText.contains('غير متصل')) return 'غير متصل';
//       if (originalText.contains('LAN')) return 'LAN';
//       if (originalText.contains('WAN')) return 'WAN';
//       return 'متصل';
//     } else if (isSmall) {
//       // للهواتف العادية (320-400px)
//       if (originalText.contains('غير متصل')) return 'غير متصل';
//       if (originalText.contains('LAN')) return 'متصل - LAN';
//       if (originalText.contains('WAN')) return 'متصل - WAN';
//       return originalText.length > 15 ? '${originalText.substring(0, 12)}...' : originalText;
//     }

//     // للشاشات الكبيرة
//     return originalText;
//   }

//   IconData _getConnectionIcon(ConnectionType type) {
//     switch (type) {
//       case ConnectionType.lan:
//         return Icons.wifi_rounded;
//       case ConnectionType.wan:
//         return Icons.signal_cellular_4_bar_rounded;
//       case ConnectionType.none:
//         return Icons.signal_wifi_off_rounded;
//     }
//   }
// }

import 'package:auth_app/pages/configration/models/network_info_model.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ConnectionTypeIndicator extends StatelessWidget {
  const ConnectionTypeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    return Obx(() {
      final info = controller.networkInfo.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: controller.getConnectionStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.getConnectionStatusColor(),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getConnectionIcon(info.connectionType),
              color: controller.getConnectionStatusColor(),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              controller.getConnectionStatusText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: controller.getConnectionStatusColor(),
              ),
            ),
          ],
        ),
      );
    });
  }

  IconData _getConnectionIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.lan:
        return Icons.wifi;
      case ConnectionType.wan:
        return Icons.signal_cellular_4_bar;
      case ConnectionType.none:
        return Icons.signal_wifi_off;
    }
  }
}

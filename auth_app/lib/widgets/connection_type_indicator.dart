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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

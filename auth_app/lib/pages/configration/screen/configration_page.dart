import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:auth_app/pages/configration/screen/components/action_buttons.dart';
import 'package:auth_app/pages/configration/screen/components/connection_status_card.dart';
import 'package:auth_app/pages/configration/screen/components/connection_type_card.dart';
import 'package:auth_app/pages/configration/screen/components/discovered_devices_card.dart';
import 'package:auth_app/pages/configration/screen/components/network_info_card.dart';
import 'package:auth_app/pages/configration/screen/components/printer_config_card.dart';
import 'package:auth_app/pages/configration/screen/components/subnet_config_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigurationController>(
      init: ConfigurationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'إعدادات الشبكة والطابعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue[700],
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkInfoCard(controller: controller),
                const SizedBox(height: 20),
                ConnectionTypeCard(controller: controller),
                if (controller.connectionType == 'LAN') ...[
                  const SizedBox(height: 20),
                  SubnetConfigCard(controller: controller),
                ],
                const SizedBox(height: 20),
                PrinterConfigCard(controller: controller),
                if (controller.discoveredDevices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  DiscoveredDevicesCard(controller: controller),
                ],
                if (controller.connectionStatus.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ConnectionStatusCard(controller: controller),
                ],
                const SizedBox(height: 30),
                ActionButtons(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}


  // // lib/pages/configuration/configuration_page.dart

  // import 'package:auth_app/pages/configration/controller/configration_controller.dart';
  // import 'package:flutter/material.dart';
  // import 'package:get/get.dart';

  // class ConfigurationPage extends StatelessWidget {
  //   const ConfigurationPage({super.key});

  //   @override
  //   Widget build(BuildContext context) {
  //     return GetBuilder<ConfigurationController>(
  //       init: ConfigurationController(),
  //       builder: (controller) {
  //         return Scaffold(
  //           backgroundColor: Colors.grey[50],
  //           appBar: AppBar(
  //             title: const Text(
  //               'إعدادات الشبكة والطابعة',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             backgroundColor: Colors.blue[700],
  //             elevation: 0,
  //             centerTitle: true,
  //           ),
  //           //======================================================================================//
  //           body: SingleChildScrollView(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Network Status Info Section
  //                 _buildSectionCard(
  //                   title: 'معلومات الشبكة الحالية',
  //                   icon: Icons.network_check,
  //                   child: Container(
  //                     padding: const EdgeInsets.all(15),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue[50],
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(color: Colors.blue[200]!),
  //                     ),
  //                     child: Text(
  //                       controller.getNetworkStatusInfo(),
  //                       style: TextStyle(
  //                         color: Colors.blue[800],
  //                         fontSize: 14,
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Network Connection Type Section
  //                 _buildSectionCard(
  //                   title: 'نوع الاتصال',
  //                   icon: Icons.network_wifi,
  //                   child: Column(
  //                     children: [
  //                       RadioListTile<String>(
  //                         title: const Text('شبكة محلية (LAN)'),
  //                         subtitle: const Text('للاتصال داخل الشبكة المحلية'),
  //                         value: 'LAN',
  //                         groupValue: controller.connectionType,
  //                         onChanged: controller.setConnectionType,
  //                         activeColor: Colors.blue[700],
  //                       ),
  //                       RadioListTile<String>(
  //                         title: const Text('شبكة واسعة (WAN)'),
  //                         subtitle: const Text('للاتصال عبر الإنترنت'),
  //                         value: 'WAN',
  //                         groupValue: controller.connectionType,
  //                         onChanged: controller.setConnectionType,
  //                         activeColor: Colors.blue[700],
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Subnet Configuration for LAN
  //                 if (controller.connectionType == 'LAN')
  //                   _buildSectionCard(
  //                     title: 'إعدادات الشبكة الفرعية',
  //                     icon: Icons.lan,
  //                     child: TextFormField(
  //                       controller: controller.customSubnetController,
  //                       decoration: InputDecoration(
  //                         labelText: 'الشبكة الفرعية',
  //                         hintText: '192.168.1',
  //                         prefixIcon: const Icon(Icons.settings_ethernet),
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                           borderSide: BorderSide(color: Colors.blue[700]!),
  //                         ),
  //                       ),
  //                     ),
  //                   ),

  //                 if (controller.connectionType == 'LAN') const SizedBox(height: 20),

  //                 // Printer Configuration Section
  //                 _buildSectionCard(
  //                   title: 'إعدادات الطابعة',
  //                   icon: Icons.print,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // MAC Address Input
  //                       TextFormField(
  //                         controller: controller.macAddressController,
  //                         decoration: InputDecoration(
  //                           labelText: 'عنوان MAC للطابعة',
  //                           hintText: '00:00:00:00:00:00',
  //                           prefixIcon: const Icon(Icons.router),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(color: Colors.blue[700]!),
  //                           ),
  //                         ),
  //                         onChanged: controller.onMacAddressChanged,
  //                       ),

  //                       const SizedBox(height: 15),

  //                       // Device Name Input
  //                       TextFormField(
  //                         controller: controller.deviceNameController,
  //                         decoration: InputDecoration(
  //                           labelText: 'اسم الجهاز',
  //                           hintText: 'أدخل اسم الجهاز',
  //                           prefixIcon: const Icon(Icons.device_hub),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(color: Colors.blue[700]!),
  //                           ),
  //                         ),
  //                       ),

  //                       const SizedBox(height: 15),

  //                       // IP Address Input (for WAN or manual entry)
  //                       if (controller.connectionType == 'WAN' ||
  //                           controller.ipAddressController.text.isNotEmpty)
  //                         Column(
  //                           children: [
  //                             TextFormField(
  //                               controller: controller.ipAddressController,
  //                               decoration: InputDecoration(
  //                                 labelText: 'عنوان IP للطابعة',
  //                                 hintText: '192.168.1.100',
  //                                 prefixIcon: const Icon(Icons.computer),
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(10),
  //                                   borderSide: BorderSide(color: Colors.blue[700]!),
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(height: 15),
  //                           ],
  //                         ),

  //                       // Auto-detect button
  //                       ElevatedButton.icon(
  //                         onPressed: controller.isLoading ? null : controller.autoDetectPrinter,
  //                         icon: controller.isLoading
  //                             ? const SizedBox(
  //                                 width: 16,
  //                                 height: 16,
  //                                 child:
  //                                     CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  //                               )
  //                             : const Icon(Icons.search),
  //                         label: Text(controller.isLoading
  //                             ? (controller.isScanning ? 'جاري البحث...' : 'جاري التحميل...')
  //                             : 'البحث التلقائي عن الطابعة'),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.orange[600],
  //                           foregroundColor: Colors.white,
  //                           minimumSize: const Size(double.infinity, 50),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Discovered Devices Section
  //                 if (controller.discoveredDevices.isNotEmpty)
  //                   _buildSectionCard(
  //                     title: 'الطابعات المكتشفة',
  //                     icon: Icons.devices,
  //                     child: Column(
  //                       children: controller.discoveredDevices.map((device) {
  //                         return Card(
  //                           margin: const EdgeInsets.only(bottom: 10),
  //                           child: ListTile(
  //                             leading: Icon(
  //                               Icons.print,
  //                               color: device.isOnline ? Colors.green : Colors.grey,
  //                             ),
  //                             title: Text(device.name),
  //                             subtitle: Text('IP: ${device.ip}\nMAC: ${device.macAddress}'),
  //                             trailing: Icon(
  //                               device.isOnline ? Icons.check_circle : Icons.error,
  //                               color: device.isOnline ? Colors.green : Colors.red,
  //                             ),
  //                             onTap: () => controller.selectDiscoveredDevice(device),
  //                           ),
  //                         );
  //                       }).toList(),
  //                     ),
  //                   ),

  //                 if (controller.discoveredDevices.isNotEmpty) const SizedBox(height: 20),

  //                 // Connection Status Section
  //                 if (controller.connectionStatus.isNotEmpty)
  //                   _buildSectionCard(
  //                     title: 'حالة الاتصال',
  //                     icon: Icons.info,
  //                     child: Container(
  //                       padding: const EdgeInsets.all(15),
  //                       decoration: BoxDecoration(
  //                         color: controller.isConnected ? Colors.green[50] : Colors.red[50],
  //                         borderRadius: BorderRadius.circular(10),
  //                         border: Border.all(
  //                           color: controller.isConnected ? Colors.green : Colors.red,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Icon(
  //                             controller.isConnected ? Icons.check_circle : Icons.error,
  //                             color: controller.isConnected ? Colors.green : Colors.red,
  //                           ),
  //                           const SizedBox(width: 10),
  //                           Expanded(
  //                             child: Text(
  //                               controller.connectionStatus,
  //                               style: TextStyle(
  //                                 color: controller.isConnected ? Colors.green[800] : Colors.red[800],
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                 const SizedBox(height: 30),

  //                 // Action Buttons
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: ElevatedButton.icon(
  //                         onPressed: controller.testConnection,
  //                         icon: const Icon(Icons.wifi_tethering),
  //                         label: const Text('اختبار الاتصال'),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.green[600],
  //                           foregroundColor: Colors.white,
  //                           minimumSize: const Size(0, 50),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 15),
  //                     Expanded(
  //                       child: ElevatedButton.icon(
  //                         onPressed: controller.saveConfiguration,
  //                         icon: const Icon(Icons.save),
  //                         label: const Text('حفظ الإعدادات'),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.blue[700],
  //                           foregroundColor: Colors.white,
  //                           minimumSize: const Size(0, 50),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),

  //                 const SizedBox(height: 15),

  //                 // Clear Configuration Button
  //                 ElevatedButton.icon(
  //                   onPressed: controller.clearConfiguration,
  //                   icon: const Icon(Icons.clear),
  //                   label: const Text('مسح الإعدادات'),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.red[600],
  //                     foregroundColor: Colors.white,
  //                     minimumSize: const Size(double.infinity, 50),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }

  //   Widget _buildSectionCard({
  //     required String title,
  //     required IconData icon,
  //     required Widget child,
  //   }) {
  //     return Card(
  //       elevation: 3,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(icon, color: Colors.blue[700], size: 24),
  //                 const SizedBox(width: 10),
  //                 Text(
  //                   title,
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.grey[800],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 15),
  //             child,
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }

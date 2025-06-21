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
//             title: const Text('إعدادات الشبكة والطابعة',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
//             backgroundColor: Colors.blue[700],
//             elevation: 0,
//             centerTitle: true,
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // معلومات الشبكة
//                 _buildCard(
//                   title: 'معلومات الشبكة الحالية',
//                   icon: Icons.network_check,
//                   child: _buildInfoContainer(controller.getNetworkStatusInfo(), Colors.blue),
//                 ),

//                 const SizedBox(height: 20),

//                 // نوع الاتصال
//                 _buildCard(
//                   title: 'نوع الاتصال',
//                   icon: Icons.network_wifi,
//                   child: Column(
//                     children: [
//                       _buildRadioTile('شبكة محلية (LAN)', 'للاتصال داخل الشبكة المحلية', 'LAN',
//                           controller.connectionType, controller.setConnectionType),
//                       _buildRadioTile('شبكة واسعة (WAN)', 'للاتصال عبر الإنترنت', 'WAN',
//                           controller.connectionType, controller.setConnectionType),
//                     ],
//                   ),
//                 ),

//                 // إعدادات الشبكة الفرعية (للـ LAN فقط)
//                 if (controller.connectionType == 'LAN') ...[
//                   const SizedBox(height: 20),
//                   _buildCard(
//                     title: 'إعدادات الشبكة الفرعية',
//                     icon: Icons.lan,
//                     child: _buildTextField(controller.customSubnetController, 'الشبكة الفرعية',
//                         '192.168.1', Icons.settings_ethernet),
//                   ),
//                 ],

//                 const SizedBox(height: 20),

//                 // إعدادات الطابعة
//                 _buildCard(
//                   title: 'إعدادات الطابعة',
//                   icon: Icons.print,
//                   child: Column(
//                     children: [
//                       _buildTextField(controller.macAddressController, 'عنوان MAC *',
//                           '00:1A:2B:3C:4D:5E', Icons.fingerprint,
//                           onChanged: controller.onMacAddressChanged),
//                       const SizedBox(height: 15),
//                       _buildTextField(controller.deviceNameController, 'اسم الجهاز *',
//                           'اسم الطابعة', Icons.devices),
//                       if (controller.connectionType == 'WAN') ...[
//                         const SizedBox(height: 15),
//                         _buildTextField(controller.ipAddressController, 'عنوان IP *',
//                             '192.168.1.100', Icons.computer),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // الأجهزة المكتشفة
//                 if (controller.discoveredDevices.isNotEmpty) ...[
//                   const SizedBox(height: 20),
//                   _buildCard(
//                     title: 'الطابعات المكتشفة',
//                     icon: Icons.devices,
//                     child: Column(
//                       children: controller.discoveredDevices
//                           .map((device) => _buildDeviceCard(device, controller))
//                           .toList(),
//                     ),
//                   ),
//                 ],

//                 // حالة الاتصال
//                 if (controller.connectionStatus.isNotEmpty) ...[
//                   const SizedBox(height: 20),
//                   _buildCard(
//                     title: 'حالة الاتصال',
//                     icon: Icons.info,
//                     child: _buildStatusContainer(controller),
//                   ),
//                 ],

//                 const SizedBox(height: 30),

//                 // أزرار العمليات
//                 _buildActionButtons(controller),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// بناء الكارد الأساسي
//   Widget _buildCard({required String title, required IconData icon, required Widget child}) {
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
//                 Text(title,
//                     style: TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
//               ],
//             ),
//             const SizedBox(height: 15),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   /// بناء حقل النص
//   Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon,
//       {Function(String)? onChanged}) {
//     return TextFormField(
//       controller: controller,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.blue[700]!),
//         ),
//       ),
//     );
//   }

//   /// بناء RadioListTile
//   Widget _buildRadioTile(
//       String title, String subtitle, String value, String groupValue, Function(String?) onChanged) {
//     return RadioListTile<String>(
//       title: Text(title),
//       subtitle: Text(subtitle),
//       value: value,
//       groupValue: groupValue,
//       onChanged: onChanged,
//       activeColor: Colors.blue[700],
//     );
//   }

//   /// بناء حاوية المعلومات
//   Widget _buildInfoContainer(String text, MaterialColor color) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: color[50],
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color[200]!),
//       ),
//       child: Text(text, style: TextStyle(color: color[800], fontSize: 14)),
//     );
//   }

//   /// بناء كارد الجهاز
//   Widget _buildDeviceCard(device, ConfigurationController controller) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         leading: Icon(Icons.print, color: device.isOnline ? Colors.green : Colors.grey),
//         title: Text(device.name),
//         subtitle: Text('IP: ${device.ip}\nMAC: ${device.macAddress}'),
//         trailing: Icon(device.isOnline ? Icons.check_circle : Icons.error,
//             color: device.isOnline ? Colors.green : Colors.red),
//         onTap: () => controller.selectDiscoveredDevice(device),
//       ),
//     );
//   }

//   /// بناء حاوية الحالة
//   Widget _buildStatusContainer(ConfigurationController controller) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: controller.isConnected ? Colors.green[50] : Colors.red[50],
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: controller.isConnected ? Colors.green : Colors.red),
//       ),
//       child: Row(
//         children: [
//           Icon(controller.isConnected ? Icons.check_circle : Icons.error,
//               color: controller.isConnected ? Colors.green : Colors.red),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(controller.connectionStatus,
//                 style: TextStyle(
//                   color: controller.isConnected ? Colors.green[800] : Colors.red[800],
//                   fontWeight: FontWeight.w500,
//                 )),
//           ),
//         ],
//       ),
//     );
//   }

//   /// بناء أزرار العمليات
//   Widget _buildActionButtons(ConfigurationController controller) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: controller.isLoading ? null : controller.autoDetectPrinter,
//                 icon: controller.isLoading
//                     ? const SizedBox(
//                         width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Icon(Icons.search),
//                 label: Text(controller.isLoading ? 'جاري البحث...' : 'البحث التلقائي'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[700],
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: controller.isLoading ? null : controller.testConnection,
//                 icon: const Icon(Icons.network_check),
//                 label: const Text('اختبار الاتصال'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange[700],
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: controller.saveConfiguration,
//                 icon: const Icon(Icons.save),
//                 label: const Text('حفظ الإعدادات'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green[700],
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: controller.clearConfiguration,
//                 icon: const Icon(Icons.clear),
//                 label: const Text('مسح الإعدادات'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red[700],
//                   side: BorderSide(color: Colors.red[700]!),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// lib/pages/configuration/configuration_page.dart

// lib/pages/configuration/configuration_page.dart

import 'package:auth_app/pages/configration/controller/configration_controller.dart';
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
            title: const Text('إعدادات الشبكة والطابعة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.blue[700],
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // تحذير Hotspot
                if (_isHotspotNetwork(controller)) _buildHotspotWarning(),

                // معلومات الشبكة
                _buildCard(
                  title: 'معلومات الشبكة الحالية',
                  icon: Icons.network_check,
                  child: _buildInfoContainer(controller.getNetworkStatusInfo(), Colors.blue),
                ),

                const SizedBox(height: 20),

                // نوع الاتصال
                _buildCard(
                  title: 'نوع الاتصال',
                  icon: Icons.network_wifi,
                  child: Column(
                    children: [
                      _buildRadioTile('شبكة محلية (LAN)', 'للاتصال داخل الشبكة المحلية', 'LAN',
                          controller.connectionType, controller.setConnectionType),
                      _buildRadioTile('شبكة واسعة (WAN)', 'للاتصال عبر الإنترنت', 'WAN',
                          controller.connectionType, controller.setConnectionType),
                    ],
                  ),
                ),

                // إعدادات الشبكة الفرعية (للـ LAN فقط)
                if (controller.connectionType == 'LAN') ...[
                  const SizedBox(height: 20),
                  _buildCard(
                    title: 'إعدادات الشبكة الفرعية',
                    icon: Icons.lan,
                    child: _buildTextField(controller.customSubnetController, 'الشبكة الفرعية',
                        '192.168.1', Icons.settings_ethernet),
                  ),
                ],

                const SizedBox(height: 20),

                // إعدادات الطابعة
                _buildCard(
                  title: 'إعدادات الطابعة',
                  icon: Icons.print,
                  child: Column(
                    children: [
                      _buildTextField(controller.macAddressController, 'عنوان MAC *',
                          '00:1A:2B:3C:4D:5E', Icons.fingerprint,
                          onChanged: controller.onMacAddressChanged),
                      const SizedBox(height: 15),
                      _buildTextField(controller.deviceNameController, 'اسم الجهاز *',
                          'اسم الطابعة', Icons.devices),
                      if (controller.connectionType == 'WAN') ...[
                        const SizedBox(height: 15),
                        _buildTextField(controller.ipAddressController, 'عنوان IP *',
                            '192.168.1.100', Icons.computer),
                      ],
                    ],
                  ),
                ),

                // الأجهزة المكتشفة
                if (controller.discoveredDevices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildCard(
                    title: 'الطابعات المكتشفة',
                    icon: Icons.devices,
                    child: Column(
                      children: controller.discoveredDevices
                          .map((device) => _buildDeviceCard(device, controller))
                          .toList(),
                    ),
                  ),
                ],

                // حالة الاتصال
                if (controller.connectionStatus.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildCard(
                    title: 'حالة الاتصال',
                    icon: Icons.info,
                    child: _buildStatusContainer(controller),
                  ),
                ],

                const SizedBox(height: 30),

                // أزرار العمليات
                _buildActionButtons(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  /// التحقق من شبكة Hotspot
  bool _isHotspotNetwork(ConfigurationController controller) {
    final networkName = controller.currentNetworkName?.toLowerCase() ?? '';
    final hotspotIndicators = [
      'galaxy',
      'iphone',
      'android',
      'samsung',
      'huawei',
      'xiaomi',
      'hotspot',
      'mobile',
      'phone',
      'nokia',
      'lg',
      'sony',
      'oneplus'
    ];

    return hotspotIndicators.any((indicator) => networkName.contains(indicator));
  }

  /// بناء تحذير Hotspot
  Widget _buildHotspotWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700], size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تم اكتشاف Mobile Hotspot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'أنت متصل بـ Mobile Hotspot. قد لا تتمكن من العثور على الطابعات بسبب قيود الشبكة.\n\n'
            '💡 الحلول المقترحة:\n'
            '• اتصل بشبكة WiFi تقليدية (راوتر)\n'
            '• تأكد من اتصال الطابعة بنفس الشبكة\n'
            '• استخدم "اختبار طابعة محددة" إذا كنت تعرف IP الطابعة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء الكارد الأساسي
  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  /// بناء حقل النص
  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon,
      {Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
      ),
    );
  }

  /// بناء RadioListTile
  Widget _buildRadioTile(
      String title, String subtitle, String value, String groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.blue[700],
    );
  }

  /// بناء حاوية المعلومات
  Widget _buildInfoContainer(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color[200]!),
      ),
      child: Text(text, style: TextStyle(color: color[800], fontSize: 14)),
    );
  }

  /// بناء كارد الجهاز
  Widget _buildDeviceCard(device, ConfigurationController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.print, color: device.isOnline ? Colors.green : Colors.grey),
        title: Text(device.name),
        subtitle: Text('IP: ${device.ip}\nMAC: ${device.macAddress}'),
        trailing: Icon(device.isOnline ? Icons.check_circle : Icons.error,
            color: device.isOnline ? Colors.green : Colors.red),
        onTap: () => controller.selectDiscoveredDevice(device),
      ),
    );
  }

  /// بناء حاوية الحالة
  Widget _buildStatusContainer(ConfigurationController controller) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: controller.isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: controller.isConnected ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(controller.isConnected ? Icons.check_circle : Icons.error,
              color: controller.isConnected ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(controller.connectionStatus,
                style: TextStyle(
                  color: controller.isConnected ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  /// بناء أزرار العمليات
  Widget _buildActionButtons(ConfigurationController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isLoading ? null : controller.autoDetectPrinter,
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search),
                label: Text(controller.isLoading ? 'جاري البحث...' : 'البحث التلقائي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isLoading ? null : controller.testConnection,
                icon: const Icon(Icons.network_check),
                label: const Text('اختبار الاتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // أزرار التشخيص الجديدة
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.isLoading ? null : controller.runNetworkDiagnostic,
                icon: const Icon(Icons.analytics),
                label: const Text('تشخيص الشبكة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple[700],
                  side: BorderSide(color: Colors.purple[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.isLoading ? null : controller.testSpecificPrinter,
                icon: const Icon(Icons.print_outlined),
                label: const Text('اختبار طابعة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo[700],
                  side: BorderSide(color: Colors.indigo[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.saveConfiguration,
                icon: const Icon(Icons.save),
                label: const Text('حفظ الإعدادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.clearConfiguration,
                icon: const Icon(Icons.clear),
                label: const Text('مسح الإعدادات'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// import 'package:auth_app/pages/configration/controller/configration_controller.dart';
// import 'package:auth_app/pages/configration/screen/components/action_buttons.dart';
// import 'package:auth_app/pages/configration/screen/components/connection_status_card.dart';
// import 'package:auth_app/pages/configration/screen/components/connection_type_card.dart';
// import 'package:auth_app/pages/configration/screen/components/discovered_devices_card.dart';
// import 'package:auth_app/pages/configration/screen/components/network_info_card.dart';
// import 'package:auth_app/pages/configration/screen/components/printer_config_card.dart';
// import 'package:auth_app/pages/configration/screen/components/subnet_config_card.dart';
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
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextButton(
//                     onPressed: () {
//                       Get.toNamed('/login');
//                     },
//                     child: const Text('go to login')),
//                 NetworkInfoCard(controller: controller),
//                 const SizedBox(height: 20),
//                 ConnectionTypeCard(controller: controller),
//                 if (controller.connectionType == 'LAN') ...[
//                   const SizedBox(height: 20),
//                   SubnetConfigCard(controller: controller),
//                 ],
//                 const SizedBox(height: 20),
//                 PrinterConfigCard(controller: controller),
//                 if (controller.discoveredDevices.isNotEmpty) ...[
//                   const SizedBox(height: 20),
//                   DeviceInfoCard(controller: controller),
//                 ],
//                 if (controller.connectionStatus.isNotEmpty) ...[
//                   const SizedBox(height: 20),
//                   ConnectionStatusCard(controller: controller),
//                 ],
//                 const SizedBox(height: 30),
//                 ActionButtons(controller: controller),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

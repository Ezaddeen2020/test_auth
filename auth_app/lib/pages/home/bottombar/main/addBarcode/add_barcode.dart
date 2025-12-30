import 'package:auth_app/pages/home/bottombar/main/addBarcode/controller/addBar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_widget/barcode_widget.dart';

class AddBarcode extends StatelessWidget {
  const AddBarcode({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(BarcodeController());
    final controller = Get.find<BarcodeController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إنشاء باركود SAP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.clearForm,
            tooltip: 'مسح الحقول',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات المنتج
              _buildSectionCard(
                title: 'معلومات المنتج',
                icon: Icons.inventory_2,
                children: [
                  _buildTextField(
                    controller: controller.productNameController,
                    label: 'اسم المنتج',
                    icon: Icons.shopping_bag,
                    hint: 'أدخل اسم المنتج',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.productCodeController,
                    label: 'كود المنتج *',
                    icon: Icons.qr_code_2,
                    hint: 'أدخل كود المنتج',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: controller.priceController,
                          label: 'السعر',
                          icon: Icons.attach_money,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: controller.quantityController,
                          label: 'الكمية',
                          icon: Icons.inventory,
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // نوع الباركود
              _buildSectionCard(
                title: 'نوع الباركود',
                icon: Icons.category,
                children: [
                  Obx(() => DropdownButtonFormField<Barcode>(
                        value: controller.selectedBarcodeType.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.format_list_bulleted),
                          labelText: 'اختر نوع الباركود',
                        ),
                        items: controller.barcodeTypes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.onBarcodeTypeChanged(value);
                          }
                        },
                      )),
                ],
              ),

              const SizedBox(height: 24),

              // زر إنشاء الباركود
              ElevatedButton.icon(
                onPressed: controller.generateBarcode,
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text(
                  'إنشاء الباركود',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),

              const SizedBox(height: 24),

              // عرض الباركود
              Obx(() => controller.showBarcode.value
                  ? _buildBarcodeDisplay(controller)
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        // fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildBarcodeDisplay(BarcodeController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'الباركود ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Obx(() {
                try {
                  return BarcodeWidget(
                    barcode: controller.selectedBarcodeType.value,
                    data: controller.barcodeValue.value,
                    width: 250,
                    height: 100,
                    drawText: true,
                    style: const TextStyle(fontSize: 14),
                    errorBuilder: (context, error) => Center(
                      child: Text(
                        'خطأ في إنشاء الباركود',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  );
                } catch (e) {
                  return Center(
                    child: Text(
                      'خطأ في عرض الباركود',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }
              }),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.printBarcode,
                  icon: const Icon(Icons.print),
                  label: const Text('طباعة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.saveBarcode,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.cancelBarcodeDisplay,
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

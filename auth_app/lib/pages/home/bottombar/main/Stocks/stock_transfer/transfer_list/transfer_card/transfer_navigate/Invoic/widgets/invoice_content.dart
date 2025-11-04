import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_helpers.dart';
import 'package:flutter/material.dart';
import 'invoice_header.dart';
import 'info_cards.dart';

class InvoiceContent extends StatelessWidget {
  final TransferHeader header;

  const InvoiceContent({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InvoiceHeader(header: header),
          const SizedBox(height: 30),
          _buildTransferInfo(),
          const SizedBox(height: 20),
          _buildDocumentDateCard(),
          const SizedBox(height: 30),
          _buildDriverInfo(),
          const SizedBox(height: 30),
          _buildReceiptAndCarInfo(),
          const SizedBox(height: 30),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildTransferInfo() {
    return Row(
      children: [
        Expanded(child: _buildFromWarehouseCard()),
        const SizedBox(width: 15),
        _buildTransferArrow(),
        const SizedBox(width: 15),
        Expanded(child: _buildToWarehouseCard()),
      ],
    );
  }

  Widget _buildFromWarehouseCard() {
    return InfoCard(
      title: 'من المخزن',
      content: header.whsNameFrom.trim(),
      icon: Icons.outbox,
      color: Colors.orange,
    );
  }

  Widget _buildToWarehouseCard() {
    return InfoCard(
      title: 'إلى المخزن',
      content: header.whsNameTo.trim(),
      icon: Icons.inbox,
      color: Colors.green,
    );
  }

  Widget _buildTransferArrow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.arrow_forward, color: Colors.blue[600], size: 20),
    );
  }

  Widget _buildDocumentDateCard() {
    return InfoCard(
      title: 'تاريخ المستند',
      content: InvoiceHelpers.formatDate(header.createDate),
      icon: Icons.calendar_today,
      color: Colors.blue,
      fullWidth: true,
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        Expanded(child: _buildDriverNameField()),
        const SizedBox(width: 20),
        Expanded(child: _buildDriverPhoneField()),
      ],
    );
  }

  Widget _buildDriverNameField() {
    return _buildLabeledField(
      label: 'اسم السائق',
      initialValue: header.driverName?.trim() ?? '',
    );
  }

  Widget _buildDriverPhoneField() {
    return _buildLabeledField(
      label: 'رقم السائق',
      initialValue: header.driverMobil?.trim() ?? '',
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildReceiptAndCarInfo() {
    return Row(
      children: [
        Expanded(child: _buildReceiptNumber()),
        const SizedBox(width: 20),
        Expanded(child: _buildCarNumberField()),
      ],
    );
  }

  Widget _buildReceiptNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('رقم الاستلام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(header.ref ?? '25105', style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCarNumberField() {
    return _buildLabeledField(
      label: 'رقم السيارة',
      initialValue: header.careNum?.trim() ?? '',
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ملاحظات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 5,
          minLines: 5,
          decoration: InputDecoration(
            hintText: 'أدخل الملاحظات هنا...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
      {required String label, required String initialValue, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.all(12),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferDetailsBottomSheet extends StatelessWidget {
  final TransferModel transfer;

  const TransferDetailsBottomSheet({
    super.key,
    required this.transfer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandleBar(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildBasicInfo(),
            const Divider(height: 30),
            _buildWarehouseInfo(),
            const Divider(height: 30),
            _buildStatusInfo(),
            _buildNotesSection(),
            const SizedBox(height: 30),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'تفاصيل التحويل',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildDetailRow('رقم المرجع', transfer.ref ?? 'غير محدد'),
        _buildDetailRow('رقم التحويل', transfer.id.toString()),
        _buildDetailRow('تاريخ الإنشاء', transfer.formattedCreateDate),
        _buildDetailRow('المنشئ', transfer.creatby.trim()),
      ],
    );
  }

  Widget _buildWarehouseInfo() {
    return Column(
      children: [
        _buildDetailRow('من المستودع', transfer.whsNameFrom.trim()),
        _buildDetailRow('رمز المستودع المرسل', transfer.whscodeFrom.trim()),
        _buildDetailRow('إلى المستودع', transfer.whsNameTo.trim()),
        _buildDetailRow('رمز المستودع المستقبل', transfer.whscodeTo.trim()),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      children: [
        _buildDetailRow('حالة الإرسال', transfer.isSended ? 'تم الإرسال' : 'لم يتم الإرسال'),
        if (transfer.sendedBy != null) _buildDetailRow('المرسل بواسطة', transfer.sendedBy!.trim()),
        _buildDetailRow('حالة الاستلام', transfer.aproveRecive ? 'تم الاستلام' : 'لم يتم الاستلام'),
        if (transfer.aproveReciveBy != null)
          _buildDetailRow('المستلم بواسطة', transfer.aproveReciveBy!.trim()),
        _buildDetailRow('حالة الترحيل', transfer.sapPost ? 'تم الترحيل' : 'لم يتم الترحيل'),
        if (transfer.sapPostBy != null)
          _buildDetailRow('المرحل بواسطة', transfer.sapPostBy!.trim()),
        if (transfer.sapPostDate != null)
          _buildDetailRow('تاريخ الترحيل', transfer.formattedSapPostDate),
      ],
    );
  }

  Widget _buildNotesSection() {
    if (transfer.note != null && transfer.note!.isNotEmpty) {
      return Column(
        children: [
          const Divider(height: 30),
          _buildDetailRow('ملاحظات', transfer.note!),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'إغلاق',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

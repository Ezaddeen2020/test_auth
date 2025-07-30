import 'package:intl/intl.dart';

class TransferModel {
  final int id;
  final String whscodeFrom;
  final String whsNameFrom;
  final String whscodeTo;
  final String whsNameTo;
  final String creatby;
  final bool isSended;
  final String? sendedBy;
  final bool aproveRecive;
  final String? aproveReciveBy;
  final bool sapPost;
  final String? sapPostBy;
  final String? sapPostDate;
  final String createDate;
  final String? driverName;
  final String? driverCode;
  final String? driverMobil;
  final String? careNum;
  final String? note;
  final String? ref;

  TransferModel({
    required this.id,
    required this.whscodeFrom,
    required this.whsNameFrom,
    required this.whscodeTo,
    required this.whsNameTo,
    required this.creatby,
    required this.isSended,
    this.sendedBy,
    required this.aproveRecive,
    this.aproveReciveBy,
    required this.sapPost,
    this.sapPostBy,
    this.sapPostDate,
    required this.createDate,
    this.driverName,
    this.driverCode,
    this.driverMobil,
    this.careNum,
    this.note,
    this.ref,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] ?? 0,
      whscodeFrom: (json['whscodeFrom'] ?? '').toString().trim(),
      whsNameFrom: (json['whsNameFrom'] ?? '').toString().trim(),
      whscodeTo: (json['whscodeTo'] ?? '').toString().trim(),
      whsNameTo: (json['whsNameTo'] ?? '').toString().trim(),
      creatby: (json['creatby'] ?? '').toString().trim(),
      isSended: json['isSended'] ?? false,
      sendedBy: json['sendedBy']?.toString().trim(),
      aproveRecive: json['aproveRecive'] ?? false,
      aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
      sapPost: json['sapPost'] ?? false,
      sapPostBy: json['sapPostBy']?.toString().trim(),
      sapPostDate: json['sapPostDate']?.toString(),
      createDate: json['createDate'] ?? '',
      driverName: json['driverName']?.toString().trim(),
      driverCode: json['driverCode']?.toString().trim(),
      driverMobil: json['driverMobil']?.toString().trim(),
      careNum: json['careNum']?.toString().trim(),
      note: json['note']?.toString().trim(),
      ref: json['ref']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'whscodeFrom': whscodeFrom,
      'whsNameFrom': whsNameFrom,
      'whscodeTo': whscodeTo,
      'whsNameTo': whsNameTo,
      'creatby': creatby,
      'isSended': isSended,
      'sendedBy': sendedBy,
      'aproveRecive': aproveRecive,
      'aproveReciveBy': aproveReciveBy,
      'sapPost': sapPost,
      'sapPostBy': sapPostBy,
      'sapPostDate': sapPostDate,
      'createDate': createDate,
      'driverName': driverName,
      'driverCode': driverCode,
      'driverMobil': driverMobil,
      'careNum': careNum,
      'note': note,
      'ref': ref,
    };
  }

  // Helper methods للحصول على حالة التحويل
  String get statusText {
    if (sapPost) return 'مُرحّل إلى SAP';
    if (aproveRecive) return 'تم الاستلام';
    if (isSended) return 'تم الإرسال';
    return 'قيد التحضير';
  }

  // لون الحالة للواجهة
  String get statusColor {
    if (sapPost) return '#4CAF50'; // أخضر
    if (aproveRecive) return '#2196F3'; // أزرق
    if (isSended) return '#FF9800'; // برتقالي
    return '#9E9E9E'; // رمادي
  }

  // دالة مساعدة لتحويل التاريخ إلى نظام 12 ساعة
  String _formatDateTo12Hour(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';

    try {
      DateTime? dateTime;

      // محاولة تحليل التاريخ بصيغ مختلفة
      try {
        dateTime = DateTime.parse(dateString);
      } catch (e) {
        try {
          dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        } catch (e2) {
          try {
            dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
          } catch (e3) {
            return dateString; // إرجاع النص الأصلي إذا فشل التحليل
          }
        }
      }

      // تنسيق التاريخ بنظام 12 ساعة
      final formatter = DateFormat('dd/MM/yyyy hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString; // إرجاع النص الأصلي في حالة الخطأ
    }
  }

  // تحويل التاريخ لصيغة أفضل بنظام 12 ساعة
  String get formattedCreateDate {
    return _formatDateTo12Hour(createDate);
  }

  // تحويل تاريخ الترحيل بنظام 12 ساعة
  String get formattedSapPostDate {
    return _formatDateTo12Hour(sapPostDate);
  }

  @override
  String toString() {
    return 'TransferModel(id: $id, ref: $ref, from: $whsNameFrom, to: $whsNameTo, status: $statusText)';
  }
}

class TransferResponse {
  final int currentPage;
  final int totalPages;
  final List<TransferModel> data;

  TransferResponse({
    required this.currentPage,
    required this.totalPages,
    required this.data,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)?.map((item) => TransferModel.fromJson(item)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'data': data.map((transfer) => transfer.toJson()).toList(),
    };
  }
}

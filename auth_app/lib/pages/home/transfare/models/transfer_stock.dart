// class TransferModel {
//   final int id;
//   final String whscodeFrom;
//   final String whsNameFrom;
//   final String whscodeTo;
//   final String whsNameTo;
//   final String creatby;
//   final bool isSended;
//   final String? sendedBy;
//   final bool aproveRecive;
//   final String? aproveReciveBy;
//   final bool sapPost;
//   final String? sapPostBy;
//   final String? sapPostDate;
//   final String createDate;
//   final String? driverName;
//   final String? driverCode;
//   final String? driverMobil;
//   final String? careNum;
//   final String? note;
//   final String? ref;

//   TransferModel({
//     required this.id,
//     required this.whscodeFrom,
//     required this.whsNameFrom,
//     required this.whscodeTo,
//     required this.whsNameTo,
//     required this.creatby,
//     required this.isSended,
//     this.sendedBy,
//     required this.aproveRecive,
//     this.aproveReciveBy,
//     required this.sapPost,
//     this.sapPostBy,
//     this.sapPostDate,
//     required this.createDate,
//     this.driverName,
//     this.driverCode,
//     this.driverMobil,
//     this.careNum,
//     this.note,
//     this.ref,
//   });

//   factory TransferModel.fromJson(Map<String, dynamic> json) {
//     return TransferModel(
//       id: json['id'] ?? 0,
//       whscodeFrom: (json['whscodeFrom'] ?? '').toString().trim(),
//       whsNameFrom: (json['whsNameFrom'] ?? '').toString().trim(),
//       whscodeTo: (json['whscodeTo'] ?? '').toString().trim(),
//       whsNameTo: (json['whsNameTo'] ?? '').toString().trim(),
//       creatby: (json['creatby'] ?? '').toString().trim(),
//       isSended: json['isSended'] ?? false,
//       sendedBy: json['sendedBy']?.toString().trim(),
//       aproveRecive: json['aproveRecive'] ?? false,
//       aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
//       sapPost: json['sapPost'] ?? false,
//       sapPostBy: json['sapPostBy']?.toString().trim(),
//       sapPostDate: json['sapPostDate']?.toString(),
//       createDate: json['createDate'] ?? '',
//       driverName: json['driverName']?.toString().trim(),
//       driverCode: json['driverCode']?.toString().trim(),
//       driverMobil: json['driverMobil']?.toString().trim(),
//       careNum: json['careNum']?.toString().trim(),
//       note: json['note']?.toString().trim(),
//       ref: json['ref']?.toString().trim(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'whscodeFrom': whscodeFrom,
//       'whsNameFrom': whsNameFrom,
//       'whscodeTo': whscodeTo,
//       'whsNameTo': whsNameTo,
//       'creatby': creatby,
//       'isSended': isSended,
//       'sendedBy': sendedBy,
//       'aproveRecive': aproveRecive,
//       'aproveReciveBy': aproveReciveBy,
//       'sapPost': sapPost,
//       'sapPostBy': sapPostBy,
//       'sapPostDate': sapPostDate,
//       'createDate': createDate,
//       'driverName': driverName,
//       'driverCode': driverCode,
//       'driverMobil': driverMobil,
//       'careNum': careNum,
//       'note': note,
//       'ref': ref,
//     };
//   }

//   // Helper methods للحصول على حالة التحويل
//   String get statusText {
//     if (sapPost) return 'SAP مُرحّل إلى ';
//     if (aproveRecive) return 'تم الاستلام';
//     if (isSended) return 'تم الإرسال';
//     return 'قيد التحضير';
//   }

//   // لون الحالة للواجهة
//   String get statusColor {
//     if (sapPost) return '#4CAF50'; // أخضر
//     if (aproveRecive) return '#2196F3'; // أزرق
//     if (isSended) return '#FF9800'; // برتقالي
//     return '#9E9E9E'; // رمادي
//   }

//   // تحويل التاريخ لصيغة أفضل
//   String get formattedCreateDate {
//     try {
//       DateTime dateTime = DateTime.parse(createDate);
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return createDate;
//     }
//   }

//   @override
//   String toString() {
//     return 'TransferModel(id: $id, ref: $ref, from: $whsNameFrom, to: $whsNameTo, status: $statusText)';
//   }
// }

// class TransferResponse {
//   final int currentPage;
//   final int totalPages;
//   final List<TransferModel> data;

//   TransferResponse({
//     required this.currentPage,
//     required this.totalPages,
//     required this.data,
//   });

//   factory TransferResponse.fromJson(Map<String, dynamic> json) {
//     return TransferResponse(
//       currentPage: json['currentPage'] ?? 1,
//       totalPages: json['totalPages'] ?? 1,
//       data:
//           (json['data'] as List<dynamic>?)?.map((item) => TransferModel.fromJson(item)).toList() ??
//               [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'currentPage': currentPage,
//       'totalPages': totalPages,
//       'data': data.map((transfer) => transfer.toJson()).toList(),
//     };
//   }
// }

// import 'package:intl/intl.dart';

// class TransferModel {
//   final int id;
//   final String whscodeFrom;
//   final String whsNameFrom;
//   final String whscodeTo;
//   final String whsNameTo;
//   final String creatby;
//   final bool isSended;
//   final String? sendedBy;
//   final bool aproveRecive;
//   final String? aproveReciveBy;
//   final bool sapPost;
//   final String? sapPostBy;
//   final String? sapPostDate;
//   final String createDate;
//   final String? driverName;
//   final String? driverCode;
//   final String? driverMobil;
//   final String? careNum;
//   final String? note;
//   final String? ref;

//   TransferModel({
//     required this.id,
//     required this.whscodeFrom,
//     required this.whsNameFrom,
//     required this.whscodeTo,
//     required this.whsNameTo,
//     required this.creatby,
//     required this.isSended,
//     this.sendedBy,
//     required this.aproveRecive,
//     this.aproveReciveBy,
//     required this.sapPost,
//     this.sapPostBy,
//     this.sapPostDate,
//     required this.createDate,
//     this.driverName,
//     this.driverCode,
//     this.driverMobil,
//     this.careNum,
//     this.note,
//     this.ref,
//   });

//   factory TransferModel.fromJson(Map<String, dynamic> json) {
//     return TransferModel(
//       id: json['id'] ?? 0,
//       whscodeFrom: (json['whscodeFrom'] ?? '').toString().trim(),
//       whsNameFrom: (json['whsNameFrom'] ?? '').toString().trim(),
//       whscodeTo: (json['whscodeTo'] ?? '').toString().trim(),
//       whsNameTo: (json['whsNameTo'] ?? '').toString().trim(),
//       creatby: (json['creatby'] ?? '').toString().trim(),
//       isSended: json['isSended'] ?? false,
//       sendedBy: json['sendedBy']?.toString().trim(),
//       aproveRecive: json['aproveRecive'] ?? false,
//       aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
//       sapPost: json['sapPost'] ?? false,
//       sapPostBy: json['sapPostBy']?.toString().trim(),
//       sapPostDate: json['sapPostDate']?.toString(),
//       createDate: json['createDate'] ?? '',
//       driverName: json['driverName']?.toString().trim(),
//       driverCode: json['driverCode']?.toString().trim(),
//       driverMobil: json['driverMobil']?.toString().trim(),
//       careNum: json['careNum']?.toString().trim(),
//       note: json['note']?.toString().trim(),
//       ref: json['ref']?.toString().trim(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'whscodeFrom': whscodeFrom,
//       'whsNameFrom': whsNameFrom,
//       'whscodeTo': whscodeTo,
//       'whsNameTo': whsNameTo,
//       'creatby': creatby,
//       'isSended': isSended,
//       'sendedBy': sendedBy,
//       'aproveRecive': aproveRecive,
//       'aproveReciveBy': aproveReciveBy,
//       'sapPost': sapPost,
//       'sapPostBy': sapPostBy,
//       'sapPostDate': sapPostDate,
//       'createDate': createDate,
//       'driverName': driverName,
//       'driverCode': driverCode,
//       'driverMobil': driverMobil,
//       'careNum': careNum,
//       'note': note,
//       'ref': ref,
//     };
//   }

//   // Helper methods للحصول على حالة التحويل
//   String get statusText {
//     if (sapPost) return 'مُرحّل إلى SAP';
//     if (aproveRecive) return 'تم الاستلام';
//     if (isSended) return 'تم الإرسال';
//     return 'قيد التحضير';
//   }

//   // لون الحالة للواجهة
//   String get statusColor {
//     if (sapPost) return '#4CAF50'; // أخضر
//     if (aproveRecive) return '#2196F3'; // أزرق
//     if (isSended) return '#FF9800'; // برتقالي
//     return '#9E9E9E'; // رمادي
//   }

//   // دالة مساعدة لتحويل التاريخ إلى نظام 12 ساعة
//   String _formatDateTo12Hour(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'غير محدد';

//     try {
//       DateTime? dateTime;

//       // محاولة تحليل التاريخ بصيغ مختلفة
//       try {
//         dateTime = DateTime.parse(dateString);
//       } catch (e) {
//         try {
//           dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
//         } catch (e2) {
//           try {
//             dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
//           } catch (e3) {
//             return dateString; // إرجاع النص الأصلي إذا فشل التحليل
//           }
//         }
//       }

//       // تنسيق التاريخ بنظام 12 ساعة
//       final formatter = DateFormat('dd/MM/yyyy hh:mm a');
//       return formatter.format(dateTime);
//     } catch (e) {
//       return dateString; // إرجاع النص الأصلي في حالة الخطأ
//     }
//   }

//   // تحويل التاريخ لصيغة أفضل بنظام 12 ساعة
//   String get formattedCreateDate {
//     return _formatDateTo12Hour(createDate);
//   }

//   // تحويل تاريخ الترحيل بنظام 12 ساعة
//   String get formattedSapPostDate {
//     return _formatDateTo12Hour(sapPostDate);
//   }

//   @override
//   String toString() {
//     return 'TransferModel(id: $id, ref: $ref, from: $whsNameFrom, to: $whsNameTo, status: $statusText)';
//   }
// }

// class TransferResponse {
//   final int currentPage;
//   final int totalPages;
//   final List<TransferModel> data;

//   TransferResponse({
//     required this.currentPage,
//     required this.totalPages,
//     required this.data,
//   });

//   factory TransferResponse.fromJson(Map<String, dynamic> json) {
//     return TransferResponse(
//       currentPage: json['currentPage'] ?? 1,
//       totalPages: json['totalPages'] ?? 1,
//       data:
//           (json['data'] as List<dynamic>?)?.map((item) => TransferModel.fromJson(item)).toList() ??
//               [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'currentPage': currentPage,
//       'totalPages': totalPages,
//       'data': data.map((transfer) => transfer.toJson()).toList(),
//     };
//   }
// }

// في ملف details_model.dart

// class TransferDetailDto {
//   final TransferHeaderDto header;
//   final List<TransferLine> lines;

//   TransferDetailDto({
//     required this.header,
//     required this.lines,
//   });

//   factory TransferDetailDto.fromJson(Map<String, dynamic> json) {
//     return TransferDetailDto(
//       header: TransferHeaderDto.fromJson(json['header'] ?? {}),
//       lines: (json['lines'] as List<dynamic>?)
//           ?.map((line) => TransferLine.fromJson(line))
//           .toList() ?? [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'header': header.toJson(),
//       'lines': lines.map((line) => line.toJson()).toList(),
//     };
//   }
// }

// class TransferHeaderDto {
//   final int id;
//   final String whscodeFrom;
//   final String whsNameFrom;
//   final String whscodeTo;
//   final String whsNameTo;
//   final String creatby;
//   final bool isSended;
//   final String? sendedBy;
//   final bool aproveRecive;
//   final String? aproveReciveBy;
//   final bool sapPost;
//   final String? sapPostBy;
//   final String? sapPostDate;
//   final String createDate;
//   final String? driverName;
//   final String? driverCode;
//   final String? driverMobil;
//   final String? careNum;
//   final String? note;
//   final String? ref;

//   TransferHeaderDto({
//     required this.id,
//     required this.whscodeFrom,
//     required this.whsNameFrom,
//     required this.whscodeTo,
//     required this.whsNameTo,
//     required this.creatby,
//     required this.isSended,
//     this.sendedBy,
//     required this.aproveRecive,
//     this.aproveReciveBy,
//     required this.sapPost,
//     this.sapPostBy,
//     this.sapPostDate,
//     required this.createDate,
//     this.driverName,
//     this.driverCode,
//     this.driverMobil,
//     this.careNum,
//     this.note,
//     this.ref,
//   });

//   factory TransferHeaderDto.fromJson(Map<String, dynamic> json) {
//     return TransferHeaderDto(
//       id: json['id'] ?? 0,
//       whscodeFrom: (json['whscodeFrom'] ?? '').toString().trim(),
//       whsNameFrom: (json['whsNameFrom'] ?? '').toString().trim(),
//       whscodeTo: (json['whscodeTo'] ?? '').toString().trim(),
//       whsNameTo: (json['whsNameTo'] ?? '').toString().trim(),
//       creatby: (json['creatby'] ?? '').toString().trim(),
//       isSended: json['isSended'] ?? false,
//       sendedBy: json['sendedBy']?.toString().trim(),
//       aproveRecive: json['aproveRecive'] ?? false,
//       aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
//       sapPost: json['sapPost'] ?? false,
//       sapPostBy: json['sapPostBy']?.toString().trim(),
//       sapPostDate: json['sapPostDate']?.toString(),
//       createDate: json['createDate'] ?? '',
//       driverName: json['driverName']?.toString().trim(),
//       driverCode: json['driverCode']?.toString().trim(),
//       driverMobil: json['driverMobil']?.toString().trim(),
//       careNum: json['careNum']?.toString().trim(),
//       note: json['note']?.toString().trim(),
//       ref: json['ref']?.toString().trim(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'whscodeFrom': whscodeFrom,
//       'whsNameFrom': whsNameFrom,
//       'whscodeTo': whscodeTo,
//       'whsNameTo': whsNameTo,
//       'creatby': creatby,
//       'isSended': isSended,
//       'sendedBy': sendedBy,
//       'aproveRecive': aproveRecive,
//       'aproveReciveBy': aproveReciveBy,
//       'sapPost': sapPost,
//       'sapPostBy': sapPostBy,
//       'sapPostDate': sapPostDate,
//       'createDate': createDate,
//       'driverName': driverName,
//       'driverCode': driverCode,
//       'driverMobil': driverMobil,
//       'careNum': careNum,
//       'note': note,
//       'ref': ref,
//     };
//   }
// }

// class TransferLine {
//   final int? docEntry;
//   final int? lineNum;
//   final String? itemCode;
//   final String? description;
//   final double? quantity;
//   final double? price;
//   final double? lineTotal;
//   final String? uomCode;
//   final String? uomCode2;
//   final double? invQty;
//   final int? baseQty1;
//   final int? ugpEntry;
//   final int? uomEntry;

//   TransferLine({
//     this.docEntry,
//     this.lineNum,
//     this.itemCode,
//     this.description,
//     this.quantity,
//     this.price,
//     this.lineTotal,
//     this.uomCode,
//     this.uomCode2,
//     this.invQty,
//     this.baseQty1,
//     this.ugpEntry,
//     this.uomEntry,
//   });

//   factory TransferLine.fromJson(Map<String, dynamic> json) {
//     return TransferLine(
//       docEntry: json['docEntry'] as int?,
//       lineNum: json['lineNum'] as int?,
//       itemCode: json['itemCode']?.toString(),
//       description: json['dscription']?.toString(), // لاحظ الإملاء الخاطئ في API
//       quantity: (json['quantity'] as num?)?.toDouble(),
//       price: (json['price'] as num?)?.toDouble(),
//       lineTotal: (json['lineTotal'] as num?)?.toDouble(),
//       uomCode: json['uomCode']?.toString(),
//       uomCode2: json['uomCode2']?.toString(),
//       invQty: (json['invQty'] as num?)?.toDouble(),
//       baseQty1: json['baseQty1'] as int?,
//       ugpEntry: json['ugpEntry'] as int?,
//       uomEntry: json['uomEntry'] as int?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'docEntry': docEntry,
//       'lineNum': lineNum,
//       'itemCode': itemCode,
//       'dscription': description, // استخدام نفس الإملاء الخاطئ للتوافق مع API
//       'quantity': quantity,
//       'price': price,
//       'lineTotal': lineTotal,
//       'uomCode': uomCode,
//       'uomCode2': uomCode2,
//       'invQty': invQty,
//       'baseQty1': baseQty1,
//       'ugpEntry': ugpEntry,
//       'uomEntry': uomEntry,
//     };
//   }

//   @override
//   String toString() {
//     return 'TransferLine(itemCode: $itemCode, description: $description, quantity: $quantity)';
//   }
// }

// ملف: transfer_stock.dart
// هذا هو الملف الأساسي للنماذج - احتفظ بـ TransferModel كما هو واضف الكلاسات الجديدة

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

// class TransferModel {
//   final int id;
//   final String whscodeFrom;
//   final String whsNameFrom;
//   final String whscodeTo;
//   final String whsNameTo;
//   final String creatby;
//   final bool isSended;
//   final String? sendedBy;
//   final bool aproveRecive;
//   final String? aproveReciveBy;
//   final bool sapPost;
//   final String? sapPostBy;
//   final String? sapPostDate;
//   final String createDate;
//   final String? driverName;
//   final String? driverCode;
//   final String? driverMobil;
//   final String? careNum;
//   final String? note;
//   final String? ref;

//   TransferModel({
//     required this.id,
//     required this.whscodeFrom,
//     required this.whsNameFrom,
//     required this.whscodeTo,
//     required this.whsNameTo,
//     required this.creatby,
//     required this.isSended,
//     this.sendedBy,
//     required this.aproveRecive,
//     this.aproveReciveBy,
//     required this.sapPost,
//     this.sapPostBy,
//     this.sapPostDate,
//     required this.createDate,
//     this.driverName,
//     this.driverCode,
//     this.driverMobil,
//     this.careNum,
//     this.note,
//     this.ref,
//   });

//   factory TransferModel.fromJson(Map<String, dynamic> json) {
//     return TransferModel(
//       id: json['id'] ?? 0,
//       whscodeFrom: json['whscodeFrom']?.toString().trim() ?? '',
//       whsNameFrom: json['whsNameFrom']?.toString().trim() ?? '',
//       whscodeTo: json['whscodeTo']?.toString().trim() ?? '',
//       whsNameTo: json['whsNameTo']?.toString().trim() ?? '',
//       creatby: json['creatby']?.toString().trim() ?? '',
//       isSended: json['isSended'] ?? false,
//       sendedBy: json['sendedBy']?.toString().trim(),
//       aproveRecive: json['aproveRecive'] ?? false,
//       aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
//       sapPost: json['sapPost'] ?? false,
//       sapPostBy: json['sapPostBy']?.toString().trim(),
//       sapPostDate: json['sapPostDate']?.toString(),
//       createDate: json['createDate']?.toString() ?? '',
//       driverName: json['driverName']?.toString().trim(),
//       driverCode: json['driverCode']?.toString().trim(),
//       driverMobil: json['driverMobil']?.toString().trim(),
//       careNum: json['careNum']?.toString().trim(),
//       note: json['note']?.toString().trim(),
//       ref: json['ref']?.toString().trim(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'whscodeFrom': whscodeFrom,
//       'whsNameFrom': whsNameFrom,
//       'whscodeTo': whscodeTo,
//       'whsNameTo': whsNameTo,
//       'creatby': creatby,
//       'isSended': isSended,
//       'sendedBy': sendedBy,
//       'aproveRecive': aproveRecive,
//       'aproveReciveBy': aproveReciveBy,
//       'sapPost': sapPost,
//       'sapPostBy': sapPostBy,
//       'sapPostDate': sapPostDate,
//       'createDate': createDate,
//       'driverName': driverName,
//       'driverCode': driverCode,
//       'driverMobil': driverMobil,
//       'careNum': careNum,
//       'note': note,
//       'ref': ref,
//     };
//   }

//   // Helper methods للحصول على حالة النقل
//   String get transferStatus {
//     if (sapPost) return 'مرحل إلى SAP';
//     if (aproveRecive) return 'تم الاستلام والموافقة';
//     if (isSended) return 'تم الإرسال';
//     return 'قيد الإنشاء';
//   }

//   // للحصول على لون الحالة
//   String get statusColor {
//     if (sapPost) return 'green';
//     if (aproveRecive) return 'blue';
//     if (isSended) return 'orange';
//     return 'red';
//   }

//   // تنسيق التاريخ
//   String get formattedCreateDate {
//     try {
//       DateTime date = DateTime.parse(createDate);
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
//           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return createDate;
//     }
//   }

//   // للتحقق من إمكانية التعديل
//   bool get canEdit {
//     return !sapPost; // يمكن التعديل فقط إذا لم يتم ترحيله إلى SAP
//   }

//   // للحصول على اسم المستودع المختصر
//   String get shortFromWarehouseName {
//     if (whsNameFrom.contains('الصالحية')) return 'مستودع الصالحية';
//     if (whsNameFrom.contains('البوادي')) return 'مستودع البوادي';
//     if (whsNameFrom.contains('General')) return 'المستودع العام';
//     return whsNameFrom.length > 20 ? whsNameFrom.substring(0, 20) + '...' : whsNameFrom;
//   }

//   String get shortToWarehouseName {
//     if (whsNameTo.contains('الصالحية')) return 'مستودع الصالحية';
//     if (whsNameTo.contains('البوادي')) return 'مستودع البوادي';
//     if (whsNameTo.contains('General')) return 'المستودع العام';
//     return whsNameTo.length > 20 ? whsNameTo.substring(0, 20) + '...' : whsNameTo;
//   }
// }

// class TransferListResponse {
//   final int currentPage;
//   final int totalPages;
//   final List<TransferModel> data;

//   TransferListResponse({
//     required this.currentPage,
//     required this.totalPages,
//     required this.data,
//   });

//   factory TransferListResponse.fromJson(Map<String, dynamic> json) {
//     return TransferListResponse(
//       currentPage: json['currentPage'] ?? 1,
//       totalPages: json['totalPages'] ?? 1,
//       data: (json['data'] as List<dynamic>?)
//               ?.map((item) => TransferModel.fromJson(item))
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'currentPage': currentPage,
//       'totalPages': totalPages,
//       'data': data.map((item) => item.toJson()).toList(),
//     };
//   }
// }
// transfer_details_model.dart
import 'package:intl/intl.dart';

class TransferDetailDto {
  final TransferHeader header;
  final List<TransferLine> lines;

  TransferDetailDto({
    required this.header,
    required this.lines,
  });

  factory TransferDetailDto.fromJson(Map<String, dynamic> json) {
    return TransferDetailDto(
      header: TransferHeader.fromJson(json['header'] ?? {}),
      lines:
          (json['lines'] as List<dynamic>?)?.map((item) => TransferLine.fromJson(item)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }

  // حساب الإجماليات
  double get totalQuantity {
    return lines.fold(0.0, (sum, line) => sum + (line.quantity ?? 0.0));
  }

  double get totalAmount {
    return lines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
  }

  int get totalItems {
    return lines.length;
  }

  int get uniqueItemsCount {
    Set<String> uniqueItems =
        lines.map((line) => line.itemCode ?? '').where((code) => code.isNotEmpty).toSet();
    return uniqueItems.length;
  }
}

class TransferHeader {
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

  TransferHeader({
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

  factory TransferHeader.fromJson(Map<String, dynamic> json) {
    return TransferHeader(
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

  // Helper methods
  String get statusText {
    if (sapPost) return 'مُرحّل إلى SAP';
    if (aproveRecive) return 'تم الاستلام';
    if (isSended) return 'تم الإرسال';
    return 'قيد التحضير';
  }

  String _formatDateTo12Hour(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';

    try {
      DateTime? dateTime;
      try {
        dateTime = DateTime.parse(dateString);
      } catch (e) {
        try {
          dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        } catch (e2) {
          return dateString;
        }
      }

      final formatter = DateFormat('dd/MM/yyyy hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String get formattedCreateDate {
    return _formatDateTo12Hour(createDate);
  }

  String get formattedSapPostDate {
    return _formatDateTo12Hour(sapPostDate);
  }
}

class TransferLine {
  final int docEntry;
  final int lineNum;
  final String? itemCode;
  final String? description;
  final double? quantity;
  final double? price;
  final double? lineTotal;
  final String? uomCode;
  final String? uomCode2;
  final double? invQty;
  final int? baseQty1;
  final int? ugpEntry;
  final int? uomEntry;

  TransferLine({
    required this.docEntry,
    required this.lineNum,
    this.itemCode,
    this.description,
    this.quantity,
    this.price,
    this.lineTotal,
    this.uomCode,
    this.uomCode2,
    this.invQty,
    this.baseQty1,
    this.ugpEntry,
    this.uomEntry,
  });

  factory TransferLine.fromJson(Map<String, dynamic> json) {
    return TransferLine(
      docEntry: json['docEntry'] ?? 0,
      lineNum: json['lineNum'] ?? 0,
      itemCode: json['itemCode']?.toString().trim(),
      description: json['dscription']?.toString().trim(), // انتبه: API يستخدم 'dscription'
      quantity: _parseDouble(json['quantity']),
      price: _parseDouble(json['price']),
      lineTotal: _parseDouble(json['lineTotal']),
      uomCode: json['uomCode']?.toString().trim(),
      uomCode2: json['uomCode2']?.toString().trim(),
      invQty: _parseDouble(json['invQty']),
      baseQty1: _parseInt(json['baseQty1']),
      ugpEntry: _parseInt(json['ugpEntry']),
      uomEntry: _parseInt(json['uomEntry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docEntry': docEntry,
      'lineNum': lineNum,
      'itemCode': itemCode,
      'dscription': description,
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'uomCode': uomCode,
      'uomCode2': uomCode2,
      'invQty': invQty,
      'baseQty1': baseQty1,
      'ugpEntry': ugpEntry,
      'uomEntry': uomEntry,
    };
  }

  // Helper methods لتحويل القيم
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  // تنسيق العرض
  String get formattedQuantity {
    if (quantity == null) return '0';
    return NumberFormat('#,##0.###').format(quantity!);
  }

  String get formattedPrice {
    if (price == null) return '0.00';
    return NumberFormat('#,##0.00').format(price!);
  }

  String get formattedLineTotal {
    if (lineTotal == null) return '0.00';
    return NumberFormat('#,##0.00').format(lineTotal!);
  }

  String get formattedInvQty {
    if (invQty == null) return '0';
    return NumberFormat('#,##0.###').format(invQty!);
  }

  // معلومات إضافية للعرض
  String get displayName {
    return itemCode ?? 'غير محدد';
  }

  String get displayDescription {
    return description ?? 'بدون وصف';
  }

  String get displayUom {
    return uomCode ?? 'وحدة';
  }

  bool get hasStock {
    return (invQty ?? 0) > 0;
  }

  // حساب نسبة الكمية المطلوبة من المخزون
  double get stockRatio {
    if (invQty == null || invQty == 0 || quantity == null) return 0;
    return (quantity! / invQty!) * 100;
  }

  String get stockStatus {
    if (!hasStock) return 'غير متوفر';
    double ratio = stockRatio;
    if (ratio > 100) return 'كمية أكبر من المخزون';
    if (ratio > 80) return 'كمية عالية';
    if (ratio > 50) return 'كمية متوسطة';
    return 'كمية منخفضة';
  }

  @override
  String toString() {
    return 'TransferLine(itemCode: $itemCode, quantity: $quantity, price: $price)';
  }
}

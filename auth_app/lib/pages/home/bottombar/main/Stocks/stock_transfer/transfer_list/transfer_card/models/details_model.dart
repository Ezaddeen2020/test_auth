// // models/transfer_details_model.dart

// class TransferDetailDto {
//   final TransferHeader header;
//   final List<TransferLine> lines;

//   TransferDetailDto({
//     required this.header,
//     required this.lines,
//   });

//   factory TransferDetailDto.fromJson(Map<String, dynamic> json) {
//     return TransferDetailDto(
//       header: TransferHeader.fromJson(json['header'] ?? {}),
//       lines:
//           (json['lines'] as List<dynamic>?)?.map((item) => TransferLine.fromJson(item)).toList() ??
//               [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'header': header.toJson(),
//       'lines': lines.map((line) => line.toJson()).toList(),
//     };
//   }
// }

// class TransferHeader {
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

//   TransferHeader({
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

//   factory TransferHeader.fromJson(Map<String, dynamic> json) {
//     return TransferHeader(
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
//       docEntry: json['docEntry']?.toInt(),
//       lineNum: json['lineNum']?.toInt(),
//       itemCode: json['itemCode']?.toString().trim(),
//       description: json['dscription']?.toString().trim(), // تأكد من اسم الحقل في الـ JSON
//       quantity: json['quantity']?.toDouble(),
//       price: json['price']?.toDouble(),
//       lineTotal: json['lineTotal']?.toDouble(),
//       uomCode: json['uomCode']?.toString().trim(),
//       uomCode2: json['uomCode2']?.toString().trim(),
//       invQty: json['invQty']?.toDouble(),
//       baseQty1: json['baseQty1']?.toInt(),
//       ugpEntry: json['ugpEntry']?.toInt(),
//       uomEntry: json['uomEntry']?.toInt(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'docEntry': docEntry,
//       'lineNum': lineNum,
//       'itemCode': itemCode,
//       'dscription': description,
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

//   // Helper methods لحساب المبالغ والكميات
//   String get formattedQuantity {
//     if (quantity == null) return '0';
//     return quantity!.toStringAsFixed(3);
//   }

//   String get formattedPrice {
//     if (price == null) return '0.00';
//     return price!.toStringAsFixed(2);
//   }

//   String get formattedLineTotal {
//     if (lineTotal == null) return '0.00';
//     return lineTotal!.toStringAsFixed(2);
//   }

//   String get formattedInvQty {
//     if (invQty == null) return '0';
//     return invQty!.toStringAsFixed(3);
//   }
// }

// models/transfer_details_model.dart

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
}

class TransferLine {
  final int? docEntry;
  final int? lineNum;
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
    this.docEntry,
    this.lineNum,
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
      docEntry: json['docEntry']?.toInt(),
      lineNum: json['lineNum']?.toInt(),
      itemCode: json['itemCode']?.toString().trim(),
      // تصحيح: استخدام 'dscription' كما في الاستجابة
      description: json['dscription']?.toString().trim() ?? json['description']?.toString().trim(),
      quantity: _parseDouble(json['quantity']),
      price: _parseDouble(json['price']),
      lineTotal: _parseDouble(json['lineTotal']),
      uomCode: json['uomCode']?.toString().trim(),
      uomCode2: json['uomCode2']?.toString().trim(),
      invQty: _parseDouble(json['invQty']),
      baseQty1: json['baseQty1']?.toInt(),
      ugpEntry: json['ugpEntry']?.toInt(),
      uomEntry: json['uomEntry']?.toInt(),
    );
  }

  // دالة مساعدة لتحويل القيم إلى double بشكل آمن
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'docEntry': docEntry,
      'lineNum': lineNum,
      'itemCode': itemCode,
      'dscription': description, // استخدام 'dscription' كما يتوقعه الـ API
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

  // تحديث: toApiJson للإرسال إلى الـ API
  Map<String, dynamic> toApiJson({bool isNewLine = false}) {
    Map<String, dynamic> data = {
      'docEntry': docEntry,
      'itemCode': itemCode?.trim(),
      'dscription': description?.trim(),
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'uomCode': uomCode?.trim(),
    };

    // إضافة lineNum فقط إذا لم يكن سطر جديد
    if (!isNewLine && lineNum != null && lineNum! > 0) {
      data['lineNum'] = lineNum;
    }

    // إضافة الحقول الاختيارية فقط إذا كانت موجودة
    if (uomCode2 != null && uomCode2!.isNotEmpty) data['uomCode2'] = uomCode2?.trim();
    if (invQty != null) data['invQty'] = invQty;
    if (baseQty1 != null) data['baseQty1'] = baseQty1;
    if (ugpEntry != null) data['ugpEntry'] = ugpEntry;
    if (uomEntry != null) data['uomEntry'] = uomEntry;

    return data;
  }

  // Helper methods لحساب المبالغ والكميات
  String get formattedQuantity {
    if (quantity == null) return '0';
    return quantity!.toStringAsFixed(3);
  }

  String get formattedPrice {
    if (price == null) return '0.00';
    return price!.toStringAsFixed(2);
  }

  String get formattedLineTotal {
    if (lineTotal == null) return '0.00';
    return lineTotal!.toStringAsFixed(2);
  }

  String get formattedInvQty {
    if (invQty == null) return '0';
    return invQty!.toStringAsFixed(3);
  }

  // دالة للتحقق من صحة البيانات قبل الإرسال
  bool get isValid {
    return itemCode != null &&
        itemCode!.isNotEmpty &&
        quantity != null &&
        quantity! > 0 &&
        price != null &&
        price! >= 0;
  }

  // نسخ الكائن مع تعديلات
  TransferLine copyWith({
    int? docEntry,
    int? lineNum,
    String? itemCode,
    String? description,
    double? quantity,
    double? price,
    double? lineTotal,
    String? uomCode,
    String? uomCode2,
    double? invQty,
    int? baseQty1,
    int? ugpEntry,
    int? uomEntry,
  }) {
    return TransferLine(
      docEntry: docEntry ?? this.docEntry,
      lineNum: lineNum ?? this.lineNum,
      itemCode: itemCode ?? this.itemCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      lineTotal: lineTotal ?? this.lineTotal,
      uomCode: uomCode ?? this.uomCode,
      uomCode2: uomCode2 ?? this.uomCode2,
      invQty: invQty ?? this.invQty,
      baseQty1: baseQty1 ?? this.baseQty1,
      ugpEntry: ugpEntry ?? this.ugpEntry,
      uomEntry: uomEntry ?? this.uomEntry,
    );
  }

  // تحديث تلقائي لـ lineTotal عند تغيير الكمية أو السعر
  TransferLine updateCalculatedFields() {
    double calculatedTotal = (quantity ?? 0.0) * (price ?? 0.0);
    return copyWith(lineTotal: calculatedTotal);
  }

  @override
  String toString() {
    return 'TransferLine{docEntry: $docEntry, lineNum: $lineNum, itemCode: $itemCode, quantity: $quantity, price: $price, lineTotal: $lineTotal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransferLine &&
        other.docEntry == docEntry &&
        other.lineNum == lineNum &&
        other.itemCode == itemCode;
  }

  @override
  int get hashCode {
    return docEntry.hashCode ^ lineNum.hashCode ^ itemCode.hashCode;
  }
}



// // إنشاء نماذج البيانات الجديدة لتتوافق مع الباك إند

// class TransferDetailDto {
//   final TransferHeader header;
//   final List<TransferLine> lines;

//   TransferDetailDto({
//     required this.header,
//     required this.lines,
//   });

//   factory TransferDetailDto.fromJson(Map<String, dynamic> json) {
//     return TransferDetailDto(
//       header: TransferHeader.fromJson(json['header']),
//       lines: (json['lines'] as List).map((line) => TransferLine.fromJson(line)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'header': header.toJson(),
//       'lines': lines.map((line) => line.toJson()).toList(),
//     };
//   }
// }

// class TransferHeader {
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

//   TransferHeader({
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

//   factory TransferHeader.fromJson(Map<String, dynamic> json) {
//     return TransferHeader(
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

//   // حساب الإجمالي من كافة الأسطر
//   double getTotalAmount(List<TransferLine> lines) {
//     return lines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
//   }

//   // حساب إجمالي الكمية
//   double getTotalQuantity(List<TransferLine> lines) {
//     return lines.fold(0.0, (sum, line) => sum + (line.quantity ?? 0.0));
//   }

//   // التحقق من حالة التحويل
//   String get statusText {
//     if (sapPost) return 'مُرحّل إلى SAP';
//     if (aproveRecive) return 'تم الاستلام';
//     if (isSended) return 'تم الإرسال';
//     return 'قيد التحضير';
//   }
// }

// class TransferLine {
//   final int docEntry;
//   final int lineNum;
//   final String? itemCode;
//   final String? description;
//   final double? quantity;
//   final double? price;
//   final double? lineTotal;
//   final String? uomCode;
//   final String? uomCode2;
//   final double? invQty;
//   final int baseQty1;
//   final int ugpEntry;
//   final int uomEntry;

//   TransferLine({
//     required this.docEntry,
//     required this.lineNum,
//     this.itemCode,
//     this.description,
//     this.quantity,
//     this.price,
//     this.lineTotal,
//     this.uomCode,
//     this.uomCode2,
//     this.invQty,
//     required this.baseQty1,
//     required this.ugpEntry,
//     required this.uomEntry,
//   });

//   factory TransferLine.fromJson(Map<String, dynamic> json) {
//     return TransferLine(
//       docEntry: json['docEntry'] ?? 0,
//       lineNum: json['lineNum'] ?? 0,
//       itemCode: json['itemCode']?.toString(),
//       description: json['dscription']?.toString(), // ملاحظة: dscription في JSON
//       quantity: _parseDouble(json['quantity']),
//       price: _parseDouble(json['price']),
//       lineTotal: _parseDouble(json['lineTotal']),
//       uomCode: json['uomCode']?.toString(),
//       uomCode2: json['uomCode2']?.toString(),
//       invQty: _parseDouble(json['invQty']),
//       baseQty1: json['baseQty1'] ?? 0,
//       ugpEntry: json['ugpEntry'] ?? 0,
//       uomEntry: json['uomEntry'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'docEntry': docEntry,
//       'lineNum': lineNum,
//       'itemCode': itemCode,
//       'dscription': description,
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

//   // دالة مساعدة لتحويل القيم إلى double
//   static double? _parseDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }

//   // حساب النسبة المئوية للصنف من الإجمالي
//   double getPercentageOfTotal(double totalAmount) {
//     if (totalAmount == 0 || lineTotal == null) return 0;
//     return (lineTotal! / totalAmount) * 100;
//   }
// }

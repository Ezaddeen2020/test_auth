// إنشاء نماذج البيانات الجديدة لتتوافق مع الباك إند

class TransferDetailDto {
  final TransferHeader header;
  final List<TransferLine> lines;

  TransferDetailDto({
    required this.header,
    required this.lines,
  });

  factory TransferDetailDto.fromJson(Map<String, dynamic> json) {
    return TransferDetailDto(
      header: TransferHeader.fromJson(json['header']),
      lines: (json['lines'] as List).map((line) => TransferLine.fromJson(line)).toList(),
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
      whscodeFrom: json['whscodeFrom']?.toString().trim() ?? '',
      whsNameFrom: json['whsNameFrom']?.toString().trim() ?? '',
      whscodeTo: json['whscodeTo']?.toString().trim() ?? '',
      whsNameTo: json['whsNameTo']?.toString().trim() ?? '',
      creatby: json['creatby']?.toString().trim() ?? '',
      isSended: json['isSended'] ?? false,
      sendedBy: json['sendedBy']?.toString().trim(),
      aproveRecive: json['aproveRecive'] ?? false,
      aproveReciveBy: json['aproveReciveBy']?.toString().trim(),
      sapPost: json['sapPost'] ?? false,
      sapPostBy: json['sapPostBy']?.toString().trim(),
      sapPostDate: json['sapPostDate']?.toString(),
      createDate: json['createDate']?.toString() ?? '',
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

  // حساب الإجمالي من كافة الأسطر
  double getTotalAmount(List<TransferLine> lines) {
    return lines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
  }

  // حساب إجمالي الكمية
  double getTotalQuantity(List<TransferLine> lines) {
    return lines.fold(0.0, (sum, line) => sum + (line.quantity ?? 0.0));
  }

  // التحقق من حالة التحويل
  String get statusText {
    if (sapPost) return 'مُرحّل إلى SAP';
    if (aproveRecive) return 'تم الاستلام';
    if (isSended) return 'تم الإرسال';
    return 'قيد التحضير';
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
  final int baseQty1;
  final int ugpEntry;
  final int uomEntry;

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
    required this.baseQty1,
    required this.ugpEntry,
    required this.uomEntry,
  });

  factory TransferLine.fromJson(Map<String, dynamic> json) {
    return TransferLine(
      docEntry: json['docEntry'] ?? 0,
      lineNum: json['lineNum'] ?? 0,
      itemCode: json['itemCode']?.toString(),
      description: json['dscription']?.toString(), // ملاحظة: dscription في JSON
      quantity: _parseDouble(json['quantity']),
      price: _parseDouble(json['price']),
      lineTotal: _parseDouble(json['lineTotal']),
      uomCode: json['uomCode']?.toString(),
      uomCode2: json['uomCode2']?.toString(),
      invQty: _parseDouble(json['invQty']),
      baseQty1: json['baseQty1'] ?? 0,
      ugpEntry: json['ugpEntry'] ?? 0,
      uomEntry: json['uomEntry'] ?? 0,
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

  // دالة مساعدة لتحويل القيم إلى double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // حساب النسبة المئوية للصنف من الإجمالي
  double getPercentageOfTotal(double totalAmount) {
    if (totalAmount == 0 || lineTotal == null) return 0;
    return (lineTotal! / totalAmount) * 100;
  }
}

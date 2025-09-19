// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';

// /// نموذج بيانات للوحدة - محدث
// class ItemUnit {
//   final String uomCode;
//   final String uomName;
//   final int baseQty;
//   final int uomEntry;
//   final int ugpEntry;
//   final String? description;

//   ItemUnit({
//     required this.uomCode,
//     required this.uomName,
//     required this.baseQty,
//     required this.uomEntry,
//     required this.ugpEntry,
//     this.description,
//   });

//   // إنشاء من UomModel - الطريقة المفقودة
//   factory ItemUnit.fromUomModel(UomModel uom) {
//     return ItemUnit(
//       uomCode: uom.uomName,
//       uomName: uom.uomName,
//       baseQty: uom.baseQty.toInt(),
//       uomEntry: uom.uomEntry,
//       ugpEntry: 1, // قيمة افتراضية
//     );
//   }

//   factory ItemUnit.fromJson(Map<String, dynamic> json) {
//     return ItemUnit(
//       uomCode: json['uomCode']?.toString() ?? json['uomName']?.toString() ?? '',
//       uomName: json['uomName']?.toString() ?? json['uomCode']?.toString() ?? '',
//       baseQty: json['baseQty']?.toInt() ?? 1,
//       uomEntry: json['uomEntry']?.toInt() ?? 1,
//       ugpEntry: json['ugpEntry']?.toInt() ?? 1,
//       description: json['description']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'uomCode': uomCode,
//       'uomName': uomName,
//       'baseQty': baseQty,
//       'uomEntry': uomEntry,
//       'ugpEntry': ugpEntry,
//       'description': description,
//     };
//   }

//   @override
//   String toString() {
//     return 'ItemUnit{uomCode: $uomCode, uomName: $uomName, baseQty: $baseQty}';
//   }
// }

import 'package:intl/intl.dart';

class InvoiceHelpers {
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MM/dd/yyyy hh:mm:ss a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}

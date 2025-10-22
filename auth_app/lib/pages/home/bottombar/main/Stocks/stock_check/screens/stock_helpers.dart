import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';

class StockHelpers {
  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static Color getStockColorFromModel(StockModel stock) {
    switch (stock.stockStatus) {
      case StockStatus.deficit:
        return Colors.red;
      case StockStatus.empty:
        return Colors.orange;
      case StockStatus.low:
        return Colors.yellow[700]!;
      case StockStatus.available:
        return Colors.green;
    }
  }
}

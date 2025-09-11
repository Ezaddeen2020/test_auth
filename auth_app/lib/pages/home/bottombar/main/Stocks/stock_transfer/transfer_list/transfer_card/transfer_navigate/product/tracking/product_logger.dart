// import 'package:flutter/foundation.dart';

// enum LogLevel {
//   debug,
//   info,
//   warning,
//   error,
//   critical,
// }

// class ProductLogger {
//   static const String _tag = 'ProductManagement';
//   static bool _isEnabled = true;
//   static LogLevel _minLevel = LogLevel.debug;
//   static List<LogEntry> _logs = [];
//   static int _maxLogs = 1000;

//   // تشغيل/إيقاف التسجيل
//   static void setEnabled(bool enabled) {
//     _isEnabled = enabled;
//   }

//   // تحديد الحد الأدنى لمستوى التسجيل
//   static void setMinLevel(LogLevel level) {
//     _minLevel = level;
//   }

//   // تحديد العدد الأقصى للسجلات المحفوظة
//   static void setMaxLogs(int maxLogs) {
//     _maxLogs = maxLogs;
//   }

//   // تسجيل رسالة تصحيح الأخطاء
//   static void debug(String message, {String? context, Map<String, dynamic>? data}) {
//     _log(LogLevel.debug, message, context: context, data: data);
//   }

//   // تسجيل رسالة معلومات
//   static void info(String message, {String? context, Map<String, dynamic>? data}) {
//     _log(LogLevel.info, message, context: context, data: data);
//   }

//   // تسجيل تحذير
//   static void warning(String message, {String? context, Map<String, dynamic>? data}) {
//     _log(LogLevel.warning, message, context: context, data: data);
//   }

//   // تسجيل خطأ
//   static void error(String message, {String? context, Map<String, dynamic>? data, Object? exception}) {
//     _log(LogLevel.error, message, context: context, data: data, exception: exception);
//   }

//   // تسجيل خطأ حرج
//   static void critical(String message, {String? context, Map<String, dynamic>? data, Object? exception}) {
//     _log(LogLevel.critical, message, context: context, data: data, exception: exception);
//   }

//   // الدالة الأساسية للتسجيل
//   static void _log(
//     LogLevel level, 
//     String message, {
//     String? context,
//     Map<String, dynamic>? data,
//     Object? exception,
//   }) {
//     if (!_isEnabled || level.index < _minLevel.index) return;

//     DateTime timestamp = DateTime.now();
//     String fullContext = context != null ? '[$_tag:$context]' : '[$_tag]';
    
//     // إنشاء سجل جديد
//     LogEntry entry = LogEntry(
//       level: level,
//       message: message,
//       context: fullContext,
//       timestamp: timestamp,
//       data: data,
//       exception: exception,
//     );

//     // إضافة إلى القائمة
//     _logs.add(entry);

//     // إزالة السجلات القديمة إذا تجاوزت الحد الأقصى
//     if (_logs.length > _maxLogs) {
//       _logs.removeAt(0);
//     }

//     // طباعة في وضع التطوير
//     if (kDebugMode) {
//       String logMessage = _formatLogMessage(entry);
//       print(logMessage);
//     }
//   }

//   // تنسيق رسالة السجل للطباعة
//   static String _formatLogMessage(LogEntry entry) {
//     String levelStr = _getLevelString(entry.level);
//     String timeStr = _formatTime(entry.timestamp);
    
//     StringBuffer buffer = StringBuffer();
//     buffer.write('$timeStr $levelStr ${entry.context} ${entry.message}');
    
//     if (entry.data != null && entry.data!.isNotEmpty) {
//       buffer.write(' | Data: ${entry.data}');
//     }
    
//     if (entry.exception != null) {
//       buffer.write(' | Exception: ${entry.exception}');
//     }
    
//     return buffer.toString();
//   }

//   // تحويل مستوى السجل إلى نص
//   static String _getLevelString(LogLevel level) {
//     switch (level) {
//       case LogLevel.debug:
//         return '[DEBUG]';
//       case LogLevel.info:
//         return '[INFO] ';
//       case LogLevel.warning:
//         return '[WARN] ';
//       case LogLevel.error:
//         return '[ERROR]';
//       case LogLevel.critical:
//         return '[CRIT] ';
//     }
//   }

//   // تنسيق الوقت
//   static String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:'
//            '${time.minute.toString().padLeft(2, '0')}:'
//            '${time.second.toString().padLeft(2, '0')}';
//   }

//   // الحصول على جميع السجلات
//   static List<LogEntry> getAllLogs() {
//     return List.from(_logs);
//   }

//   // الحصول على السجلات حسب المستوى
//   static List<LogEntry> getLogsByLevel(LogLevel level) {
//     return _logs.where((log) => log.level == level).toList();
//   }

//   // الحصول على السجلات حسب السياق
//   static List<LogEntry> getLogsByContext(String context) {
//     return _logs.where((log) => log.context.contains(context)).toList();
//   }

//   // الحصول على السجلات في فترة زمنية
//   static List<LogEntry> getLogsByTimeRange(DateTime start, DateTime end) {
//     return _logs.where((log) => 
//       log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
//     ).toList();
//   }

//   // الحصول على إحصائيات السجلات
//   static Map<String, dynamic> getLogStats() {
//     Map<LogLevel, int> levelCounts = {};
//     Map<String, int> contextCounts = {};
    
//     for (LogEntry log in _logs) {
//       levelCounts[log.level] = (levelCounts[log.level] ?? 0) + 1;
      
//       String context = log.context.replaceAll(RegExp(r'[\[\]]'), '');
//       contextCounts[context] = (contextCounts[context] ?? 0) + 1;
//     }
    
//     return {
//       'totalLogs': _logs.length,
//       'levelCounts': levelCounts.map((k, v) => MapEntry(k.toString(), v)),
//       'contextCounts': contextCounts,
//       'oldestLog': _logs.isNotEmpty ? _logs.first.timestamp : null,
//       'newestLog': _logs.isNotEmpty ? _logs.last.timestamp : null,
//     };
//   }

//   // مسح جميع السجلات
//   static void clearLogs() {
//     _logs.clear();
//   }

//   // مسح السجلات القديمة
//   static void clearOldLogs(Duration maxAge) {
//     DateTime cutoff = DateTime.now().subtract(maxAge);
//     _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
//   }

//   // تصدير السجلات كنص
//   static String exportLogsAsText({LogLevel? minLevel, String? context}) {
//     List<LogEntry> filteredLogs = _logs;
    
//     if (minLevel != null) {
//       filteredLogs = filteredLogs.where((log) => log.level.index >= minLevel.index).toList();
//     }
    
//     if (context != null) {
//       filteredLogs = filteredLogs.where((log) => log.context.contains(context)).toList();
//     }
    
//     StringBuffer buffer = StringBuffer();
//     buffer.writeln('=== Product Management Logs ===');
//     buffer.writeln('Generated: ${DateTime.now()}');
//     buffer.writeln('Total logs: ${filteredLogs.length}');
//     buffer.writeln('');
    
//     for (LogEntry log in filteredLogs) {
//       buffer.writeln(_formatLogMessage(log));
//     }
    
//     return buffer.toString();
//   }

//   // دوال مخصصة لتسجيل العمليات المختلفة
  
//   // تسجيل عملية تحميل البيانات
//   static void logDataLoad(String operation, {bool success = true, String? details}) {
//     if (success) {
//       info('تحميل البيانات: $operation', context: 'DataLoad', data: {'details': details});
//     } else {
//       error('فشل تحميل البيانات: $operation', context: 'DataLoad', data: {'details': details});
//     }
//   }

//   // تسجيل عملية حفظ البيانات
//   static void logDataSave(String operation, {bool success = true, String? details, int? count}) {
//     Map<String, dynamic> data = {'details': details};
//     if (count != null) data['count'] = count;
    
//     if (success) {
//       info('حفظ البيانات: $operation', context: 'DataSave', data: data);
//     } else {
//       error('فشل حفظ البيانات: $operation', context: 'DataSave', data: data);
//     }
//   }

//   // تسجيل عملية بحث
//   static void logSearch(String query, int results, {Duration? duration}) {
//     Map<String, dynamic> data = {
//       'query': query,
//       'results': results,
//     };
//     if (duration != null) data['duration'] = '${duration.inMilliseconds}ms';
    
//     debug('عملية بحث', context: 'Search', data: data);
//   }

//   // تسجيل عملية على المنتج
//   static void logProductOperation(String operation, String? itemCode, {bool success = true, String? details}) {
//     Map<String, dynamic> data = {
//       'operation': operation,
//       'itemCode': itemCode,
//       'details': details,
//     };
    
//     if (success) {
//       info('عملية منتج: $operation', context: 'Product', data: data);
//     } else {
//       error('فشل عملية منتج: $operation', context: 'Product', data: data);
//     }
//   }

//   // تسجيل أخطاء API
//   static void logApiError(String endpoint, String error, {int? statusCode, Map<String, dynamic>? response}) {
//     Map<String, dynamic> data = {
//       'endpoint': endpoint,
//       'error': error,
//     };
//     if (statusCode != null) data['statusCode'] = statusCode;
//     if (response != null) data['response'] = response;
    
//     // error('خطأ API', context: 'API', data: data);
//   }

//   // تسجيل أداء العمليات
//   static void logPerformance(String operation, Duration duration, {Map<String, dynamic>? metrics}) {
//     Map<String, dynamic> data = {
//       'operation': operation,
//       'duration': '${duration.inMilliseconds}ms',
//     };
//     if (metrics != null) data.addAll(metrics);
    
//     if (duration.inSeconds > 3) {
//       warning('عملية بطيئة: $operation', context: 'Performance', data: data);
//     } else {
//       debug('أداء العملية: $operation', context: 'Performance', data: data);
//     }
//   }
// }

// // كلاس سجل واحد
// class LogEntry {
//   final LogLevel level;
//   final String message;
//   final String context;
//   final DateTime timestamp;
//   final Map<String, dynamic>? data;
//   final Object? exception;

//   LogEntry({
//     required this.level,
//     required this.message,
//     required this.context,
//     required this.timestamp,
//     this.data,
//     this.exception,
//   });

//   @override
//   String toString() {
//     return 'LogEntry(level: $level, message: $message, context: $context, timestamp: $timestamp)';
//   }
// }
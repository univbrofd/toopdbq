import 'dart:core';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormString({String format = 'yyyyMMddHHmmssSS'}) {
    var formatter = DateFormat(format);
    var formatted = formatter.format(this);
    print('DateTime time:$this to $formatted');
    return formatted;
  }

  String toFormStringYM({String format = 'yyyyMM'}) {
    var formatter = DateFormat(format);
    var formatted = formatter.format(this);
    return formatted;
  }
  String toFormStringM({String format = 'MM'}) {
    var formatter = DateFormat(format);
    var formatted = formatter.format(this);
    return formatted;
  }

  String getWeekDay(){
    switch(weekday){
      case 1:return '月';
      case 2:return '火';
      case 3:return '水';
      case 4:return '木';
      case 5:return '金';
      case 6:return '土';
      case 7:return '日';
    }
    return '';
  }

  static DateTime fromString(String str){
    String strTime = '${str.substring(0, 8)}T${str.substring(8,14)}';
    return DateTime.parse(strTime);
  }

  int getAge(){
    return (DateTime.now().difference(this).inDays.toInt() / 365).floor();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TimeUtils {
  static String convertTime(Timestamp timestamp) {
    DateTime time = timestamp.toDate();
    DateTime now = DateTime.now();

    if (time.day != now.day) {
      return '${time.day}.${time.month}.${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
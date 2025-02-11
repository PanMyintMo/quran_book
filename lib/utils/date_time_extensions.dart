import 'package:quran_book/utils/strings_extensions.dart';

extension DateTimeExtensions on DateTime {
  String get getHoursAndMinutes {
    int hours = hour;
    int minutes = minute;

    String formattedTime = hours > 0 ? "$hours ${"hour".addS(hours)} and $minutes ${'minute'.addS(minutes)}" : "$minutes minutes";
    return formattedTime;
  }
}

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tablets/src/common/functions/debug_print.dart';

String generateRandomString({int len = 5}) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89)).toString();
}

// used to create thousand comma separators for numbers displayed in the UI
// it can be used with or without decimal places using numDecimalPlaces optional parameter
String doubleToStringWithComma(dynamic value,
    {int? numDecimalPlaces, bool isAbsoluteValue = false}) {
  if (value == null) {
    return '';
  }
  String valueString;
  if (value is double || value is num) {
    value = value.round();
  }
  if (isAbsoluteValue && (value is double || value is num || value is int)) {
    value = value.abs();
  }
  if (numDecimalPlaces != null) {
    valueString = value.toStringAsFixed(numDecimalPlaces); // Keeping 2 decimal places
  } else {
    valueString = value.toString();
  }
  // Split the string into whole and decimal parts
  List<String> parts = valueString.split('.');
  String wholePart = parts[0];
  String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
  // Add commas to the whole part
  String formattedWholePart = wholePart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  // Combine the whole part and the decimal part
  return formattedWholePart + decimalPart;
}

String formatDate(DateTime date) => DateFormat('yyyy/MM/dd').format(date);

/// this function uses package SharedPreferences to store last update
Future<bool> checkIfOneDayPassed() async {
  bool oneDayPassed = false;
  final prefs = await SharedPreferences.getInstance();
  final lastStoredDateString = prefs.getString('lastStoredDate');
  DateTime? lastStoredDate;

  if (lastStoredDateString != null) {
    lastStoredDate = DateTime.parse(lastStoredDateString);
  }

  final currentDate = DateTime.now();

  if (lastStoredDate == null || currentDate.difference(lastStoredDate).inDays >= 1) {
    oneDayPassed = true;
    tempPrint(oneDayPassed);
  }
  await prefs.setString('lastStoredDate', currentDate.toIso8601String());
  return oneDayPassed;
}

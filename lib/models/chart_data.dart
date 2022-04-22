import 'dart:convert';

import 'package:crypto_test/utils/tools.dart';

class ChartData {
  double value;
  DateTime dateTime;

  ChartData({
    required this.value,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      value: map['rate']?.toDouble() ?? 0.0,
      dateTime: parseDateTime(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChartData.fromJson(String source) =>
      ChartData.fromMap(json.decode(source));
}

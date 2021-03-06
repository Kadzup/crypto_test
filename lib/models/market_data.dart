import 'dart:convert';

import 'package:crypto_test/utils/tools.dart';

class MarketData {
  String symbol;
  double price;
  DateTime dateTime;

  MarketData({
    required this.symbol,
    required this.price,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'price': price,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory MarketData.fromMap(Map<String, dynamic> map) {
    String tempSymbol = "";

    if (map['asset_id_base'] != null && map['asset_id_quote'] != null) {
      tempSymbol = "${map['asset_id_base']}/${map['asset_id_quote']}";
    }

    return MarketData(
      symbol: tempSymbol,
      price: map['rate']?.toDouble() ?? 0.0,
      dateTime: parseDateTime(map['time']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MarketData.fromJson(String source) =>
      MarketData.fromMap(json.decode(source));
}

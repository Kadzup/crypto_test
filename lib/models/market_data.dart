import 'dart:convert';

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
    DateTime time = DateTime.now();

    if (map['asset_id_base'] != null && map['asset_id_quote'] != null) {
      tempSymbol = "${map['asset_id_base']}/${map['asset_id_quote']}";
    }

    if (map['time'] != null) {
      String tempTime = map['time'];

      String datePart = tempTime.split("T").first;
      var dateList = datePart.split("-");
      String timePart = tempTime.split("T").last.replaceAll("Z", "");
      var timeList = timePart.split(":");

      time = DateTime(
        // date
        int.parse(dateList[0]),
        int.parse(dateList[1]),
        int.parse(dateList[2]),
        // time
        int.parse(timeList[0]),
        int.parse(timeList[1]),
        int.parse(timeList[2].replaceRange(
          timeList[2].indexOf("."),
          timeList[2].length - 1,
          "",
        )),
      );
    }

    return MarketData(
      symbol: tempSymbol,
      price: map['rate']?.toDouble() ?? 0.0,
      dateTime: time,
    );
  }

  String toJson() => json.encode(toMap());

  factory MarketData.fromJson(String source) =>
      MarketData.fromMap(json.decode(source));
}

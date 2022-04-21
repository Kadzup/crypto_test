import 'dart:convert';
import 'dart:developer';

import 'package:crypto_test/models/market_data.dart';
import 'package:crypto_test/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiController {
  bool hasSub = false;
  WebSocketChannel? _channel;

  Future<MarketData?> getMarketData(String? symbols) async {
    if (symbols == null || symbols.isEmpty) {
      throw "Invalid symbols";
    }

    symbols = symbols.toUpperCase();

    try {
      final response = await http.get(
        Uri.parse(restAPIUrl + symbols.trim()),
        headers: {'X-CoinAPI-Key': restAPIKey},
      );

      return MarketData.fromJson(response.body);
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<WebSocketChannel> listenToSymbols(String? symbols) async {
    if (symbols == null || symbols.isEmpty) {
      throw "Invalid symbols";
    }

    symbols = symbols.toUpperCase();

    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    try {
      _channel ??= WebSocketChannel.connect(Uri.parse(socketAPIUrl));
      _channel!.sink.add(
        jsonEncode(
          {
            "type": "hello",
            "apikey": "EEF7E4F6-B4AA-47AF-9E5C-E7FB4DBDF85A",
            "heartbeat": true,
            "subscribe_data_type": ["exrate"],
            "subscribe_filter_asset_id": [symbols],
          },
        ),
      );
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }

    return _channel!;
  }
}

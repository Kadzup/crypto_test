import 'dart:convert';
import 'dart:developer';

import 'package:crypto_test/models/market_data.dart';
import 'package:crypto_test/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiController {
  final _channel = ExchangeChannel();

  Future<MarketData?> getMarketData(String? symbols) async {
    if (symbols == null || symbols.isEmpty) {
      throw "Invalid symbols";
    }

    symbols = symbols.toUpperCase();

    try {
      final response = await http.get(
        Uri.parse(restAPIUrl + symbols),
        headers: {'X-CoinAPI-Key': apiKey},
      );

      return MarketData.fromJson(response.body);
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Stream listenToSymbols(String? symbols) {
    if (symbols == null || symbols.isEmpty) {
      throw "Invalid symbols";
    }

    symbols = symbols.toUpperCase();

    //_channel.close();
    _channel.reInit();

    return _channel.getData(symbols);
  }
}

class ExchangeChannel {
  var _channel = WebSocketChannel.connect(Uri.parse(websocketAPIUrl));

  void reInit() async {
    // await close();
    _channel = WebSocketChannel.connect(Uri.parse(websocketAPIUrl));
  }

  Future<void> close() async {
    await _channel.sink.close();
  }

  Stream getData(String symbols) {
    _channel.sink.add(json.encode({
      "type": "hello",
      "apikey": apiKey,
      "heartbeat": true,
      "subscribe_data_type": ["quote"],
      "subscribe_filter_asset_id": ["BTC", "ETH"]
    }));

    return _channel.stream;
  }
}

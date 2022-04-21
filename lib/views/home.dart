import 'dart:convert';
import 'dart:developer';

import 'package:crypto_test/utils/tools.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:crypto_test/controllers/api_controller.dart';
import 'package:crypto_test/models/chart_data.dart';
import 'package:crypto_test/models/market_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? symbols;
  final searchController = TextEditingController();
  final apiController = ApiController();

  @override
  void initState() {
    symbols = "BTC/USDT";
    searchController.text = symbols!;
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchArea(
              controller: searchController,
              callback: (value) {
                symbols = value;
                setState(() {});
              },
            ),
            MarketDataSection(symbols: symbols, controller: apiController),
            ChartingSection(
              symbols: symbols,
              channel: apiController.listenToSymbols(symbols),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SearchArea extends StatelessWidget {
  void Function(String?) callback;
  TextEditingController controller;

  SearchArea({
    Key? key,
    required this.callback,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "BTC/USDT",
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => callback(controller.text),
                    child: const Text("Subscribe"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MarketDataSection extends StatelessWidget {
  String? symbols;
  ApiController controller;

  MarketDataSection({
    Key? key,
    required this.symbols,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                "Market data:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(5),
              ),
              child: FutureBuilder<MarketData?>(
                future: controller.getMarketData(symbols),
                builder: (context, snapshot) {
                  if (ConnectionState.done != snapshot.connectionState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [CircularProgressIndicator()],
                    );
                  }

                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Row(
                      children: const [
                        Expanded(
                          child: Text(
                            "No information was found",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }
                  final nFormat = NumberFormat.currency(symbol: "\$");
                  final dFormat = DateFormat("MMM d, hh:mm a");

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DataColumn(
                        title: "Symbol:",
                        value: snapshot.data!.symbol,
                      ),
                      _DataColumn(
                        title: "Price:",
                        value: nFormat.format(snapshot.data!.price),
                      ),
                      _DataColumn(
                        title: "Time:",
                        value: dFormat.format(snapshot.data!.dateTime),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _DataColumn extends StatelessWidget {
  String title;
  String value;

  _DataColumn({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ChartingSection extends StatefulWidget {
  String? symbols;
  Future<WebSocketChannel> channel;

  ChartingSection({
    Key? key,
    required this.symbols,
    required this.channel,
  }) : super(key: key);

  @override
  State<ChartingSection> createState() => _ChartingSectionState();
}

class _ChartingSectionState extends State<ChartingSection> {
  List<ChartData> chartData = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Text(
                "Charting data:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(5),
              ),
              child: FutureBuilder<WebSocketChannel>(
                future: widget.channel,
                builder: (context, snapshot) {
                  if (ConnectionState.done != snapshot.connectionState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  chartData.clear();

                  if (snapshot.hasError) {
                    return Expanded(
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return StreamBuilder(
                    stream: snapshot.data!.stream,
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.hasError) {
                        return Expanded(
                          child: Text(
                            streamSnapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (streamSnapshot.hasData) {
                        var data = jsonDecode(streamSnapshot.data.toString());

                        if (data['type'] == "exrate") {
                          chartData.add(
                            ChartData(
                              dateTime: parseDateTime(data['time']),
                              value: data['rate'],
                            ),
                          );

                          log(chartData.length.toString());
                        } else {
                          log(data.toString());
                        }
                      }

                      return SfCartesianChart(
                        primaryXAxis: DateTimeAxis(),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePanning: true,
                        ),
                        series: <ChartSeries>[
                          LineSeries<ChartData, DateTime>(
                            dataSource: chartData,
                            xValueMapper: (ChartData dataItem, _) =>
                                dataItem.dateTime,
                            yValueMapper: (ChartData dataItem, _) =>
                                dataItem.value,
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

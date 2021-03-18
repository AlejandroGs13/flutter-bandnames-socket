import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/services/socket_service.dart';

import 'package:band_names/models/band.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Home();
  }
}

class _Home extends State<Home> {
  List<Band> bands = [];

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // TODO: implement build
    var icon = (socketService.serverStatus == ServerStatus.Online)
        ? Icon(Icons.online_prediction, color: Colors.blue[400])
        : Icon(Icons.offline_bolt, color: Colors.red[400]);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Band Votess',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(margin: EdgeInsets.only(right: 10), child: icon)
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int index) =>
                    _bandTile(bands[index])),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewBand();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
        key: Key(band.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          socketService.emit('delete-band', {'id': band.id});
        },
        background: Container(
          color: Colors.red[700],
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 32.0,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: TextStyle(fontSize: 20.0),
          ),
          onTap: () {
            socketService.emit('vote-band', {'id': band.id});
            print(band.id);
          },
        ));
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New Band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  child: Text('Add'),
                  elevation: 1,
                  color: Colors.white70,
                  textColor: Colors.blue[700],
                  onPressed: () {
                    addBandToList(textController.text);
                  },
                )
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text("New band name:"),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Add"),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Close"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      //podemos agregar
      socketService.emit('new-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.blue[500],
      Colors.pink[50],
      Colors.pink[200],
      Colors.pink[500],
      Colors.red[50],
      Colors.red[200],
      Colors.red[500],
    ];
    return Container(
        width: double.infinity,
        height: 200.0,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 35,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 25,
          centerText: "BANDS",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: true,
            decimalPlaces: 1,
          ),
        ));
  }
}

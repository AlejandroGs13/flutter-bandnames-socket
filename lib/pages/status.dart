import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';

class Status extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text('ServerStatus ${socketService.serverStatus}')],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.emit('emitir-mensaje',
              {'nombre': 'flutter', 'mensaje': 'hola desde flutter'});
        },
      ),
    );
  }
}

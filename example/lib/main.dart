import 'dart:async';

import 'package:dartzmq/dartzmq.dart';
import 'package:flutter/material.dart';

/// !IMPORTANT! Dont't forget to copy your shared library (.dll, .so or .dylib) to the executable path
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ZContext _context = ZContext();
  late final ZSocket _socket, _reply;
  String _receivedData = '';
  late StreamSubscription _subscription;

  @override
  void initState() {
    _socket = _context.createSocket(SocketType.dealer);
    _socket.bind("tcp://*:5566");
    // _socket.connect("tcp://192.168.2.18:5566");

    _reply = _context.createSocket(SocketType.router);
    _reply.connect("tcp://localhost:5566");

    // listen for messages
    _subscription = _socket.messages.listen((message) {
      setState(() {
        _receivedData = message.first.payload.toString();
      });
    });

    // echo messages back to dealer
    _reply.messages.listen((message) {
      _reply.sendMessage(message);
    });

    // listen for frames
    // _subscription = _socket.frames.listen((frame) {
    //   setState(() {
    //     _receivedData = frame.toString();
    //   });
    // });

    // listen for payloads
    // _subscription = _socket.payloads.listen((payload) {
    //   setState(() {
    //     _receivedData = payload.toString();
    //   });
    // });
    super.initState();
  }

  @override
  void dispose() {
    _socket.close();
    _context.stop();
    _subscription.cancel();
    super.dispose();
  }

  void _sendMessage() {
    // send message to router
    _socket.send([1, 2, 3, 4, 5]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("dartzmq demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Press to send a message'),
            MaterialButton(
              onPressed: _sendMessage,
              color: Colors.blue,
              child: const Text('Send'),
            ),
            const Text('Received'),
            Text(_receivedData),
          ],
        ),
      ),
    );
  }
}

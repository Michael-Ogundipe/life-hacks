import 'dart:async';

import 'package:example_app/core/services/batter_level.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final batteryLevel = await BatteryLevel.getBatteryLevel();
  print('Battery Level: $batteryLevel%');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Server-driven integer incrementation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    super.key,
    required this.title,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _incrementer = AsynchronousIncrementer();

  /// Semaphore used to ensure we only ever increment one number at a time.
  bool _isIncrementing = false;

  @override
  void initState() {
    super.initState();

    /// Mimics the server which listens to [AsynchronousIncrementer] and
    /// performs complicated incrementation on integers.
    _incrementer.connectToServer(IncrementerServer());
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _isIncrementing = true;
    });

    // We call `_incrementer.increment`, which internally communicates with a server
    // through two streams (representing websockets), but by the magic of completers,
    // that extra complexity is hidden from code interacting with the
    // `AsynchronousIncrementer` class.
    final incremented = await _incrementer.increment(_counter);
    setState(() {
      _isIncrementing = false;
      _counter = incremented;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: !_isIncrementing ? _incrementCounter : null,
        tooltip: 'Increment',
        child: !_isIncrementing
            ? const Icon(Icons.add)
            : CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

/// Increments a number by sending its value up to the server over (an imaginary) websocket
/// and listening for the response on the same (imaginary) websocket.
class AsynchronousIncrementer {
  Completer<int>? _completer;

  void connectToServer(IncrementerServer server) {
    _send.stream.listen((int value) => server.increment(value));
    server.responses.listen((int incremented) {
      assert(
        _completer != null,
        'Completer must not be null when output stream emits answer.',
      );
      _completer!.complete(incremented);
    });
  }

  /// Stream which mimics the ability to send a number up to the server over the websocket
  /// for highly sophisticated incrementation.
  final StreamController<int> _send = StreamController<int>();

  /// Returns true if no incrementation is currently underway, as concurrent
  /// incrementation would threaten to break the universe.
  bool get canIncrement => _completer == null || _completer!.isCompleted;

  Future<int> increment(int value) {
    if (!canIncrement) {
      throw Exception('Cannot increment while already computing!');
    }
    // Set up our Completer.
    _completer = Completer<int>();

    // Send the value up to the server for complicated incrementation.
    _send.add(value);

    // Immediately return the completer's future, which we will complete
    // when the server gets back to us on the [_output]
    return _completer!.future;
  }
}

/// Class which runs on the (imaginary) webserver, which our client communicates
/// with via websocket to increment numbers.
class IncrementerServer {
  final _responder = StreamController<int>();

  /// The server's mechanism to send incremented numbers back to the client
  /// over the imaginary websocket.
  Stream<int> get responses => _responder.stream;

  void increment(int value) async {
    // Imitate advanced Hadron Collider simulations which are only known
    // way to increment an integer, short of using quantum computers.
    Future.delayed(const Duration(seconds: 2))
        .then((_) => _responder.add(value + 1));
  }
}

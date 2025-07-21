import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basific Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Basific Calculator Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Calculator _calculator = Calculator();
  int _currentNumber = 0;
  int _result = 0;

  void _incrementNumber() {
    setState(() {
      _currentNumber++;
      _result = _calculator.addOne(_currentNumber);
    });
  }

  void _decrementNumber() {
    setState(() {
      _currentNumber--;
      _result = _calculator.addOne(_currentNumber);
    });
  }

  void _resetNumber() {
    setState(() {
      _currentNumber = 0;
      _result = _calculator.addOne(_currentNumber);
    });
  }

  @override
  void initState() {
    super.initState();
    _result = _calculator.addOne(_currentNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Basific Calculator Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Current Number:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '$_currentNumber',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'After adding one:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '$_result',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _decrementNumber,
                  child: const Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: _resetNumber,
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _incrementNumber,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementNumber,
        tooltip: 'Add One',
        child: const Icon(Icons.add),
      ),
    );
  }
}

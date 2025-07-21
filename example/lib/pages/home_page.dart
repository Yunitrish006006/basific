import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import '../widgets/calculator_card.dart';
import '../widgets/control_buttons.dart';

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
            CalculatorCard(
              currentNumber: _currentNumber,
              result: _result,
            ),
            const SizedBox(height: 30),
            ControlButtons(
              onIncrement: _incrementNumber,
              onDecrement: _decrementNumber,
              onReset: _resetNumber,
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

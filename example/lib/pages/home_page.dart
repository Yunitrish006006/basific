import 'package:basific_example/pages/users_page.dart';
import 'package:basific_example/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import '../widgets/calculator_card.dart';
import '../widgets/control_buttons.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key, 
    required this.title,
    this.currentUser,
  });

  final String title;
  final Map<String, dynamic>? currentUser;

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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('登出'),
          content: const Text('確定要登出嗎？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
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
        actions: [
          if (widget.currentUser != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  '歡迎，${widget.currentUser!['name']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _logout();
              },
              tooltip: '登出',
            ),
          ],
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // go to users page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersPage()),
                );
              },
              child: const Text('Go to Users Page'),
            ),
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

import 'package:flutter/material.dart';

class CalculatorCard extends StatelessWidget {
  const CalculatorCard({
    super.key,
    required this.currentNumber,
    required this.result,
  });

  final int currentNumber;
  final int result;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '$currentNumber',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              'After adding one:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$result',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

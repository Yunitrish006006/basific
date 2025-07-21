import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onDecrement,
          child: const Icon(Icons.remove),
        ),
        ElevatedButton(
          onPressed: onReset,
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: onIncrement,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

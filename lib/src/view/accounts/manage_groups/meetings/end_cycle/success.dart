import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onPressed;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(content),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPressed,
          child: const Text('Done'),
        ),
      ],
    );
  }
}

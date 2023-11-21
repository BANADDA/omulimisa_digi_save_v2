import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String errorMessage;

  const CustomErrorDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Row(
          children: [
            Text(
              'Error',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 15),
            Icon(Icons.error_sharp,
                color: Color.fromARGB(255, 105, 8, 1)),
          ],
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }
}

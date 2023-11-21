import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String description;
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  const CustomAlertDialog({super.key, 
    required this.description,
    required this.onYesPressed,
    required this.onNoPressed,
    required Null Function() onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_sharp,
              color: Color.fromARGB(255, 133, 11, 2),
              size: 70,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onYesPressed,
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNoPressed,
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)));
  }
}

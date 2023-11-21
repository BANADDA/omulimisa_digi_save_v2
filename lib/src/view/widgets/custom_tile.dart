import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final Function()? onTap;

  const CustomListTile({super.key, 
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 235, 233, 233),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemberDebt extends StatelessWidget {
  // final String imageUrl;
  Uint8List bytesImage;
  final String personName;
  final String loanAmount;
  final String dueDate;

  MemberDebt({super.key, 
    // required this.imageUrl,
    required this.bytesImage,
    required this.personName,
    required this.loanAmount,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
        border: Border(
            bottom: BorderSide(
                width: 1.0,
                color: const Color.fromARGB(255, 109, 107, 107)
                    .withOpacity(0.5))), // Add this line
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                MemoryImage(bytesImage), // Use MemoryImage to display Uint8List
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    'Loan Amount: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                  ),
                  Text(
                    loanAmount,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 160, 5)),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Due Date: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                  ),
                  Text(
                    '        $dueDate',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 255, 42, 27)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class AssignFundsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> groupMembers;
  final Function(String selectedUser, double amount) onAssignFunds;

  const AssignFundsDialog({super.key, 
    required this.groupMembers,
    required this.onAssignFunds,
  });

  @override
  _AssignFundsDialogState createState() => _AssignFundsDialogState();
}

class _AssignFundsDialogState extends State<AssignFundsDialog> {
  String? selectedUser;
  double? amount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Assign Loan Funds",
        style: TextStyle(fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedUser,
            onChanged: (newValue) {
              setState(() {
                selectedUser = newValue;
              });
            },
            items: widget.groupMembers.map((member) {
              final String memberName =
                  '${member['first_name']} ${member['last_name']}';
              return DropdownMenuItem<String>(
                value: memberName,
                child: Text(memberName),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: "Select User",
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                final parsedAmount = double.tryParse(value);
                if (parsedAmount != null && parsedAmount <= 50000) {
                  amount = parsedAmount;
                } else {
                  // Amount exceeds the limit, show an error or reset it
                  amount = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Amount should not exceed 50,000 UGX"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            decoration: const InputDecoration(
              labelText: "Enter Amount in UGX",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ], // Allow only valid decimal numbers
          ),
          const SizedBox(height: 10),
          Text(
            "Amount: ${amount != null ? NumberFormat.currency(locale: 'en_US', symbol: 'UGX', decimalDigits: 0).format(amount) : 'N/A'}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Validate and assign funds when the "Assign" button is pressed
            if (selectedUser != null && amount != null) {
              widget.onAssignFunds(selectedUser!, amount!);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          child: const Text("Assign"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // Close the dialog without assigning funds
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

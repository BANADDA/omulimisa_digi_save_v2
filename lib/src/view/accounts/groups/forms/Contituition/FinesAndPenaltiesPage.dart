import 'package:flutter/material.dart';

class FinesAndPenaltiesPage extends StatefulWidget {
  const FinesAndPenaltiesPage({super.key});

  @override
  _FinesAndPenaltiesPageState createState() => _FinesAndPenaltiesPageState();
}

class _FinesAndPenaltiesPageState extends State<FinesAndPenaltiesPage> {
  final TextEditingController finesController = TextEditingController();
  final TextEditingController penaltyController = TextEditingController();
  bool hasFinesAndPenalties = false;

  @override
  void dispose() {
    finesController.dispose();
    penaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fines and Penalties',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Are there fines for late payments or violations of group rules?'),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: hasFinesAndPenalties,
                  onChanged: (value) {
                    setState(() {
                      hasFinesAndPenalties = value!;
                    });
                  },
                ),
                const Text('Yes'),
                Radio(
                  value: false,
                  groupValue: hasFinesAndPenalties,
                  onChanged: (value) {
                    setState(() {
                      hasFinesAndPenalties = value!;
                    });
                  },
                ),
                const Text('No'),
              ],
            ),
            if (hasFinesAndPenalties)
              Column(
                children: [
                  TextFormField(
                    controller: finesController,
                    decoration: const InputDecoration(labelText: 'Types of Fines'),
                  ),
                  TextFormField(
                    controller: penaltyController,
                    decoration: const InputDecoration(labelText: 'Penalty Amounts'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                // Handle form submission or navigate to the next page
                final fines = finesController.text;
                final penalties = penaltyController.text;
                // Add your logic here to use the fines and penalties data
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

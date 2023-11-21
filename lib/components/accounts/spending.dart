import 'package:flutter/material.dart';

class Spendings extends StatelessWidget {
  final String name;
  final String amount;
  const Spendings({
    Key? key,
    required this.name,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(),
      elevation: 4.0,
      child: InkWell(
        onTap: () => print("tapped"),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 15.0, bottom: 0.0, right: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[400],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

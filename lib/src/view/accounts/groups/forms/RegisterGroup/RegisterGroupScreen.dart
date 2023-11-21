import 'package:flutter/material.dart';

class RegisterGroupScreen extends StatefulWidget {
  const RegisterGroupScreen({super.key});

  @override
  State<RegisterGroupScreen> createState() => _RegisterGroupScreenState();
}

class _RegisterGroupScreenState extends State<RegisterGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 255, 233),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        leading: IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: true,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 1, 67, 3),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 11, 0, 0).withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Choose a logo to represent your group",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

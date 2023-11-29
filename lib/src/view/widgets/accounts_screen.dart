import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '/src/view/widgets/start_card.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/background.jpg',
              height: MediaQuery.of(context).size.height / 2.8,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            const Positioned(
              left: 16.0,
              right: 16.0,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 110.0),
                child: StartCard(
                  theWidth: 320.0,
                  theHeight: 120.0,
                  borderRadius: 0,
                  theChild: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'DigiSave Mobile App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 300.0, left: 16.0, right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Manage User Accounts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 64, 64, 64),
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Flushbar(
                            title: "Error",
                            titleColor: Colors.white,
                            message: "New Accounts",
                            messageColor: Colors.white,
                            duration: null,
                            backgroundColor: Colors.black,
                            isDismissible: true,
                            mainButton: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              label: const Text(''),
                            ),
                          ).show(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color.fromARGB(200, 2, 121, 6)),
                          ),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.question_mark_rounded,
                                color: Color.fromARGB(200, 2, 121, 6),
                                size: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 47.0, vertical: 18.0),
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Adding vertical gap
                  ElevatedButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 18.0),
                      child: Text(
                        'Manage Groups',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Create New Accounts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 64, 64, 64),
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          Flushbar(
                            title: "Error",
                            titleColor: Colors.white,
                            message: "New Accounts",
                            messageColor: Colors.white,
                            duration: null,
                            backgroundColor: Colors.black,
                            isDismissible: true,
                            mainButton: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              label: const Text(''),
                            ),
                          ).show(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color.fromARGB(200, 2, 121, 6)),
                          ),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.question_mark_rounded,
                                color: Color.fromARGB(200, 2, 121, 6),
                                size: 15),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  TextButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 1, 67, 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      backgroundColor: Colors.transparent,
                      side: BorderSide.none,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color.fromARGB(200, 2, 121, 6),
                          child: Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                        SizedBox(
                            width:
                                15), // here put the desired space between the icon and the text
                        Text(
                          'Create New Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 2, 121, 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 1, 67, 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      backgroundColor: Colors.transparent,
                      side: BorderSide.none,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color.fromARGB(200, 2, 121, 6),
                          child: Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                        SizedBox(
                            width:
                                15), // here put the desired space between the icon and the text
                        Text(
                          'Create New Group',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 2, 121, 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Divider(color: Colors.black),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Book Name"),
                            Text("Author name"),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

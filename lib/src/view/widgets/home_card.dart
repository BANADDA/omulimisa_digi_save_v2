import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/groupData.dart';
import 'package:omulimisa_digi_save_v2/database/meetingData.dart';
import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:omulimisa_digi_save_v2/database/userData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:ui';
import '../../../database/constants.dart';
import '../authentication/login_screen.dart';
import 'package:http/http.dart' as http;

class FrostedGlassBox extends StatefulWidget {
  const FrostedGlassBox({
    Key? key,
    required this.theWidth,
    this.contentPadding = const EdgeInsets.all(20.0),
  }) : super(key: key);
  final double theWidth;
  final EdgeInsets contentPadding;
  @override
  State<FrostedGlassBox> createState() => _FrostedGlassBoxState();
}

class _FrostedGlassBoxState extends State<FrostedGlassBox> {
  var lgs = ['English', 'Luganda', 'Swahili'];

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

// Function to sync data for a specific table with the API
  Future<void> syncTableWithApi(Database database, String tableName) async {
    print('Unsynced row');
  }

  // Future<void> initializeSharedPreferences() async {
  //   print('Here');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  //   if (isFirstRun) {
  //     // Call your function here
  //     syncUserDataWithApi();
  //     syncpositionWithApi();
  //     syncDataGroupWithApi();
  //     syncDataMeetingWithApi();

  //     // Set isFirstRun to false to indicate that the function has been called
  //     prefs.setBool('isFirstRun', false);
  //   }
  // }

  @override
  void initState() {
    // initializeSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String selectedLanguage = 'English';
    void navigateToLoginscreen() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Loginscreen(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: widget.theWidth,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 55, 54, 54).withOpacity(0.25),
              const Color.fromARGB(255, 55, 54, 54).withOpacity(0.10),
            ],
          ),
        ),
        child: Padding(
          padding: widget.contentPadding,
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 10.0, sigmaY: 10.0), // Adjust blur values as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore More with DigiSave Mobile App',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Discover the world of digital finance with DigiSave mobile app. Manage your savings, make secure transactions, and access a range of financial services at your fingertips.',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Choose Your Language'),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return DropdownButton(
                                // Initial Value
                                value: selectedLanguage,

                                // Down Arrow Icon
                                icon: const Icon(Icons.keyboard_arrow_down),

                                // Array list of items
                                items: lgs.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLanguage = newValue!;
                                  });
                                },
                              );
                            }),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Do something with the selected language
                                  print('Selected Language: $selectedLanguage');

                                  // Navigate to the next screen
                                  navigateToLoginscreen();

                                  // Close the dialog
                                  Navigator.pop(context, 'OK');
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 1, 67, 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      backgroundColor: const Color.fromARGB(255, 1, 67, 3),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

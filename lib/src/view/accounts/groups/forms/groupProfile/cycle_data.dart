import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/view/accounts/groups/forms/groupProfile/cyclesScreen.dart';
import '/src/view/accounts/groups/group_start.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/alert.dart';

class CycleData extends StatefulWidget {
  const CycleData({
    Key? key,
    required this.groupName,
    required this.countryOfOrigin,
    required this.meetingLocation,
    required this.groupStatus,
    required this.groupLogo,
    required this.partnerID,
    required this.workingWithPartner,
    required this.isWorkingWithPartner,
    required this.numberOfCycles,
  }) : super(key: key);

  final String? groupName;
  final String? countryOfOrigin;
  final String? meetingLocation;
  final String? groupStatus;
  final File? groupLogo;
  final String? partnerID;
  final SingingCharacter? workingWithPartner;
  final bool isWorkingWithPartner;
  final String numberOfCycles;

  @override
  State<CycleData> createState() => _CycleDataState();
}

class _CycleDataState extends State<CycleData> {
  final _formKey = GlobalKey<FormState>();
  final _loanController = TextEditingController();
  final _socialController = TextEditingController();
  final _meetingsController = TextEditingController();
  static const _locale = 'en';

  //
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;
  //

  // Validation functions for your text fields
  String? validateMeetings(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the number of meetings conducted';
    }
    return null; // Return null for no validation error
  }

  String? validateLoanFund(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your group's current loan fund";
    }
    return null; // Return null for no validation error
  }

  String? validateSocialFund(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your group's current social fund";
    }
    return null; // Return null for no validation error
  }

  Future<void> storeGroupIdInSharedPreferences(String groupId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('groupid', groupId);
  }

  Future<void> retrieveGroups() async {
    // Initialize your database and tables

    // Retrieve all group profiles
    List<Map<String, dynamic>> groupProfiles =
        await DatabaseHelper.instance.getAllGroupProfiles();
    // Now, you can iterate through the group profiles and access the 'id' field along with other fields.
    for (Map<String, dynamic> groupProfile in groupProfiles) {
      String id = groupProfile['id'];
      String groupName = groupProfile['groupName'];
      String countryOfOrigin = groupProfile['countryOfOrigin'];
      // ...

      // Process the data as needed
      print(
          'ID: $id, Group Name: $groupName, Country of Origin: $countryOfOrigin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 255, 233),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Current Cycle Data',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          // leading: IconButton(
          //   icon: const Icon(
          //     Icons.cancel_outlined,
          //     color: Colors.white,
          //     size: 30,
          //   ),
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return CustomAlertDialog(
          //           description: "Are you sure you want to close this form",
          //           onYesPressed: () {
          //             Navigator.pop(context);
          //             Navigator.of(context).pop();
          //           },
          //           onNoPressed: () {
          //             Navigator.pop(context);
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
          automaticallyImplyLeading: true,
          toolbarHeight: 55,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Provide a few details about your current cycle',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 80, 78, 78),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                      const SizedBox(
                        height: 30,
                      ),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 0.0,
                                  ),
                                  child: Text(
                                    'How many meetings has your group conducted?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 17, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            // Use TextFormField here
                            controller: _meetingsController,
                            validator:
                                validateMeetings, // Apply validation function
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 0.0,
                                  ),
                                  child: Text(
                                    'Loan Fund',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 17, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            // Use TextFormField here
                            controller: _loanController,
                            validator:
                                validateLoanFund, // Apply validation function
                            decoration: const InputDecoration(
                              labelText: "Enter your group's current loan fund",
                              prefixText: 'UGX  ',
                              prefixStyle: TextStyle(
                                color: Color.fromARGB(255, 4, 88, 6),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            onChanged: (string) {
                              string =
                                  _formatNumber(string.replaceAll(',', ''));
                              _loanController.value = TextEditingValue(
                                text: string,
                                selection: TextSelection.collapsed(
                                    offset: string.length),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 0.0,
                                  ),
                                  child: Text(
                                    'Social Fund',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 17, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            // Use TextFormField here
                            controller: _socialController,
                            validator:
                                validateSocialFund, // Apply validation function
                            decoration: const InputDecoration(
                              labelText:
                                  "Enter your group's current social fund",
                              prefixText: 'UGX  ',
                              prefixStyle: TextStyle(
                                color: Color.fromARGB(255, 4, 88, 6),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            onChanged: (string) {
                              string =
                                  _formatNumber(string.replaceAll(',', ''));
                              _socialController.value = TextEditingValue(
                                text: string,
                                selection: TextSelection.collapsed(
                                    offset: string.length),
                              );
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              // Step 3: Validate the form before saving
                              if (_formKey.currentState!.validate()) {
                                // Create a Map representing the GroupProfile data
                                final groupProfileData = {
                                  'groupName': widget.groupName,
                                  'countryOfOrigin': widget.countryOfOrigin,
                                  'meetingLocation': widget.meetingLocation,
                                  'groupStatus': widget.groupStatus,
                                  'groupLogoPath': widget.groupLogo?.path,
                                  'partnerID': widget.partnerID,
                                  'workingWithPartner':
                                      widget.workingWithPartner?.toString(),
                                  'isWorkingWithPartner':
                                      widget.isWorkingWithPartner ? 1 : 0,
                                  'numberOfCycles': widget.numberOfCycles,
                                  'numberOfMeetings': _meetingsController.text,
                                  'loanFund': _loanController.text,
                                  'socialFund': _socialController.text,
                                };

                                // Save the data to the database
                                final dbHelper = DatabaseHelper.instance;
                                try {
                                  final groupId = await dbHelper
                                      .insertGroupProfile(groupProfileData);
                                  if (groupId != null) {
                                    storeGroupIdInSharedPreferences(groupId);
                                    print(
                                        'Group profile id: $groupId inserted data: $groupProfileData');
                                    //     'Group ID stored in SharedPreferences: $groupId');

                                    // Set groupProfileSaved to true
                                    setState(() {
                                      groupProfileSaved = true;
                                    });

                                    // Show a success alert
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Success'),
                                          content: const Text(
                                              'GroupProfile data saved successfully.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the alert dialog
                                                // Navigate to the next page (GroupStart)
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const GroupStart(),
                                                  ),
                                                );
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    print('Error saving GroupProfile data');

                                    // Show an error alert
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: const Text(
                                              'There was an error saving GroupProfile data.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the alert dialog
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  print('Group Profile Error $e');
                                }

                                // Check if the data was successfully saved
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 103, 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: () async {
        final bool? closeForm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              description: "Are you sure you want to close this form?",
              onYesPressed: () {
                Navigator.pop(context, true); // Return true to close the form
              },
              onNoPressed: () {
                Navigator.pop(
                    context, false); // Return false to stay on the form
              },
              onOkPressed: () {},
            );
          },
        );

        return closeForm ??
            false; // If the dialog is dismissed, default to false (stay on the form)
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/view/accounts/groups/forms/groupProfile/cycle_data.dart';
import '/src/view/accounts/groups/forms/groupProfile/cyclesScreen.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/alert.dart';
import '../../group_start.dart';

class CycleNumber extends StatefulWidget {
  const CycleNumber({
    Key? key,
    required this.groupName,
    required this.meetingLocation,
    required this.countryOfOrigin,
    required this.groupStatus,
    required this.groupLogo,
    required this.partnerID,
    required this.workingWithPartner,
    this.isWorkingWithPartner = false, // Provide a default value
    required this.numberOfCycles,
  }) : super(key: key);
  final String? groupName;
  final String? meetingLocation;
  final String? countryOfOrigin;
  final String? groupStatus;
  final File? groupLogo;
  final String? partnerID;
  final SingingCharacter? workingWithPartner;
  final bool isWorkingWithPartner;
  final String numberOfCycles; // Define the parameter for the number of cycles

  @override
  State<CycleNumber> createState() => _CycleNumberState();
}

enum CycleStatus { InMiddle, NewCycle }

class _CycleNumberState extends State<CycleNumber> {
  CycleStatus? _cycleStatus = CycleStatus.InMiddle; // Default selection
  String _buttonText = "Next";

  Future<void> storeGroupIdInSharedPreferences(int groupId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('groupid', groupId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 244, 255, 233),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 1, 67, 3),
            title: const Text(
              'Current Cycle',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: true,
            toolbarHeight: 60,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tell us about your current cycle (Are you already in the middle of a cylce, or you are starting a new cycle) ?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 17, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ListTile(
                              title: const Text(
                                'We are in the middle of a cycle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 61, 61, 61),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              leading: Radio<CycleStatus>(
                                value: CycleStatus.InMiddle,
                                groupValue: _cycleStatus,
                                onChanged: (CycleStatus? value) {
                                  setState(() {
                                    _cycleStatus = value;
                                    _buttonText = "Next";
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text(
                                'We are starting a new cycle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 61, 61, 61),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              leading: Radio<CycleStatus>(
                                value: CycleStatus.NewCycle,
                                groupValue: _cycleStatus,
                                onChanged: (CycleStatus? value) {
                                  setState(() {
                                    _cycleStatus = value;
                                    _buttonText = "Done";
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_cycleStatus == CycleStatus.InMiddle) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return CycleData(
                                              groupName: widget.groupName,
                                              meetingLocation:
                                                  widget.meetingLocation,
                                              countryOfOrigin:
                                                  widget.countryOfOrigin,
                                              groupStatus: widget.groupStatus,
                                              groupLogo: widget.groupLogo,
                                              partnerID: widget.partnerID,
                                              workingWithPartner:
                                                  widget.workingWithPartner,
                                              isWorkingWithPartner:
                                                  widget.isWorkingWithPartner,
                                              numberOfCycles:
                                                  widget.numberOfCycles,
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      try {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              title: const Text("Confirmation"),
                                              content: const Text(
                                                  "Are you sure you want to complete this form?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();

                                                    // Insert data into 'group_profile' table here
                                                    final int? insertedRows =
                                                        await DatabaseHelper
                                                            .instance
                                                            .insertGroupProfile({
                                                      'groupName':
                                                          widget.groupName,
                                                      'countryOfOrigin': widget
                                                          .countryOfOrigin,
                                                      'meetingLocation': widget
                                                          .meetingLocation,
                                                      'groupStatus':
                                                          widget.groupStatus,
                                                      'groupLogoPath': widget
                                                          .groupLogo?.path,
                                                      'partnerID':
                                                          widget.partnerID,
                                                      'workingWithPartner':
                                                          widget
                                                              .workingWithPartner
                                                              .toString(),
                                                      'isWorkingWithPartner':
                                                          widget.isWorkingWithPartner
                                                              ? 1
                                                              : 0,
                                                      'numberOfCycles':
                                                          widget.numberOfCycles,
                                                      'numberOfMeetings':
                                                          '0', // You can initialize other values here
                                                      'loanFund': '0',
                                                      'socialFund': '0',
                                                    });

                                                    if (insertedRows! > 0) {
                                                      int groupId =
                                                          insertedRows;
                                                      // Data inserted successfully
                                                      storeGroupIdInSharedPreferences(
                                                          groupId);
                                                      // print(
                                                      //     'Group ID stored in SharedPreferences: $groupId');

                                                      // Set groupProfileSaved to true
                                                      setState(() {
                                                        groupProfileSaved =
                                                            true;
                                                      });
                                                      // Data inserted successfully
                                                      final List<
                                                              Map<String,
                                                                  dynamic>>
                                                          groupProfiles =
                                                          await DatabaseHelper
                                                              .instance
                                                              .getAllGroupProfiles();
                                                      if (groupProfiles
                                                          .isNotEmpty) {
                                                        final int groupId =
                                                            groupProfiles
                                                                .first['id'];
                                                        print(
                                                            'Group profile inserted successfully. Group ID: $groupId');
                                                      } else {
                                                        print(
                                                            'Group profile inserted successfully, but unable to retrieve Group ID');
                                                      }
                                                      setState(() {
                                                        groupProfileSaved =
                                                            true;
                                                      });

                                                      // Navigate to the next screen
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return const GroupStart();
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      // Handle insertion error
                                                      print(
                                                          'Failed to insert group profile');
                                                      // You can show an error message here if needed
                                                    }
                                                  },
                                                  child: const Text("Yes"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("No"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } catch (e) {
                                        print('Error inserting data: $e');
                                        // Handle the error as needed, e.g., show an error message to the user
                                      }
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          _buttonText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Icon(
                                          Icons.navigate_next,
                                          size: 30,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
        });
  }
}

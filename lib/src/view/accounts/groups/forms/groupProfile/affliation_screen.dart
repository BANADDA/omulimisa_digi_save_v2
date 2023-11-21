import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import '/src/view/accounts/groups/forms/groupProfile/cyclesScreen.dart';

import '../../../../widgets/alert.dart';

class AffiliationScreen extends StatefulWidget {
  const AffiliationScreen({
    Key? key,
    required this.groupName,
    required this.meetingLocation,
    required this.countryOfOrigin,
    required this.groupStatus,
    required this.groupLogo,
    this.partnerID,
  }) : super(key: key);

  final String groupName;
  final String meetingLocation;
  final String countryOfOrigin;
  final String groupStatus;
  final File groupLogo;
  final String? partnerID;

  @override
  State<AffiliationScreen> createState() => _AffiliationScreenState();
}

enum SingingCharacter { Yes, No }

class _AffiliationScreenState extends State<AffiliationScreen> {
  //
  void navigateToCyclesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CyclesScreen(
          groupName: widget.groupName,
          meetingLocation: widget.meetingLocation,
          countryOfOrigin: widget.countryOfOrigin,
          groupStatus: widget.groupStatus,
          groupLogo: widget.groupLogo,
          isWorkingWithPartner: _character == SingingCharacter.Yes,
          partnerID: _character == SingingCharacter.Yes
              ? newTextEditingController?.text
              : null,
          workingWithPartner: null,
        ),
      ),
    );
  }

  //
  TextEditingController? newTextEditingController;
  FocusNode? focusNode;

  SingingCharacter? _character = SingingCharacter.Yes;
  bool _isErrorVisible = false;

  @override
  void initState() {
    super.initState();
    newTextEditingController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    newTextEditingController?.dispose();
    focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 244, 255, 233),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 1, 67, 3),
            title: const Text(
              'Partner Affiliation',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: true,
            toolbarHeight: 50,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Is your group working with an NGO, savings group network, or other partner organisations to support your use of DigiSave ?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 17, 0, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                            Column(
                              children: [
                                ListTile(
                                  title: const Text('Yes'),
                                  leading: Radio<SingingCharacter>(
                                    value: SingingCharacter.Yes,
                                    groupValue: _character,
                                    onChanged: (SingingCharacter? value) {
                                      setState(() {
                                        _character = value;
                                        _isErrorVisible =
                                            false; // Reset the error visibility
                                        // Create new instances of the controller and focus node
                                        newTextEditingController =
                                            TextEditingController();
                                        focusNode = FocusNode();
                                      });
                                    },
                                  ),
                                ),
                                ListTile(
                                  title: const Text('No'),
                                  leading: Radio<SingingCharacter>(
                                    value: SingingCharacter.No,
                                    groupValue: _character,
                                    onChanged: (SingingCharacter? value) {
                                      setState(() {
                                        _character = value;
                                        _isErrorVisible =
                                            false; // Reset the error visibility
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_character == SingingCharacter.Yes)
                              Column(
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'Partner ID',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  PinCodeFields(
                                    length: 4,
                                    controller: newTextEditingController,
                                    focusNode: focusNode,
                                    onComplete: (result) {
                                      print(result);
                                    },
                                  ),
                                  if (_isErrorVisible)
                                    const Text(
                                      'Please enter a Partner ID',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_character == SingingCharacter.Yes &&
                                        newTextEditingController!
                                            .text.isEmpty) {
                                      setState(() {
                                        _isErrorVisible = true;
                                      });
                                    } else {
                                      navigateToCyclesScreen();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 103, 4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19.0,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
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
        });
  }
}

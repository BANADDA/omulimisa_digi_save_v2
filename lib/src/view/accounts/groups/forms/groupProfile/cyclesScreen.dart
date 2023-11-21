import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/src/view/accounts/groups/forms/groupProfile/cycle_number_screen.dart';

import '../../../../widgets/alert.dart';
import '../../../../widgets/error_dialog.dart';

class CyclesScreen extends StatefulWidget {
  const CyclesScreen({
    Key? key,
    required this.groupName,
    required this.meetingLocation,
    required this.countryOfOrigin,
    required this.groupStatus,
    required this.groupLogo,
    required this.partnerID,
    required this.workingWithPartner,
    required this.isWorkingWithPartner,
  }) : super(key: key);

  final String? groupName;
  final String? meetingLocation;
  final String? countryOfOrigin;
  final String? groupStatus;
  final File? groupLogo;
  final String? partnerID;
  final SingingCharacter? workingWithPartner;
  final bool isWorkingWithPartner;

  @override
  State<CyclesScreen> createState() => _CyclesScreenState();
}

enum SingingCharacter { Yes, No }

class _CyclesScreenState extends State<CyclesScreen> {
  void navigateToLoanScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CycleNumber(
          groupName: widget.groupName,
          meetingLocation: widget.meetingLocation,
          countryOfOrigin: widget.countryOfOrigin,
          groupStatus: widget.groupStatus,
          groupLogo: widget.groupLogo,
          partnerID: widget.partnerID,
          workingWithPartner: widget.workingWithPartner,
          isWorkingWithPartner: widget.isWorkingWithPartner,
          numberOfCycles: numberOfCyclesController.text, // Pass the cycles data
        ),
      ),
    );
  }

  TextEditingController? newTextEditingController;
  FocusNode? focusNode;

  final SingingCharacter _character = SingingCharacter.Yes;
  final bool _isErrorVisible = false;
  bool isNon = false;

  TextEditingController numberOfCyclesController = TextEditingController();

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
              'Group Cycles',
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
                        const SizedBox(
                          height: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'How many cycles has your group completed in the past (excluding the current cycle) ?',
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
                            Container(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: "Enter number of cycles",
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  enabled: !isNon,
                                  controller:
                                      numberOfCyclesController, // This line associates the controller
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: isNon,
                                      onChanged: (value) {
                                        setState(() {
                                          isNon = value!;
                                          if (isNon) {
                                            numberOfCyclesController.text = "";
                                          }
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Non. This is our first cycle',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 17, 0, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (isNon ||
                                        numberOfCyclesController
                                            .text.isNotEmpty) {
                                      navigateToLoanScreen();
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const CustomErrorDialog(
                                            errorMessage:
                                                'Please enter the number of cycles or check the "Non" checkbox.',
                                          );
                                        },
                                      );
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

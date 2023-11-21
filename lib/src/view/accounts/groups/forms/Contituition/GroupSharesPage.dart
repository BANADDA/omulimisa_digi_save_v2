import 'package:flutter/material.dart';
import '/src/view/accounts/groups/forms/Contituition/LoansPage.dart';

import '../../../../widgets/alert.dart';
import 'constitution_screen.dart';

class GroupSharesData {
  final bool usesGroupShares;
  final double shareValue;
  final int maxSharesPerMember;
  final int minSharesRequired;
  final String frequencyOfContributions;

  GroupSharesData({
    required this.usesGroupShares,
    required this.shareValue,
    required this.maxSharesPerMember,
    required this.minSharesRequired,
    required this.frequencyOfContributions,
  });
}

class GroupSharesPage extends StatefulWidget {
  final int? groupId;
  final ConstitutionData data; // Data from Constitution screen
  final ConstitutionData?
      constitutionData; // Data from the previous screen (nullable)

  const GroupSharesPage({
    super.key,
    required this.data,
    this.constitutionData,
    this.groupId, // Make it nullable
  });

  @override
  _GroupSharesPageState createState() => _GroupSharesPageState();
}

class _GroupSharesPageState extends State<GroupSharesPage> {
  bool usesGroupShares = false;
  double shareValue = 0.0;
  int maxSharesPerMember = 0;
  int minSharesRequired = 0;
  String frequencyOfContributions = 'Weekly';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void navigateToLoansPage() {
    // Collect the data entered on this screen
    final groupSharesData = GroupSharesData(
      usesGroupShares: usesGroupShares,
      shareValue: shareValue,
      maxSharesPerMember: maxSharesPerMember,
      minSharesRequired: minSharesRequired,
      frequencyOfContributions: frequencyOfContributions,
    );

    // print('Group Data');
    // print('user shares: ${groupSharesData.usesGroupShares}');
    // print('user shares: ${groupSharesData.shareValue}');
    // print('user shares: ${groupSharesData.maxSharesPerMember}');
    // print('user shares: ${groupSharesData.minSharesRequired}');
    // print('user shares: ${groupSharesData.frequencyOfContributions}');

    // print('Has Constitution?: ${widget.constitutionData?.hasConstitution}');
    // print('Constitution Files: ${widget.constitutionData?.constitutionFiles}');

    // Pass the collected data and data from Constitution screen to the next screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoansPage(
          constitutionData: widget.constitutionData ??
              ConstitutionData(
                hasConstitution: false,
                constitutionFiles: [], // Provide default values if necessary
              ),
          groupId: widget.groupId,
          groupSharesData: groupSharesData, // Data collected on this screen
        ),
      ),
    );
  }

  final _minSharesRequiredController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Group Shares',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Form(
              key: _formKey, // Assign the form key
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Does the group use group shares? (Yes/No)',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 17, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: usesGroupShares,
                          onChanged: (value) {
                            setState(() {
                              usesGroupShares = value!;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 17, 0, 0),
                          ),
                        ),
                        Radio(
                          value: false,
                          groupValue: usesGroupShares,
                          onChanged: (value) {
                            setState(() {
                              usesGroupShares = value!;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 17, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    if (usesGroupShares)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Share Value',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 17, 0, 0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              double? parsedValue = double.tryParse(value);
                              if (parsedValue != null) {
                                // Valid double input
                                shareValue = parsedValue;
                              } else if (value.isNotEmpty) {
                                // Non-empty, but not a valid double
                                // You can issue a warning here or handle it as needed
                                // For example, show an error message to the user
                                // You can use a Flutter SnackBar or showDialog for this purpose.
                                // Example:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Invalid input. Please enter a valid number.'),
                                  ),
                                );
                              } else {
                                // Value is empty, you can handle this case as needed
                              }
                            },
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Share Value';
                              }
                              double? enteredShareValue =
                                  double.tryParse(value);
                              if (enteredShareValue == null) {
                                return 'Invalid input. Please enter a valid number.';
                              }

                              if (usesGroupShares) {
                                if (enteredShareValue <= 0) {
                                  return 'Share Value must be greater than 0.';
                                }
                                if (enteredShareValue <= maxSharesPerMember) {
                                  return 'Must be greater than Maximum Shares Per Member.';
                                }
                                if (enteredShareValue < minSharesRequired) {
                                  return 'Must be greater than or equal to Minimum Shares Required.';
                                }
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Maximum Shares Per Member',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 17, 0, 0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              int? parsedValue = int.tryParse(value);
                              if (parsedValue != null) {
                                // Valid integer input
                                maxSharesPerMember = parsedValue;
                              } else if (value.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Invalid input. Please enter a valid number.'),
                                  ),
                                );
                              } else {
                                // Value is empty, you can handle this case as needed
                              }
                            },
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Maximum Shares Per Member';
                              }
                              int? maxShares = int.tryParse(value);
                              if (maxShares == null) {
                                return 'Invalid input. Please enter a valid number.';
                              }
                              if (maxShares > shareValue) {
                                return 'Maximum shares cannot be greater than Share Value $shareValue.';
                              }
                              if (maxShares <= minSharesRequired) {
                                return 'Must be greater than Minimum Shares Required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Minimum Shares Required',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 17, 0, 0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              int? parsedValue = int.tryParse(value);
                              if (parsedValue != null) {
                                // Valid integer input
                                minSharesRequired = parsedValue;
                              } else if (value.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Invalid input. Please enter a valid number.'),
                                  ),
                                );
                              } else {
                                // Value is empty, you can handle this case as needed
                              }
                            },
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Minimum Shares Required';
                              }
                              int? minShares = int.tryParse(value);
                              if (minShares == null) {
                                return 'Invalid input. Please enter a valid number.';
                              }
                              if (minShares < 1) {
                                return 'Minimum shares cannot be less than 1.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Frequency of Share Contributions',
                              labelStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 17, 0, 0),
                              ),
                            ),
                            value: frequencyOfContributions,
                            items: ['Daily', 'Weekly', 'Monthly', 'Per Seating']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                frequencyOfContributions = newValue!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select the Frequency of Share Contributions';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Validate the form
                            if (_formKey.currentState!.validate()) {
                              // The form is valid, continue with your logic
                              // Handle data submission or navigation to the next page
                              navigateToLoansPage();
                            }
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 103, 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
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
              ),
            ),
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

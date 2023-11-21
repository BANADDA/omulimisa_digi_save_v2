import 'dart:io'; // Import the dart:io package for file-related functionality
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/src/view/accounts/groups/group_start.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../../database/localStorage.dart';
import '../../../../widgets/alert.dart';
import 'GroupSharesPage.dart';
import 'constitution_screen.dart';

class LoansPage extends StatefulWidget {
  final int? groupId;
  @override
  _LoansPageState createState() => _LoansPageState();

  final ConstitutionData constitutionData;
  final GroupSharesData groupSharesData;

  const LoansPage({
    super.key,
    required this.constitutionData,
    required this.groupSharesData,
    this.groupId,
  });
}

class _LoansPageState extends State<LoansPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool offersLoans = false;
  double maxLoanAmount = 0.0;
  String? interestMethod; // Make it nullable
  String? loanTerms; // Make it nullable
  List<String> selectedCollateralRequirements = [];
  List<String> collateralRequirementsList = [
    'Real Estate Property',
    'Vehicle Card',
    'Savings Account',
    'Jewelry',
    'Stocks and Bonds',
    'Certificate of Deposit',
    'Artwork',
    'Electronic Equipment',
    'Collectibles',
    'Business Assets',
  ];

  List<String> interestMethodsList = ['Flat Rate', 'Compound Interest'];
  List<String> loanTermsList = ['1_month', '2_months', '3_months'];

  final _loanAmount = TextEditingController();
  final _interestRate = TextEditingController();
  static const _locale = 'en';

  //
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  String? validateLoanAmount(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your group's current loan fund";
    }
    return null; // Return null for no validation error
  }

  // Function to convert a file to Uint8List
  Future<Uint8List> convertFileToUint8List(String filePath) async {
    File file = File(filePath);

    if (await file.exists()) {
      List<int> bytes = await file.readAsBytes();
      return Uint8List.fromList(bytes);
    } else {
      throw FileSystemException("File not found: $filePath");
    }
  }

  int constituionId = 0;

  Future<bool> saveLoanDataToDatabase() async {
    try {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;

      // Use widget property to access constitutionData and groupSharesData
      Uint8List? constitutionFileData;

      // Assuming widget.constitutionData?.constitutionFiles is of type List<PlatformFile>
      List<PlatformFile>? constitutionFiles =
          widget.constitutionData.constitutionFiles;

      if (constitutionFiles.isNotEmpty) {
        // Take the first file in the list (assuming there's only one)
        PlatformFile firstFile = constitutionFiles[0];
        Uint8List fileBytes = await convertPlatformFileToUint8List(firstFile);
        constitutionFileData = fileBytes;
      }

      // Convert the loan amount value to a double
      double loanAmount =
          double.tryParse(_loanAmount.text.replaceAll(',', '')) ?? 0.0;

      // Convert the interest rate to a double (remove '%' if present)
      double interestRate = double.tryParse(
              _interestRate.text.replaceAll('%', '').replaceAll(',', '')) ??
          0.0;

      // Prepare data to be inserted into the 'constitution_table'
      Map<String, dynamic> data = {
        'hasConstitution':
            widget.constitutionData.hasConstitution == true ? 1 : 0,
        'constitutionFiles': constitutionFileData, // Store the binary data
        'usesGroupShares':
            widget.groupSharesData.usesGroupShares == true ? 1 : 0,
        'shareValue': widget.groupSharesData.shareValue ?? 0.0,
        'maxSharesPerMember': widget.groupSharesData.maxSharesPerMember ?? 0,
        'minSharesRequired': widget.groupSharesData.minSharesRequired ?? 0,
        'frequencyOfContributions':
            widget.groupSharesData.frequencyOfContributions ??
                '', // Add the appropriate field for frequencyOfContributions
        'offersLoans': offersLoans ? 1 : 0, // Convert boolean to 1 or 0
        'maxLoanAmount': loanAmount,
        'interestRate': interestRate,
        'interestMethod': interestMethod ?? '',
        'loanTerms': loanTerms ?? '',
        'registrationFee': registrationFee,
        'group_id': widget.groupId,
        'selectedCollateralRequirements': selectedCollateralRequirements
            .join(', '), // Convert the list to a comma-separated string
      };

      // Insert data into the 'constitution_table'
      constituionId = await dbHelper.insertConstitutionData(data);
      print('Saved Data: $data');

      // Update the flag variable
      setState(() {
        constitutionSaved = true;
      });

      // If the insertion was successful, return true
      return true;
    } catch (e) {
      // If there was an error, return false
      print(e);
      return false;
    }
  }

  void navigateToGroupStart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupStart(constituionId: constituionId),
      ),
    );
  }

  Future<Uint8List> convertPlatformFileToUint8List(
      PlatformFile platformFile) async {
    Uint8List fileBytes = platformFile.bytes ?? Uint8List(0);
    return fileBytes;
  }

  String? groupName;

  void retrieveName() async {
    String? groupName = await DatabaseHelper.instance
        .getGroupNameByGroupId(widget.groupId.toString()); // Convert to String
    setState(() {
      this.groupName = groupName;
      print('Group Name IN ADD MEMBERS is: $groupName');
    });
  }

  bool isFirst = true;
  TextEditingController addAmountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  double registrationFee = 0.0;
  bool isSubmitted = false;

  String _formatCurrency(String value) {
    if (value.isEmpty) {
      return '0.00';
    }
    final intValue = int.parse(value);
    final dollars = (intValue / 100).toStringAsFixed(2);
    return dollars;
  }

  @override
  @override
  void initState() {
    super.initState();

    _currencyController.addListener(() {
      final value = _currencyController.text;
      final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      final formattedValue = 'UGX ${_formatCurrency(numericValue)}';
      _currencyController.value = _currencyController.value.copyWith(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );

      // Try to parse the numericValue to a double and update registrationFee
      try {
        registrationFee = double.parse(numericValue) / 100;
      } catch (e) {
        // Handle the exception here
      }
    });

    retrieveName(); // Call the function when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 1, 67, 3),
              title: const Text(
                'Loans & Registration Fees',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Does the $groupName group offer loans to its members?',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 17, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Radio(
                              value: true,
                              groupValue: offersLoans,
                              onChanged: (value) {
                                setState(() {
                                  offersLoans = value!;
                                });
                              },
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
                              groupValue: offersLoans,
                              onChanged: (value) {
                                setState(() {
                                  offersLoans = value!;
                                });
                              },
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
                        if (offersLoans)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _loanAmount,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a loan amount';
                                        }
                                        double loanValue = double.tryParse(
                                                value.replaceAll(',', '')) ??
                                            -1.0; // Parse as double, default to -1.0 if parsing fails
                                        if (loanValue <= 0) {
                                          return 'Loan amount must be greater than 0';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText:
                                            "Loan Amount Value Per Member",
                                        labelStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 17, 0, 0),
                                        ),
                                        hintText: 'Enter loan amount',
                                        hintStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 1, 99, 4),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 1, 99, 4),
                                      ),
                                      onChanged: (string) {
                                        // You can keep the onChanged logic as before
                                        string = string.replaceAll(
                                            ',', ''); // Remove commas
                                        double loanValue = double.tryParse(
                                                string) ??
                                            0.0; // Parse as double, default to 0.0 if parsing fails
                                        String formattedString =
                                            NumberFormat.decimalPattern()
                                                .format(loanValue);
                                        _loanAmount.value = TextEditingValue(
                                          text: formattedString,
                                          selection: TextSelection.collapsed(
                                              offset: formattedString.length),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                        height:
                                            8.0), // Add spacing between TextFormField and note
                                    const Text(
                                      "Note: The loan amount will be calculated as a multiple of your savings. For example, if your total savings are 9,000,000 and the loan amount value is 3, your maximum loan amount can be 3 times your savings.",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _interestRate,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an interest rate';
                                        }
                                        double interestRate = double.tryParse(
                                                value) ??
                                            -1.0; // Parse as double, default to -1.0 if parsing fails
                                        if (interestRate == 0) {
                                          return 'Interest rate cannot be 0%';
                                        }
                                        if (interestRate < 0) {
                                          return 'Interest rate cannot be negative';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: "Interest Rate (%)",
                                        labelStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 17, 0, 0),
                                        ),
                                        hintText: 'Enter interest rate',
                                        hintStyle: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 1, 99, 4),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 1, 99, 4),
                                      ),
                                      onChanged: (string) {
                                        // You can keep the onChanged logic as before
                                        string = string.replaceAll(
                                            ',', ''); // Remove commas
                                        double interestRate = double.tryParse(
                                                string) ??
                                            0.0; // Parse as double, default to 0.0 if parsing fails
                                        String formattedString =
                                            NumberFormat.decimalPattern()
                                                .format(interestRate);
                                        _interestRate.value = TextEditingValue(
                                          text: formattedString,
                                          selection: TextSelection.collapsed(
                                              offset: formattedString.length),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Interest Method',
                                  labelStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 17, 0, 0),
                                  ),
                                ),
                                value: interestMethod,
                                items: interestMethodsList.map((String method) {
                                  return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(
                                        method,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 4, 85, 7),
                                        ),
                                      ));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    interestMethod = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please specify the interest method.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Loan Terms',
                                  labelStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 17, 0, 0),
                                  ),
                                ),
                                value: loanTerms,
                                items: loanTermsList.map((String term) {
                                  return DropdownMenuItem<String>(
                                    value: term,
                                    child: Text(
                                      term,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 4, 85, 7),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    loanTerms = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please specify the loan terms.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Collateral Requirements (if any)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 17, 0, 0),
                                ),
                              ),
                              Wrap(
                                children: collateralRequirementsList
                                    .map((String requirement) {
                                  return Row(
                                    children: [
                                      Checkbox(
                                        value: selectedCollateralRequirements
                                            .contains(requirement),
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            if (newValue!) {
                                              selectedCollateralRequirements
                                                  .add(requirement);
                                            } else {
                                              selectedCollateralRequirements
                                                  .remove(requirement);
                                            }
                                          });
                                        },
                                      ),
                                      Text(requirement),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            TextField(
                              controller: _currencyController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: "Enter group's registration fees",
                              ),
                            ),
                          ],
                        ),
                        // Column(
                        //   children: [
                        //     TextFormField(
                        //       controller: addAmountController,
                        //       keyboardType: TextInputType.number,
                        //       inputFormatters: <TextInputFormatter>[
                        //         FilteringTextInputFormatter.digitsOnly,
                        //       ],
                        //       decoration: InputDecoration(
                        //         labelText: "Enter group's registration fees",
                        //       ),
                        //       onChanged: (value) {
                        //         String newValue = value.replaceAll(',', '');
                        //         if (value.isEmpty || newValue == '00') {
                        //           addAmountController.clear();
                        //           isFirst = true;
                        //           return;
                        //         }
                        //         double value1 = double.parse(newValue);
                        //         if (!isFirst) value1 = value1 * 100;
                        //         registrationFee = value1;
                        //         value = 'UGX ' +
                        //             NumberFormat.currency(
                        //                     customPattern: '###,###.##')
                        //                 .format(value1 / 100);
                        //         addAmountController.value = TextEditingValue(
                        //           text: value,
                        //           selection: TextSelection.collapsed(
                        //               offset: value.length),
                        //         );
                        //       },
                        //       validator: (value) {
                        //         if (value!.isEmpty) {
                        //           return 'Please enter the registration fee';
                        //         }
                        //         return null;
                        //       },
                        //     )
                        //   ],
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState?.save();

                                  // Save loan-related information to the database
                                  final success =
                                      await saveLoanDataToDatabase();

                                  if (success) {
                                    // Data saved successfully
                                    print(
                                        'Data saved successfully in group: $groupName with ID: ${widget.groupId}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Data saved successfully!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    // Additional code or navigation logic for success
                                    navigateToGroupStart(); // Navigate to the next screen
                                  } else {
                                    // Data save failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Error: Failed to save data.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
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
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Done',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: Colors.white),
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
                ),
              ),
            )),
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

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '/src/view/accounts/groups/forms/Contituition/GroupSharesPage.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/alert.dart';
import '../../../../widgets/error_dialog.dart';

class ConstitutionData {
  final bool hasConstitution;
  final List<PlatformFile> constitutionFiles;

  ConstitutionData({
    required this.hasConstitution,
    required this.constitutionFiles,
  });
}

class Constitution extends StatefulWidget {
  final int? groupId;

  const Constitution({super.key, this.groupId});
  @override
  _ConstitutionState createState() => _ConstitutionState();
}

class _ConstitutionState extends State<Constitution> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hasConstitution = false;
  List<PlatformFile> constitutionFiles = [];

  Future<void> _pickConstitutionFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        constitutionFiles = result.files;
      });
    }
  }

  void navigateToGroupSharesPage() {
    final constitutionData = ConstitutionData(
      hasConstitution: hasConstitution,
      constitutionFiles: constitutionFiles,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupSharesPage(
            data: constitutionData,
            constitutionData: constitutionData,
            groupId: widget.groupId // Pass the data here
            ),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    retrieveName(); // Call the function when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Constitution Details',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(
              color: Colors.white), // Set the icon color to white
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Text(
                                  'Does your $groupName group have a written constitution? (If yes, please upload it)',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 17, 0, 0),
                                    fontWeight: FontWeight.bold,
                                  ))),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Radio(
                                value: true,
                                groupValue: hasConstitution,
                                onChanged: (value) {
                                  setState(() {
                                    hasConstitution = value!;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              const Text('Yes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 24, 23, 23),
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: false,
                                groupValue: hasConstitution,
                                onChanged: (value) {
                                  setState(() {
                                    hasConstitution = value!;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              const Text('No',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 24, 23, 23),
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (hasConstitution)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickConstitutionFile,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 103, 4),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.file_copy),
                                      SizedBox(width: 8),
                                      Text('Select File'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (constitutionFiles.isNotEmpty)
                              Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      children: [
                                        if (constitutionFiles.isNotEmpty)
                                          _buildFileTypeIcon(constitutionFiles
                                                  .first.extension ??
                                              'unknown'),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            constitutionFiles.first.name,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                          ],
                        ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (hasConstitution) {
                                if (constitutionFiles.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CustomErrorDialog(
                                        errorMessage:
                                            'Please upload your constitution',
                                      );
                                    },
                                  );
                                } else {
                                  // User has selected "Yes" and also uploaded a file.
                                  // You can proceed to save data or navigate to the next page.
                                  navigateToGroupSharesPage();

                                  _formKey.currentState?.save();
                                  // Add your logic here.
                                }
                              } else {
                                final allData = ConstitutionData(
                                  hasConstitution: hasConstitution,
                                  constitutionFiles: constitutionFiles,
                                );

                                // Print the collected data to the console
                                print('All Data:');
                                print(
                                    'Has constitution?: ${allData.hasConstitution}');
                                print(
                                    'constitution file: ${allData.constitutionFiles}');
                                navigateToGroupSharesPage();
                                // User has selected "No."
                                // You can proceed to save data or navigate to the next page.
                                // Add your logic here.
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
            )
          ],
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

  Widget _buildFileTypeIcon(String fileExtension) {
    IconData iconData;
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        break;
      default:
        iconData = Icons.insert_drive_file; // Default icon for other file types
        break;
    }

    return Icon(
      iconData,
      color: Colors.red, // You can change the icon color as needed
      size: 24, // You can adjust the icon size as needed
    );
  }
}

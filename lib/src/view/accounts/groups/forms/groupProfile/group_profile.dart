import 'dart:io';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/src/view/accounts/groups/forms/groupProfile/affliation_screen.dart';

import '../../../../widgets/alert.dart';
import '../../../../widgets/data/user_data.dart';

class GroupProfile extends StatefulWidget {
  const GroupProfile({super.key});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  //

  //
  final TextEditingController _controller = TextEditingController();
  //Image picker

  File? _image;
  int _selectedIndex = -1;
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //
  String? _country;
  final List<String> _groupStatus = [
    'Real Group',
    'Practice Group',
  ];
  String? __selectedgroupStatus;
  final _formKey = GlobalKey<FormState>();
  // Variables to store form data
  String? groupName;
  String? meetingLocation;
  String? countryOfOrigin;
  String? groupStatus;
  final int _groupImageIndex = -1;
  File? _groupimage;

  void navigateToAffiliationScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AffiliationScreen(
          groupName: groupName ??
              '', // Provide a default empty string if groupName is null
          meetingLocation: meetingLocation ??
              '', // Provide a default empty string if meetingLocation is null
          countryOfOrigin: countryOfOrigin ??
              '', // Provide a default empty string if countryOfOrigin is null
          groupStatus: groupStatus ??
              '', // Provide a default empty string if groupStatus is null
          groupLogo: _image ??
              File(
                  'default_image_path.jpg'), // Provide a default image if _image is null
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return WillPopScope(
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
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 244, 255, 233),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 1, 67, 3),
            title: const Text(
              'Group Profile',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            automaticallyImplyLeading: true,
            toolbarHeight: 50,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 1, 67, 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 11, 0, 0)
                                      .withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Choose a logo to represent your group",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: SizedBox(
                                    height: 150,
                                    child: PageView.builder(
                                      itemCount: ImageData.imageUrls.length,
                                      controller:
                                          PageController(viewportFraction: 0.6),
                                      onPageChanged: (int index) =>
                                          setState(() => index = index),
                                      itemBuilder: (_, i) {
                                        return Transform.scale(
                                          scale: i == index ? 1 : 0.9,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedIndex = i;
                                                _image = File(ImageData
                                                        .imageUrls[
                                                    i]); // Update _image with the selected image
                                              });
                                            },
                                            child: Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              color: const Color.fromARGB(
                                                  255, 1, 67, 3),
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                      ImageData.imageUrls[i],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  if (_selectedIndex == i)
                                                    Positioned(
                                                      top: 6,
                                                      left: 14,
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 0, 126, 4),
                                                          border: Border.all(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 27, 1),
                                                            width: 3,
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                          Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Row(
                                      children: [
                                        Text(
                                          'What is your group name?',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Color.fromARGB(255, 17, 0, 0),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '*',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your group name';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          groupName =
                                              value; // Store the group name
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter your group name',
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  'Where is your meeting location?',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                          255, 17, 0, 0),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  '*',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your location';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  meetingLocation =
                                                      value; // Store the meeting location
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    'Enter a short description',
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Row(
                                      children: [
                                        Text(
                                          'Country of Origin',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Color.fromARGB(255, 17, 0, 0),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '*',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        textTheme: Theme.of(context)
                                            .textTheme
                                            .copyWith(
                                              titleMedium: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                                      child: CountryListPick(
                                        theme: CountryTheme(
                                          isShowFlag: true,
                                          isShowTitle: true,
                                          isShowCode: false,
                                          isDownIcon: true,
                                          showEnglishName: true,
                                        ),
                                        initialSelection: '+256',
                                        onChanged: (CountryCode? code) {
                                          setState(() {
                                            _country = code!.name!;
                                            countryOfOrigin = code
                                                .name!; // Store the country of origin
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Row(
                                      children: [
                                        Text(
                                          'Is this a real group or practice group?',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Color.fromARGB(255, 17, 0, 0),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '*',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      children: _groupStatus
                                          .map(
                                            (status) => RadioListTile(
                                              title: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0),
                                                child: Text(
                                                  status,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 138, 138, 138),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              value: status,
                                              groupValue: __selectedgroupStatus,
                                              onChanged: (value) {
                                                setState(() {
                                                  __selectedgroupStatus = value;
                                                  groupStatus =
                                                      value; // Store the group status
                                                });
                                              },
                                              activeColor: Colors.green,
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    if (__selectedgroupStatus == null)
                                      const Text(
                                        'Please select your marital status',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              navigateToAffiliationScreen();
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.green,
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 0, 103, 4),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0))),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0.0,
                                                vertical: 10.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Next',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              )
                            ],
                          )),
                        ]))
              ],
            ),
          ),
        ));
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:omulimisa_digi_save_v2/database/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../../../../../../database/localStorage.dart';
import '../../../../../../database/userData.dart';
import 'MemberProfilesScreen.dart';

class NewMemberScreen extends StatefulWidget {
  final int? groupId;

  const NewMemberScreen({super.key, this.groupId});
  @override
  _NewMemberScreenState createState() => _NewMemberScreenState();
}

class _NewMemberScreenState extends State<NewMemberScreen> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final controller = TextEditingController();
  // New controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final String _selectedGender = '';
  final TextEditingController _dependentsController = TextEditingController();
  final TextEditingController _familyInfoController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nextOfKinController = TextEditingController();
  final TextEditingController _nextOfKinPhoneNumberController =
      TextEditingController();
  final TextEditingController _residencyStatusController =
      TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _subCountyController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String _selectedPwd = 'No'; // Default value is 'No'
  String _selectedPwdType = ''; // Initially empty
  final TextEditingController _pwdTypeController =
      TextEditingController(); // PWD type field controller
  bool _isLoading = false;
  bool _nextOfKinHasPhoneNumber = false; // Initially, no phone number
  final List<String> _pwdStatusList = ['Yes', 'No'];
  final String _selectedPwdStatus = ''; // Initialize with an empty string
  final List<String> _pwdTypesList = [
    'Blind',
    'Deaf',
    'Mobility Impaired',
    'Other'
  ];

//
  final List<String> _maritalStatus = [
    'Single',
    'Married',
    'Separated or Divorced',
    'Widowed'
  ];
  String? _selectedMaritalStatus;
  final List<String> _educationBackground = [
    'No Formal Education',
    'Primary School',
    'SEcondary School',
    'University or Tertiary Institution'
  ];
  String? _selectedEducationBackground;

  final _formKey = GlobalKey<FormState>();

  String? _phone;
  String? _nextphone;
  String? _sex;
  String? _country;
  File? _image;
  String? base64Image;
  DateTime? _dateOfBirth;
  String initialCountry = 'UG';
  PhoneNumber number = PhoneNumber(isoCode: 'UG');

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image!.readAsBytesSync();
        base64Image = base64Encode(imageBytes);
        print(base64Image);
      } else {
        print('No image selected.');
      }
    });
  }

  String generateShortCode() {
    const String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    final StringBuffer code = StringBuffer();

    for (int i = 0; i < 6; i++) {
      final int randomIndex = random.nextInt(characters.length);
      code.write(characters[randomIndex]);
    }

    return code.toString();
  }

  @override
  // void dispose() {
  //   fnameController.dispose();
  //   lnameController.dispose();
  //   emailController.dispose();
  //   _phoneNumberController.dispose();
  //   _dependentsController.dispose();
  //   _familyInfoController.dispose();
  //   _locationController.dispose();
  //   _nextOfKinController.dispose();
  //   _nextOfKinPhoneNumberController.dispose();
  //   _pwdTypeController.dispose(); // Dispose PWD type field controller
  //   super.dispose();
  //   controller.dispose();
  //   super.dispose();
  // }

  Future<void> _submitdata() async {
    String fnam = fnameController.text.trim();
    String lnam = lnameController.text.trim();
    String ema = emailController.text.trim();
    final String uniqueCode = generateShortCode();
    final Map<String, dynamic> user = {
      'unique_code': uniqueCode,
      'fname': fnam,
      'lname': lnam,
      'email': ema,
      'phone': _phone,
      'sex': _sex,
      'country': _country,
      'date_of_birth': _dateOfBirth.toString(),
      'image': base64Image,
      'district': _districtController.text,
      'subCounty': _subCountyController.text,
      'village': _villageController.text,
      'number_of_dependents': _dependentsController.text,
      'family_information': _familyInfoController.text,
      'next_of_kin_name': _nextOfKinController.text,
      'next_of_kin_has_phone_number': _nextOfKinHasPhoneNumber,
      'pwd_type': _selectedPwd,
      if (_nextOfKinHasPhoneNumber) 'next_of_kin_phone_number': _nextphone,
    };

    if (_formKey.currentState!.validate()) {
      print(user);
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final int userId = await dbHelper.addUser(user);

      final database = await openDatabase('app_database.db');
      final userEndpoint = {
        'users': {
          'sendEndpoint': '${ApiConstants.baseUrl}/users/',
          'retrieveEndpoint': '${ApiConstants.baseUrl}/users/',
        },
      };

      if (userId != null) {
        try {
          for (final tableName in userEndpoint.keys) {
            final endpoints = userEndpoint[tableName];
            final sendEndpoint = endpoints!['sendEndpoint'];
            final retrieveEndpoint = endpoints['retrieveEndpoint'];
            final unsyncedData = await database.rawQuery(
              'SELECT * FROM $tableName WHERE sync_flag = ?',
              [0],
            );
            for (final data in unsyncedData) {
              final dataToSend = Map.from(data);
              try {
                final response = await http.post(
                  Uri.parse(sendEndpoint!),
                  body: json.encode(dataToSend),
                  headers: {'Content-Type': 'application/json'},
                );
                // print('Response: $response');
                // print('Data: ${json.encode(dataToSend)}');

                if (response.statusCode == 200) {
                  // Data uploaded successfully, update sync_flag to 1 in local SQLite
                  await database.rawUpdate(
                    'UPDATE $tableName SET sync_flag = ? WHERE id = ?',
                    [1, data['id']],
                  );
                  print('Success');
                } else {
                  print(response.body);
                }
              } catch (e) {
                // print('Error uploading data $data for table $tableName: $e');
              }
            }

            // Step 5: Retrieve data from the server and store it in the local SQLite database
            final serverDataResponse = await http.get(
              Uri.parse(retrieveEndpoint!),
            );

            if (serverDataResponse.statusCode == 200) {
              // Step 4: Clear local SQLite database for this table
              await database.rawDelete('DELETE FROM $tableName');

              // Reset the auto-increment counter for the primary key column
              await database.rawDelete(
                  'DELETE FROM sqlite_sequence WHERE name = ?', ['$tableName']);
              final Map<String, dynamic> responseData =
                  json.decode(serverDataResponse.body);

              for (final key in responseData.keys) {
                if (key != 'status') {
                  final List<dynamic> tableData = responseData[key];
                  print('Table data: $tableData');

                  if (tableData.isNotEmpty) {
                    print('Here');
                    for (final data in tableData) {
                      final columns = data.keys.join(', ');
                      final values =
                          List.generate(data.length, (index) => '?').join(', ');
                      final query =
                          'INSERT INTO $key ($columns) VALUES ($values)';
                      final args = data.values.toList();

                      await database.rawInsert(query, args);
                    }

                    // Step 4: Update the sync flag to 1 for all rows in that table
                    await database
                        .rawUpdate('UPDATE $tableName SET sync_flag = 1');

                    // Retrieve and print all data from the table
                    // Retrieve and print all data from the table excluding the "image" column
                    final allRows =
                        await database.rawQuery('SELECT * FROM $tableName');
                    print(
                        'All data in table $tableName (excluding "image" column):');
                    for (final row in allRows) {
                      // Exclude the "image" column
                      final filteredRow = Map.from(row)..remove('image');
                      print(filteredRow);
                    }

                    continue;
                  } else {
                    print('Server is empty');
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error uploading user data: $e');
        }
      } else {
        print('No user created');
      }

      // Create a FlutterLocalNotificationsPlugin instance
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      // Initialize the plugin with settings (you can customize this)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid, iOS: null, macOS: null);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Create a notification
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id', // Replace with your own channel ID
        'New Member Notification',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0, // Unique ID for the notification
        'Hello $fnam $lnam', // Notification title
        'Your unique code is: $uniqueCode', // Notification message
        platformChannelSpecifics,
      );

      // Implement your logic to add the new member to the group, including PWD information
      // Once added, set isLoading to true and show a loading indicator
      setState(() {
        _isLoading = true;
      });

      // Simulate member addition (Replace this with your actual logic)
      await Future.delayed(const Duration(seconds: 2));

      // Once member is added, set isLoading to false
      setState(() {
        _isLoading = false;
      });

      if (userId != -1) {
        print('User data Saved');
        dbHelper.getTodo();
      } else {
        print('There was an error');
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MemberProfilesScreen(
            groupId: widget
                .groupId), // Replace 'NextScreen()' with your actual next screen
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 213, 253, 214),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 102, 5),
        title: const Center(
          child: Text(
            'Create New Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _getImage(),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              3.5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          width: 2.0,
                                        ),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: (_image != null)
                                              ? FileImage(_image!)
                                              : const AssetImage(
                                                      'assets/local_group.jpg')
                                                  as ImageProvider<Object>,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                          backgroundColor: const Color.fromARGB(
                                              255, 12, 59, 0),
                                          radius: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              20,
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Color.fromARGB(
                                                255, 253, 253, 253),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('First Name',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: fnameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your first name',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Last Name',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: lnameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your last name',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Email', // Adding a label for the input field
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ), // Customizing label color
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.redAccent),
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.redAccent),
                                  ),
                                ),
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Please enter your email';
                                //   }
                                //   return null;
                                // },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Gender',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )),
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
                              DropdownButtonFormField<String>(
                                value: _sex,
                                decoration: const InputDecoration(
                                  hintText: 'Select Gender',
                                  hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 78, 78, 78),
                                      fontWeight: FontWeight.bold),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                dropdownColor:
                                    const Color.fromARGB(255, 1, 141, 6),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _sex == 'Male'
                                                ? Colors.black
                                                : null)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: _sex == 'Female'
                                                ? Colors.black
                                                : null)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Other',
                                    child: Text('Other',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: _sex == 'Other'
                                                ? Colors.black
                                                : null)),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  setState(() {
                                    _sex = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a gender';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Date of Birth',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
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
                              GestureDetector(
                                  onTap: () async {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now());
                                    if (pickedDate != null &&
                                        pickedDate != _dateOfBirth) {
                                      setState(() {
                                        _dateOfBirth = pickedDate;
                                      });
                                    }
                                  },
                                  child: AbsorbPointer(
                                      child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Select Date of Birth',
                                      hintStyle: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                    ),
                                    controller: TextEditingController(
                                        text: _dateOfBirth == null
                                            ? ''
                                            : DateFormat.yMd()
                                                .format(_dateOfBirth!)),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your date of birth';
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ))),
                              if (_dateOfBirth != null)
                                Text(
                                    'Age:${DateTime.now().difference(_dateOfBirth!).inDays ~/ 365}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black)),
                              const SizedBox(height: 25),
                              const Row(
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
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
                              const SizedBox(
                                height: 15,
                              ),
                              InternationalPhoneNumberInput(
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                onInputChanged: (PhoneNumber number) {
                                  print(number.phoneNumber);
                                  setState(() {
                                    _phone = number.phoneNumber!;
                                    _country = number.isoCode!;
                                  });
                                },
                                selectorConfig: const SelectorConfig(
                                  selectorType:
                                      PhoneInputSelectorType.BOTTOM_SHEET,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle:
                                    const TextStyle(color: Colors.black),
                                initialValue: number,
                                textFieldController: controller,
                                formatInput: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: true, decimal: true),
                                inputDecoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text(
                                    'Country of Origin',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
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
                                  textTheme:
                                      Theme.of(context).textTheme.copyWith(
                                            titleMedium: const TextStyle(
                                              color: Colors.black,
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
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('District',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller:
                                    _districtController, // Add a controller for the district field
                                decoration: const InputDecoration(
                                  hintText: 'Enter your district',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your district';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Sub-County',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller:
                                    _subCountyController, // Add a controller for the sub-county field
                                decoration: const InputDecoration(
                                  hintText: 'Enter your sub-county',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your sub-county';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Village',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller:
                                    _villageController, // Add a controller for the village field
                                decoration: const InputDecoration(
                                  hintText: 'Enter your village',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your village';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Text('Number of Dependents',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: _dependentsController,
                                keyboardType: TextInputType
                                    .number, // Set the keyboard type to number
                                decoration: const InputDecoration(
                                  hintText: 'Enter the number of dependents',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the number of family dependents';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Family Information',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: _familyInfoController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter family information',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter family information';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Next of Kin Name',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: _nextOfKinController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter next of kin name',
                                  hintStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter next of kin name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Does Next of Kin have a phone number?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Yes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Checkbox(
                                        value: _nextOfKinHasPhoneNumber,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _nextOfKinHasPhoneNumber =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_nextOfKinHasPhoneNumber)
                                Column(
                                  children: [
                                    const Row(
                                      children: [
                                        Text('Enter next of kin phone number',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '*',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    InternationalPhoneNumberInput(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      onInputChanged:
                                          (PhoneNumber nextNnumber) {
                                        print(nextNnumber.phoneNumber);
                                        setState(() {
                                          _nextphone = nextNnumber.phoneNumber!;
                                          _country = nextNnumber.isoCode!;
                                        });
                                      },
                                      selectorConfig: const SelectorConfig(
                                        selectorType:
                                            PhoneInputSelectorType.BOTTOM_SHEET,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode:
                                          AutovalidateMode.disabled,
                                      selectorTextStyle:
                                          const TextStyle(color: Colors.black),
                                      initialValue: number,
                                      textFieldController: controller,
                                      formatInput: true,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              signed: true, decimal: true),
                                      inputDecoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.green, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Text('Person with Disabilities (PWD) Type',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              // Dropdown for PWD
                              DropdownButtonFormField<String>(
                                value: _selectedPwd.isNotEmpty
                                    ? _selectedPwd
                                    : null,
                                items: ['Yes', 'No'].map((String pwdOption) {
                                  return DropdownMenuItem<String>(
                                    value: pwdOption,
                                    child: Text(pwdOption),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPwd =
                                        value ?? 'No'; // Set to 'No' if null
                                    _selectedPwdType =
                                        ''; // Clear the PWD type when changing the selection
                                  });
                                },
                                decoration: const InputDecoration(
                                    labelText: 'Person with Disability (PWD)?'),
                                validator: (value) {
                                  if (_selectedPwd.isEmpty) {
                                    return 'Please answer if the member has a disability';
                                  }
                                  return null;
                                },
                              ),
                              // Dropdown for PWD Type (only shown when "Yes" is selected)
                              if (_selectedPwd == 'Yes')
                                DropdownButtonFormField<String>(
                                  value: _selectedPwdType.isNotEmpty
                                      ? _selectedPwdType
                                      : null,
                                  items: [
                                    'Visual Impairment',
                                    'Hearing Impairment',
                                    'Mobility Impairment',
                                    'Cognitive Impairment',
                                    'Other'
                                  ].map((String pwdType) {
                                    return DropdownMenuItem<String>(
                                      value: pwdType,
                                      child: Text(pwdType),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedPwdType = value ??
                                          ''; // Set to an empty string if null
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'PWD Type'),
                                  validator: (value) {
                                    if (_selectedPwdType.isEmpty) {
                                      return 'Please select PWD type';
                                    }
                                    return null;
                                  },
                                ),

                              const SizedBox(height: 35),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _submitdata();
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        backgroundColor: const Color.fromARGB(
                                            255, 0, 103, 4),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 18.0),
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

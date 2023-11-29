// Import the necessary packages
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:country_list_pick/country_list_pick.dart';

import '../../screens/bottom_navigation_bar.dart';
import '../data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileData userData = UserProfileData();
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _phone;
  String? _sex;
  String? _country;
  File? _image;
  DateTime? _dateOfBirth;
  final TextEditingController _controller = TextEditingController();
  String initialCountry = 'UG';
  PhoneNumber number = PhoneNumber(isoCode: 'UG');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 255, 9),
        title: const Center(
          child: Text(
            'Update User Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
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
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    height:
                                        MediaQuery.of(context).size.width / 3.5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 0, 255, 8),
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
                                        backgroundColor: Colors.white,
                                        radius:
                                            MediaQuery.of(context).size.width /
                                                20,
                                        child: const Icon(Icons.camera_alt_outlined),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 255, 8),
                                )),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              initialValue: userData.name,
                              decoration: const InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 13),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _name = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              initialValue: userData.email,
                              decoration: const InputDecoration(
                                labelText:
                                    'Email', // Adding a label for the input field
                                labelStyle: TextStyle(
                                    color: Colors
                                        .green), // Customizing label color
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 16),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _email = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text('Gender',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 255, 8))),
                            DropdownButtonFormField<String>(
                              value: userData.sex,
                              decoration: const InputDecoration(
                                hintText: 'Select Gender',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
                                          fontSize: 16,
                                          color: _sex == 'Male'
                                              ? Colors.white
                                              : null)),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: _sex == 'Female'
                                              ? Colors.white
                                              : null)),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: _sex == 'Other'
                                              ? Colors.white
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
                            const Text('Date of Birth',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 255, 8))),
                            GestureDetector(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                          context: context,
                                          initialDate: userData.dateOfBirth ??
                                              DateTime.now(),
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
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your date of birth';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ))),
                            if (_dateOfBirth != null)
                              Text(
                                  'Age:${DateTime.now().difference(_dateOfBirth!).inDays ~/ 365}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 20),
                            const Text(
                              'Country of Origin',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 255, 8)),
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.copyWith(
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
                                initialSelection: userData.country,
                                onChanged: (CountryCode? code) {
                                  setState(() {
                                    _country = code!.name!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Phone Number',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 255, 8),
                                )),
                            const SizedBox(
                              height: 16,
                            ),
                            InternationalPhoneNumberInput(
                              textStyle: const TextStyle(color: Colors.white),
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
                              selectorTextStyle: const TextStyle(color: Colors.white),
                              initialValue: number,
                              textFieldController: _controller,
                              formatInput: true,
                              keyboardType: const TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputDecoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 18.0),
                                    child: Text(
                                      'Cancle',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {}
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
                                        horizontal: 20.0, vertical: 18.0),
                                    child: Text(
                                      'Update',
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
      bottomNavigationBar: CustomNavigationBar(current_index: 2),
    );
  }
}

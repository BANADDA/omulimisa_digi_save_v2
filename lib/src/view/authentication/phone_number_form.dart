import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:omulimisa_digi_save_v2/database/constants.dart';
import 'package:omulimisa_digi_save_v2/database/getData.dart';
import 'package:omulimisa_digi_save_v2/database/getMeetings.dart';
import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../database/localStorage.dart';
import '../widgets/start_card.dart';
import '../widgets/user_class.dart';
import '/src/view/screens/start_screen.dart';

class PhoneForm extends StatefulWidget {
  const PhoneForm({Key? key}) : super(key: key);

  @override
  _PhoneFormState createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final String _initialCountry = 'UG';
  final PhoneNumber _number = PhoneNumber(isoCode: 'UG');
  final _passwordController = TextEditingController();
  final controller = TextEditingController();
  String? _country;
  String? _phone;
  String? _test;

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>?> checkData() async {
    final data = dbHelper.getUnsyncedUser();
    return data;
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const StartScreen(),
        ),
      );
    }
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('userId', user.id!);
    prefs.setString('token', user.token);
    prefs.setString('userFirstName', user.firstName);
    prefs.setString('userLastName', user.lastName);
    // prefs.setString('token', user.token!);
  }

  // Retrieve user data from shared preferences
  Future<void> printUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userFirstName = prefs.getString('userFirstName');
    final userLastName = prefs.getString('userLastName');

    if (token != null && userFirstName != null && userLastName != null) {
      print('User ID: $token');
      print('User First Name: $userFirstName');
      print('User Last Name: $userLastName');
    } else {
      print('User data not found in shared preferences.');
    }
  }

  void showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
        Text('No internet connection. Please check your network settings.'),
        duration: Duration(seconds: 5), // You can adjust the duration as needed
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkData();
    checkLoginStatus();
  }

  Future<void> initializeSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      // Call your function here
      // syncUserDataWithApi();
      syncpositionWithApi();
      // syncDataGroupWithApi();
      // syncDataMeetingWithApi();

      // Set isFirstRun to false to indicate that the function has been called
      prefs.setBool('isFirstRun', false);
    }
  }

  Future<void> loginUser(String phoneNumber, String pinCode) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetSnackBar(context); // Show the SnackBar
      return;
    }

    // Perform the login process if internet is available
    final apiUrl = Uri.parse('${ApiConstants.baseUrl}/login-with-phone-code/');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'phone': phoneNumber, 'unique_code': pinCode});
    final Map<String, String> data = {
      'phone': phoneNumber,
      'unique_code': pinCode,
    };
    print('JSON: :$body');
    print('Here');

    final response = await http.post(apiUrl, body: data);

    if (response.statusCode == 200) {
      // Parse the response data
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('Response: $responseData');

      // // Access user data and token from responseData
      // String token = responseData['token'];
      Map<String, dynamic> userData = responseData['user'];
      // getDataGroupWithApi();
      // getDataMeetingWithApi();

      String token = responseData['Token'];
      String code = userData['unique_code'];
      int userId = userData['id'];

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${userData['fname']} ${userData['lname']}'),
        ),
      );

      // print('User ID: ${userData['id']}');
      print('First Name: ${userData['fname']}');
      print('Last Name: ${userData['lname']}');

      // String idString = userData['id'].toString();
      // int userId = int.parse(idString);
      print('User token: $token');

      // Store the token securely
      // await storage.write(key: 'token', value: token);
      await saveLoginStatus(true);
      await saveUserData(User(
        id: userId,
        token: token,
        firstName: userData['fname'],
        lastName: userData['lname'],
      ));

      printUserData();
      getDataGroupWithApi();
      getDataMeetingWithApi();
      initializeSharedPreferences();

      // Now you can use the token and user information as needed
      // print('Token: $token');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const StartScreen(),
        ),
      );
    } else {
      // Handle errors or display appropriate messages
      print('Failed to log in. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: StartCard(
              theWidth: 500.0,
              theHeight: 200.0,
              borderRadius: 0,
              theChild: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        'DigiSave VSLA Mobile App',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Enter your phone number and pin to login',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 20, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: InternationalPhoneNumberInput(
                      textStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          _phone = number.phoneNumber;
                          _country = number.isoCode!;
                        });
                      },
                      onSaved: (PhoneNumber? number) {
                        if (number != null) {
                          print('Phone Number Saved: ${number.phoneNumber}');
                          _test = number.phoneNumber;
                        }
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: const TextStyle(color: Colors.black),
                      initialValue: _number,
                      textFieldController: controller,
                      formatInput: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputDecoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.green, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Pin',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 82, 80, 80),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pin';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          print('Phone number: $_test');
                          String uniqueCode = _passwordController.text;
                          print('Full Typed phone is: $_test');
                          if (_test != null) {
                            loginUser(_test!, uniqueCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone number is required.'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print(e);
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                      );
                      return;
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

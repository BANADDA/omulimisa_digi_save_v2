import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../screens/start_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  void navigateToStartSCreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StartScreen(),
      ),
    );
  }

  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Color.transparent, // Set this to transparent
      body: Stack(
        children: [
          Image.asset('assets/background.jpg',
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "Enter the 6-digit code we sent to ${widget.phoneNumber}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    setState(() {
                      _otpCode = value;
                    });
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5.0),
                    fieldHeight: 60.0,
                    fieldWidth: 45.0,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: const Color.fromARGB(255, 102, 199, 105),
                    inactiveColor: const Color.fromARGB(255, 246, 246, 246),
                    selectedColor: Colors.green,
                  ),
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  cursorColor: Colors.white,
                  animationType: AnimationType.fade,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                ),
                const SizedBox(
                  height: 18,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive the code? ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Color.fromARGB(255, 30, 253, 38),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_otpCode.isEmpty) {
                      Flushbar(
                        title: "Error",
                        titleColor: Colors.white,
                        message: "Kindly fill in the OTP code sent",
                        messageColor: Colors.white,
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ).show(context);
                    } else {
                      navigateToStartSCreen();
                    }
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: const Color.fromARGB(255, 11, 146, 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 18.0),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19.0,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
          // Add other widgets on top of the image here
        ],
      ),
    );
  }
}

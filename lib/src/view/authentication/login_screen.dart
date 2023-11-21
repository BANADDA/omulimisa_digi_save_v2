import 'package:flutter/material.dart';
import '/src/view/authentication/phone_number_form.dart';
import '/src/view/authentication/signup_screen.dart';

// import the PhoneForm widget

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  @override
  Widget build(BuildContext context) {
    void navigateToCreateUser() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SignUpSCreen(),
        ),
      );
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 163, 245, 166),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Login',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Stack(
            // use a Stack widget
            children: [
              Column(
                // use a Column widget
                children: [
                  const PhoneForm(),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 39, 2),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: navigateToCreateUser,
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

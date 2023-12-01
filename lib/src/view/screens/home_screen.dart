import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/home_card.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   elevation: 0,
        //   title: const Text(
        //     "Welcome to DigiSave",
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 22,
        //     ),
        //   ),
        //   backgroundColor: Colors.transparent,
        // ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage('assets/local_group.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Opacity(
              opacity: 0.7, // Adjust the opacity value as needed
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 70),
                  Text(
                    'DigiSave VSLA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage("assets/app_icon.jpg"),
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  FrostedGlassBox(
                    theWidth: 330,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

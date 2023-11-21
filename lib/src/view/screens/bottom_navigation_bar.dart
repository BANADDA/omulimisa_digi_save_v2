import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../accounts/manage_groups/dashbord.dart';
import '../accounts/users/edit_profile.dart';
import '../widgets/user_class.dart';
import 'start_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  final GlobalKey<CurvedNavigationBarState> navigationBarKey = GlobalKey();
  final int current_index;

  CustomNavigationBar({super.key, required this.current_index});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  void navigateToStartScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StartScreen(),
      ),
    );
  }

  void navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get User
    User user;
    Future<User?> getUserData() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userFirstName = prefs.getString('userFirstName');
      final userLastName = prefs.getString('userLastName');

      if (token != null && userFirstName != null && userLastName != null) {
        print('User: $token');
        return User(
            token: token, firstName: userFirstName, lastName: userLastName);
      } else {
        return null;
      }
    }

    Future<void> navigateToDashboard() async {
      User? user = await getUserData();
      print('User Data: ${user?.firstName}');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashBoard(user: user), // Pass user to DashBoard
        ),
      );
    }

    List<Widget> navigationItems = [
      const Icon(Icons.dashboard, color: Colors.white, size: 20),
      const Icon(Icons.home, color: Colors.white, size: 20),
      const Icon(Icons.settings, color: Colors.white, size: 20),
    ];

    return CurvedNavigationBar(
      key: widget.navigationBarKey,
      backgroundColor: Colors.transparent,
      color: const Color.fromARGB(255, 0, 92, 2),
      onTap: (index) {
        switch (index) {
          case 0:
            navigateToDashboard();
            break;
          case 1:
            navigateToStartScreen();
            break;
          case 2:
            navigateToUserProfile();
            break;
        }
      },
      index: widget.current_index,
      items: navigationItems,
      letIndexChange: (index) => true,
      height: 50,
    );
  }
}

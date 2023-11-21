import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/getData.dart';
import 'package:omulimisa_digi_save_v2/database/getMeetings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/localStorage.dart';
import '../src/view/accounts/groups/group_start.dart';
import '../src/view/accounts/manage_groups/dashbord.dart';
import '../src/view/screens/Memebers/new_members.dart';
import '../src/view/widgets/user_class.dart';
import 'customList.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  Future<void> logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    //Update server before logout
    getDataGroupWithApi();
    getDataMeetingWithApi();

    // Clear user data from SharedPreferences
    await prefs.remove('userId');
    await prefs.remove('userFirstName');
    await prefs.remove('token');
    await prefs.remove('userLastName');
    await prefs.remove('isFirstRun');

    // Set the login status to false
    await prefs.setBool('isLoggedIn', false);

    // Replace the current route with the login screen
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    // Get User
    User user;
    Future<User?> getUserData() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId');
      final userFirstName = prefs.getString('userFirstName');
      final userLastName = prefs.getString('userLastName');

      if (userId != null && userFirstName != null && userLastName != null) {
        print('User: $userId');
        return User(
            id: userId,
            firstName: userFirstName,
            lastName: userLastName,
            token: token!);
      } else {
        return null;
      }
    }

    Future<void> navigateDashBoard() async {
      User? user = await getUserData();
      print('User Data: ${user?.firstName}');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashBoard(user: user), // Pass user to DashBoard
        ),
      );
    }

    // New Users
    void navigateToNewUsers() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NewUsers(),
        ),
      );
    }

    // New Groups
    void navigateGroupScreen() {
      setState(() {
        groupProfileSaved = false;
        constitutionSaved = false;
        scheduleSaved = false;
        membersSaved = false;
        officersSaved = false;
        getUserData();
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GroupStart(),
        ),
      );
    }

    // Function to get the user's name from SharedPreferences
    Future<String?> getUserName() async {
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('userFirstName');
      final lastName = prefs.getString('userLastName');
      if (firstName != null && lastName != null) {
        return '$firstName $lastName';
      }
      return null;
    }

    Uint8List bytes;

    Future<Uint8List>? getImage() async {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('userId');
      print('User id: $userId');

      String? base64EncodedImage;
      try {
        if (userId != null) {
          base64EncodedImage =
              await DatabaseHelper.instance.getImagePathForMember(userId);
          print('Byte image: $base64EncodedImage');
        } else {
          print('Error: User ID is null');
        }
      } catch (e) {
        print(e);
      }
      if (base64EncodedImage != null) {
        bytes = base64Decode(base64EncodedImage);
        return bytes;
      } else {
        print('Error fetching user image');
        return Uint8List(0);
      }
    }

    String phone;

    Future<String>? getphone() async {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('userId');
      print('User id: $userId');

      String? phoneNumber;
      try {
        if (userId != null) {
          phoneNumber = await DatabaseHelper.instance.getphoneNumber(userId);
          print('Byte image: $phoneNumber');
        } else {
          print('Error: User ID is null');
        }
      } catch (e) {
        print(e);
      }
      if (phoneNumber != null) {
        phone = phoneNumber;
        return phone;
      } else {
        print('Error fetching user image');
        return 'null';
      }
    }

    return Drawer(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              maxWidth: MediaQuery.of(context).size.width * 0.3,
            ),
            child: FutureBuilder(
                future: getUserName(), // Get the user's name
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Display a loading indicator while fetching the name.
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final userName = snapshot.data;
                    return ListView(
                      // Remove padding
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,

                      children: [
                        UserAccountsDrawerHeader(
                          accountName: Text(
                            userName ?? 'Unknown User',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          accountEmail: FutureBuilder<String>(
                            future: getphone(), // Get the user's image
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                phone = snapshot
                                    .data!; // Assign the image data to 'bytes'
                                return Text('Phone Number: $phone');
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Display a loading indicator while fetching the image.
                              } else {
                                return const Text(
                                    'Error fetching phone number');
                              }
                            },
                          ),
                          currentAccountPicture: FutureBuilder<Uint8List>(
                            future: getImage(), // Get the user's image
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                bytes = snapshot
                                    .data!; // Assign the image data to 'bytes'
                                return CircleAvatar(
                                  child: ClipOval(
                                    child: Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    ),
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Display a loading indicator while fetching the image.
                              } else {
                                return const Text('Error fetching image');
                              }
                            },
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/profile-bg3.jpg'),
                            ),
                          ),
                        ),
                        CustomListTile(
                          icon: Icons.home,
                          title: 'Manage Groups',
                          onTap: () {
                            navigateDashBoard();
                          },
                        ),
                        CustomListTile(
                          icon: Icons.money,
                          title: 'View Transactions',
                          onTap: () {},
                        ),
                        CustomListTile(
                          icon: Icons.wallet,
                          title: 'Wallet',
                          onTap: () {},
                        ),
                        const Divider(),
                        CustomListTile(
                          icon: Icons.group,
                          title: 'Create New Group',
                          onTap: () {
                            navigateGroupScreen();
                          },
                        ),
                        CustomListTile(
                          icon: Icons.account_box,
                          title: 'Create New Profile',
                          onTap: () {
                            navigateToNewUsers();
                          },
                        ),
                        const Divider(),
                        CustomListTile(
                          icon: Icons.person,
                          title: 'View Profile',
                          onTap: () {},
                        ),
                        CustomListTile(
                          icon: Icons.logout,
                          title: 'Log Out',
                          onTap: () async {
                            await logOut(context);
                          },
                        ),
                      ],
                    );
                  }
                })));
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/view/accounts/manage_groups/dashbord.dart';
import '/src/view/screens/Memebers/new_members.dart';

import 'package:flutter_offline/flutter_offline.dart';
import '../../../navBar/navBar.dart';
import '../accounts/groups/group_start.dart';
import '../accounts/users/edit_profile.dart';
import '../widgets/start_card.dart';
import '../widgets/user_class.dart';
import 'bottom_navigation_bar.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void navigateToUpdateProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void navigateToNewUsers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewUsers(),
      ),
    );
  }
  // Logout

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear user data from SharedPreferences
    await prefs.remove('userId');
    await prefs.remove('userFirstName');
    await prefs.remove('userLastName');

    // Set the login status to false
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Widget build(BuildContext context) {
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

    Future<void> navigateDashBoard() async {
      User? user = await getUserData();
      print('User Data: ${user?.firstName}');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashBoard(user: user), // Pass user to DashBoard
        ),
      );
    }

    // Future<void> navigateDashBoard() async {
    //   User? user = await getUserData();
    //   if (user != null) {
    //     Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) =>
    //             DashBoard(user: user), // Pass user to DashBoard
    //       ),
    //     );
    //   } else {
    //     print('User not found');
    //   }
    // }

    return Scaffold(
        key: _scaffoldKey,
        drawer: const NavBar(),
        body: OfflineBuilder(
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final bool connected = connectivity != ConnectivityResult.none;
              return new Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    child: Stack(
                      children: [
                        Stack(
                          children: [
                            Image.asset(
                              'assets/background.jpg',
                              height: MediaQuery.of(context).size.height / 2.5,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 20.0,
                              height: 25.0,
                              left: 0.0,
                              right: 0.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1.0),
                                child: Container(
                                  color: connected
                                      ? Color(0xFF00EE44)
                                      : Color(0xFFEE4400),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${connected ? 'ONLINE' : 'OFFLINE'}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: connected
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        SizedBox(
                                            width:
                                                5.0), // Add some space between text and loading indicator
                                        if (!connected)
                                          SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Positioned(
                              top: 45,
                              left: 5,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                onPressed: () {
                                  // Open the drawer using GlobalKey
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.2,
                              left: 18,
                              right: 18,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: StartCard(
                                      theWidth: 320.0,
                                      theHeight: 120.0,
                                      borderRadius: 0,
                                      theChild: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Welcome to',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'DigiSave VSLA',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 45, right: 45),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 342),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Manage User Accounts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 64, 64, 64),
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SingleChildScrollView(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.black,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 10),
                                                            child: Icon(
                                                                Icons.info,
                                                                size: 35,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          const Text(
                                                            'Tips & Advice',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          InkWell(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                              ),
                                                              Text(
                                                                'Update Profile',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "This option simplifies personalization by allowing effortless changes to your information and visuals. It ensures accuracy, reflecting your current preferences and identity. ",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // SizedBox(
                                                          //   height: 5,
                                                          // ),
                                                          const Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                              ),
                                                              Text(
                                                                'Manage Groups',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "Simplifies engagement in village-saving groups by providing unified access and effortless switching between circles. ",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                200, 2, 121, 6)),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(Icons.question_mark_rounded,
                                            color:
                                                Color.fromARGB(200, 2, 121, 6),
                                            size: 15),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton(
                                onPressed: navigateToUpdateProfile,
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 103, 4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 16.0),
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25), // Adding vertical gap
                              ElevatedButton(
                                onPressed: () {
                                  navigateDashBoard();
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
                                      horizontal: 20.0, vertical: 16.0),
                                  child: Text(
                                    'Manage Groups',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 22,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Create New Accounts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 64, 64, 64),
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SingleChildScrollView(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.black,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 10),
                                                            child: Icon(
                                                                Icons.info,
                                                                size: 35,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          const Text(
                                                            'Tips & Advice',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          InkWell(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                              ),
                                                              Text(
                                                                'Create New Profile',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "This feature allows you to create distinct profiles for seamless participation in various community groups, much like village savings associations.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // SizedBox(
                                                          //   height: 5,
                                                          // ),
                                                          const Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                              ),
                                                              Text(
                                                                'Create New Group',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                              "This feature allows you to establish and manage various community-oriented groups, akin to village savings groups. By creating new groups, you can facilitate connections and collaborations among individuals with shared interests or goals.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                200, 2, 121, 6)),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(Icons.question_mark_rounded,
                                            color:
                                                Color.fromARGB(200, 2, 121, 6),
                                            size: 15),
                                      ),
                                    ),
                                  )
                                ],
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              TextButton(
                                onPressed: () {
                                  navigateToNewUsers();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(255, 1, 67, 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide.none,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor:
                                          Color.fromARGB(200, 2, 121, 6),
                                      child: Icon(Icons.add,
                                          color: Colors.white, size: 20),
                                    ),
                                    SizedBox(
                                        width:
                                            15), // here put the desired space between the icon and the text
                                    Text(
                                      'Create New Profile',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 2, 121, 6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: navigateGroupScreen,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(255, 1, 67, 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide.none,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor:
                                          Color.fromARGB(200, 2, 121, 6),
                                      child: Icon(Icons.add,
                                          color: Colors.white, size: 20),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      'Create New Group',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 2, 121, 6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: (const Row(
                                  children: <Widget>[
                                    // ...
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Divider(
                                            color: Colors.black,
                                            thickness: 1.2,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 14,
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: const Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Color.fromARGB(
                                                    255, 1, 67, 3),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Contact Support Team',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 1, 67, 3),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/background.jpg',
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 25,
                        left: 5,
                        child: IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: () {
                            // Open the drawer using GlobalKey
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.2,
                        left: 18,
                        right: 18,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: StartCard(
                                theWidth: 320.0,
                                theHeight: 120.0,
                                borderRadius: 0,
                                theChild: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Welcome to',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'DigiSave VSLA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 45, right: 45),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 342),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Manage User Accounts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 64, 64, 64),
                              ),
                            ),
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              color: Colors.black,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: Icon(Icons.info,
                                                          size: 35,
                                                          color: Colors.white),
                                                    ),
                                                    const Text(
                                                      'Tips & Advice',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                        ),
                                                        Text(
                                                          'Update Profile',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        "This option simplifies personalization by allowing effortless changes to your information and visuals. It ensures accuracy, reflecting your current preferences and identity. ",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // SizedBox(
                                                    //   height: 5,
                                                    // ),
                                                    const Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                        ),
                                                        Text(
                                                          'Manage Groups',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        "Simplifies engagement in village-saving groups by providing unified access and effortless switching between circles. ",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(200, 2, 121, 6)),
                                ),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(Icons.question_mark_rounded,
                                      color: Color.fromARGB(200, 2, 121, 6),
                                      size: 15),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          onPressed: navigateToUpdateProfile,
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 103, 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0),
                            child: Text(
                              'Update Profile',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25), // Adding vertical gap
                        ElevatedButton(
                          onPressed: () {
                            navigateDashBoard();
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 103, 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0),
                            child: Text(
                              'Manage Groups',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 22,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Create New Accounts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 64, 64, 64),
                              ),
                            ),
                            const SizedBox(width: 25),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              color: Colors.black,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: Icon(Icons.info,
                                                          size: 35,
                                                          color: Colors.white),
                                                    ),
                                                    const Text(
                                                      'Tips & Advice',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                        ),
                                                        Text(
                                                          'Create New Profile',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        "This feature allows you to create distinct profiles for seamless participation in various community groups, much like village savings associations.",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // SizedBox(
                                                    //   height: 5,
                                                    // ),
                                                    const Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                        ),
                                                        Text(
                                                          'Create New Group',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Text(
                                                        "This feature allows you to establish and manage various community-oriented groups, akin to village savings groups. By creating new groups, you can facilitate connections and collaborations among individuals with shared interests or goals.",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(200, 2, 121, 6)),
                                ),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(Icons.question_mark_rounded,
                                      color: Color.fromARGB(200, 2, 121, 6),
                                      size: 15),
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextButton(
                          onPressed: () {
                            navigateToNewUsers();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color.fromARGB(255, 1, 67, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Color.fromARGB(200, 2, 121, 6),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 20),
                              ),
                              SizedBox(
                                  width:
                                      15), // here put the desired space between the icon and the text
                              Text(
                                'Create New Profile',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 2, 121, 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: navigateGroupScreen,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color.fromARGB(255, 1, 67, 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Color.fromARGB(200, 2, 121, 6),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 20),
                              ),
                              SizedBox(width: 15),
                              Text(
                                'Create New Group',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 2, 121, 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: (const Row(
                            children: <Widget>[
                              // ...
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Divider(
                                      color: Colors.black,
                                      thickness: 1.2,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Color.fromARGB(255, 1, 67, 3),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Contact Support Team',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 1, 67, 3),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
        bottomNavigationBar: CustomNavigationBar(current_index: 1));
  }
}

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/getData.dart';
import 'package:omulimisa_digi_save_v2/database/getMeetings.dart';
import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/groupData.dart';
import '../../../../database/localStorage.dart';
import '../../screens/bottom_navigation_bar.dart';
import '../../widgets/user_class.dart';
import '../groups/group_start.dart';
import 'group_screen.dart';

class DashBoard extends StatefulWidget {
  final User? user;
  const DashBoard({Key? key, required this.user}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<String> groupNames = []; // Define groupNames at the class level
  List<int> groupIds = [];

  Future<void> retrieveGroupNames() async {
    print('==========Retriving groups=========');
    try {
      User user = widget.user ?? User(token: '', firstName: '', lastName: '');
      // print('User ID: ${user.id}');
      final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');
      final userId = prefs.getInt('userId');
      print('User Id: $userId');

      final member = await DatabaseHelper.instance.getGroupIdsForUser(userId!);
      print('Member groups; $member');
      List<Map<String, dynamic>> linkedData =
          await DatabaseHelper.instance.getLinkedDataForUser(member);
      print('Linked Data: $linkedData');

      // final data = await DatabaseHelper.instance.getGroupsForUser(userId);
      // print('User groups: $data');
      // final pos =
      //     await DatabaseHelper.instance.getPositionsForUserInGroups(userId);
      // print('Member positions in groups; $pos');

      final groups = await DatabaseHelper.instance.getGroupsUser(userId);
      print('Groups: $groups');

      // final group_forms = await DatabaseHelper.instance.getGroupFormIds(member);
      // print('Group forms: $group_forms');

      // final dbHelper = DatabaseHelper.instance;
      // final groups = await dbHelper.getGroupIdsAndPositionsForUser(userId);
      // print('Users groups: $groups');
      // groups.forEach((element) {});

      // groups.forEach((element) async {
      //   // ignore: unnecessary_type_check
      //   if (element is int) {
      //     final groupName = await dbHelper.getGroupNamesForGroupIds([element]);
      //     print('Group name: $groupName');
      //   }
      // });

      // Remove the local variable declarations here
      groupIds.clear(); // Clear the existing values
      groupNames.clear();

      for (Map<String, dynamic> data in linkedData) {
        int groupId = data['group_id']; // Provide a default value if null
        String groupName = data['groupName'];
        groupIds.add(groupId);
        groupNames.add(groupName);
      }

      setState(() {
        // Update the class-level variables here
        groupIds = groupIds; // Store group IDs in the state
        groupNames = groupNames; // Store group names in the state
        print('GroupId: $groupIds');
      });
    } catch (e) {
      // Handle the exception here
      print('An error occurred: $e');
      // You can add more specific error handling or UI feedback as needed.
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> getGroups() async {
    if (await checkInternetConnectivity()) {
      syncDataGroupWithApi();
      List<Map<String, dynamic>> groupFormData =
          await DatabaseHelper.instance.getAllGroupFormData();
      print('All group data: $groupFormData');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update groups. No internet connection.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> printAllGroupFormData() async {
    await DatabaseHelper.instance.printPositions();
    final List<Map<String, dynamic>> dataList =
        await DatabaseHelper.instance.GroupFormData();
    for (var data in dataList) {
      print(
          'Group Forms: $data'); // You can customize the way you want to print the data here
    }
  }

  bool isLoading = true; // Declare and initialize the isLoading variable

  @override
  void initState() {
    super.initState();
    printAllGroupFormData();

    setState(() {
      isLoading = true;
    });

    // getGroups().then((_) {
    retrieveGroupNames().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Groups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  print('Here');
                  syncpositionWithApi();
                  getDataGroupWithApi();
                  setState(() {
                    isLoading = true;
                  });

                  // getGroups().then((_) {
                  retrieveGroupNames().then((_) {
                    setState(() {
                      isLoading = false;
                    });
                  });
                  // getDataMeetingWithApi();
                },
                child: Text('Sync Data'),
                style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 1, 78, 4),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0))))
          ],
        ),
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else ...{
                if (groupNames.isEmpty)
                  const Center(
                    child: Text('No groups to manage'),
                  )
                else
                  Column(
                    children: groupNames.map((groupName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: Text(
                              groupName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                int groupId =
                                    groupIds[groupNames.indexOf(groupName)];
                                // Navigate to the dashboard for the selected group
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDashboard(
                                      groupName: groupName,
                                      groupId: groupId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Select'),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(current_index: 0),
      // floatingActionButton: FloatingActionButton.extended(
      //   foregroundColor: Colors.white,
      //   backgroundColor: const Color.fromARGB(255, 0, 103, 4),
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(10.0),
      //   ),
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const GroupStart(),
      //       ),
      //     );
      //   },
      //   label: const Text('Add Group'),
      //   icon: const Icon(Icons.add),
      // ),
    );
  }
}

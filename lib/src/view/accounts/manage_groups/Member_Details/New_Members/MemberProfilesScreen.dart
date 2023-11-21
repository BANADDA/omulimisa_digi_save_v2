import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/src/view/accounts/groups/group_start.dart';
import '../../../../../../database/localStorage.dart';
import '../membership_summary.dart';
import 'existing_member.dart';
import 'new_member.dart';

class MemberProfilesScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final Function() refreshCallback;

  const MemberProfilesScreen(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.refreshCallback});
  @override
  _MemberProfilesScreenState createState() => _MemberProfilesScreenState();
}

class _MemberProfilesScreenState extends State<MemberProfilesScreen> {
  String? selectedMemberType;
  List<String> addedMembers = [];

  void _checkMemberCountAndNavigate() async {
    int memberCount = await _getGroupMemberCount();

    if (memberCount >= 2) {
      // Change the check to 5
      // Get the names of members added to the group
      List<String> addedMembers = await _getAddedMembers();

      // Show success message with added members' names
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success ${addedMembers.join(", ")} have been added to the group',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to the next screen here
      setState(() {
        membersSaved = true;
      });
      widget.refreshCallback();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MembershipSummaryScreen(
            groupId: widget.groupId,
            groupName: widget.groupName,
            refreshCallback: widget.refreshCallback,
          ),
        ),
        result: (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need to have at least 5 group members to proceed.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<int> _getGroupMemberCount() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> countResult = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM group_members',
    );
    final int memberCount = countResult[0]['count'] as int;
    return memberCount;
  }

  Future<List<String>> _getAddedMembers() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> addedMembersResult = await db.rawQuery(
      'SELECT users.fname, users.lname FROM group_members INNER JOIN users ON group_members.user_id = users.id WHERE group_members.group_id = ?',
      [widget.groupId],
    );

    List<String> addedMembers = [];
    for (var member in addedMembersResult) {
      String firstName = member['fname'] ?? '';
      String lastName = member['lname'] ?? '';
      String fullName = '$firstName $lastName';
      addedMembers.add(fullName);
    }

    return addedMembers;
  }

  void retrieveName() async {
    String? groupName = await DatabaseHelper.instance
        .getGroupNameByGroupId(widget.groupId.toString()); // Convert to String
    setState(() {
      print('Group Name is: $groupName');
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveName(); // Call the function when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    // Access the groupId using widget.groupId
    final groupId = widget.groupId;
    final groupName = widget.groupName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Add Member',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select member type to add to your group $groupName with id $groupId:',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 17, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                    value: 'Existing',
                                    groupValue: selectedMemberType,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMemberType = value;
                                      });
                                    },
                                    activeColor: Colors.green),
                                const Text('Existing Member',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 24, 23, 23),
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                            const Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 50),
                                    child: Text(
                                      'Select this option if the member is an existing user. (Note that you will be required to enter his phone number for verification)',
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                    value: 'New',
                                    groupValue: selectedMemberType,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMemberType = value;
                                      });
                                    },
                                    activeColor: Colors.green),
                                const Text('New Member',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 24, 23, 23),
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                            const Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 50),
                                    child: Text(
                                      "Select this option if the member user. You'll be required to create an account for the new user",
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _checkMemberCountAndNavigate();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            'Done',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToSelectedScreen();
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19.0,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSelectedScreen() {
    if (selectedMemberType == 'Existing') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ExistingMemberScreen(groupId: widget.groupId), // Pass groupId
      ));
    } else if (selectedMemberType == 'New') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            NewMemberScreen(groupId: widget.groupId), // Pass groupId
      ));
    }
  }
}

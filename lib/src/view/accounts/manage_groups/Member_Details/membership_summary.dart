import 'package:flutter/material.dart';
import '../../../../../database/localStorage.dart';
import 'MemberDetailsScreen.dart';
import 'New_Members/MemberProfilesScreen.dart';

class MembershipSummaryScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const MembershipSummaryScreen({super.key, 
    required this.groupId,
    required this.groupName,
    required Function() refreshCallback,
  });

  @override
  _MembershipSummaryScreenState createState() =>
      _MembershipSummaryScreenState();
}

class _MembershipSummaryScreenState extends State<MembershipSummaryScreen> {
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    List<Map<String, dynamic>> members =
        await DatabaseHelper.instance.getMembersForGroup(widget.groupId);
    setState(() {
      this.members = members;
      print('Members: $members');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: Text(
          '${widget.groupName} Members Summary',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 1, 67, 3),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Group Members',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: members.map((member) {
                          final String memberName =
                              '${member['fname']} ${member['lname']}';
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    memberName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (member['id'] != null) {
                                        int memberId = member['id'];
                                        print('MemberId: $memberId');

                                        // Retrieve the member's information
                                        List<Map<String, dynamic>>
                                            memberDetails = await DatabaseHelper
                                                .instance
                                                .getUserData(memberId);

                                        // Navigate to member details screen with member details
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MemberDetailsScreen(
                                              memberId: memberId,
                                              memberDetails: memberDetails,
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Handle the case where 'member' or 'member['id']' is null
                                        print('Member or member ID is null');
                                      }
                                    },
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberProfilesScreen(
                groupId: widget.groupId,
                groupName: widget.groupName,
                refreshCallback: () {
                  fetchMembers(); // This will trigger a refresh
                },
              ),
            ),
          );
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../../database/localStorage.dart';

class ExistingMemberScreen extends StatefulWidget {
  final int? groupId;

  const ExistingMemberScreen({super.key, this.groupId});
  @override
  _ExistingMemberScreenState createState() => _ExistingMemberScreenState();
}

class _ExistingMemberScreenState extends State<ExistingMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResultsList = [];
  String _searchMessage = ''; // Initialize a variable for the search message
  String? groupName;

  void retrieveName() async {
    String? groupName = await DatabaseHelper.instance
        .getGroupNameByGroupId(widget.groupId.toString()); // Convert to String
    setState(() {
      this.groupName = groupName;
      print('Group Name IN ADD MEMBERS is: $groupName');
    });
  }

  void _fetchGroupMembers() async {
    final int? groupId = widget.groupId;
    try {
      final membersFromDb =
          await DatabaseHelper.instance.getGroupMembersByGroupId(groupId!);
      print('Fetched members: $membersFromDb');
      setState(() {
        searchResultsList = membersFromDb;
      });
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveName(); // Call the function when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Add Existing Member',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by Unique Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          _searchForMember(_searchController.text);
                        },
                        label: const Text('Search'),
                        icon: const Icon(Icons.search),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 0, 103, 4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0))))
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (_searchMessage.isNotEmpty)
              Text(
                _searchMessage,
                style: const TextStyle(color: Colors.red),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResultsList.length,
                itemBuilder: (context, index) {
                  final member = searchResultsList[index];
                  return ListTile(
                    title: Text('${member['fname']} ${member['lname']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _addMember(member);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchForMember(String uniqueCode) async {
    final dynamic searchResults =
        await DatabaseHelper.instance.searchUserByUniqueCode(uniqueCode);
    print('Search results: $searchResults');

    if (searchResults is Map<String, dynamic>) {
      setState(() {
        searchResultsList = [searchResults];
        if (searchResults.isEmpty) {
          _searchMessage = 'No member found with the entered code.';
        } else {
          _searchMessage = '';
        }
      });
    } else {
      // Handle the case where the result is not as expected.
      // You may want to show an error message or take other appropriate actions.
    }
  }

  void _addMember(Map<String, dynamic> member) async {
    final int userId = member['id'];
    final int? groupId = widget.groupId;

    if (groupId != null) {
      // Check if the member is already in the group with the specified groupId
      final bool isMemberInGroup =
          await DatabaseHelper.instance.isMemberInGroup(userId, groupId);

      if (!isMemberInGroup) {
        final int result =
            await DatabaseHelper.instance.addMemberToGroup(userId, groupId);
        if (result > 0) {
          print(
              'Member ${member['fname']} ${member['lname']} with ID $userId added successfully to group $groupId');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Member ${member['fname']} ${member['lname']} with ID $userId added successfully to group $groupName with ID $groupId!'),
              duration: const Duration(seconds: 2),
            ),
          );

          // You can also refresh the list of group members after adding
          _fetchGroupMembers();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Member ${member['fname']} ${member['lname']} with ID $userId is already in the group with name $groupName!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group ID is null. Unable to add member.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

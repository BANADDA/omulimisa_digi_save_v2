// import 'package:flutter/material.dart';
// import '../../../../../../database/localStorage.dart';
// import '../../../../../../database/positions.dart';
// import '../../group_start.dart';

// class Member {
//   final int id;
//   final String? firstName; // Make 'firstName' nullable
//   final String? lastName; // Make 'lastName' nullable

//   Member(
//       {required this.id,
//       this.firstName,
//       this.lastName}); // Update the constructor

//   factory Member.fromMap(Map<String, dynamic> map) {
//     return Member(
//       id: map['id'],
//       firstName: map['fname'], // It's okay if 'first_name' is null
//       lastName: map['lname'], // It's okay if 'last_name' is null
//     );
//   }
// }

// class ElectOfficersScreen extends StatefulWidget {
//   final int? groupId;

//   const ElectOfficersScreen({super.key, this.groupId});
//   @override
//   _ElectOfficersScreenState createState() => _ElectOfficersScreenState();
// }

// class _ElectOfficersScreenState extends State<ElectOfficersScreen> {
//   List<Member> members = [];

//   @override
//   void initState() {
//     super.initState();
//     // Fetch the list of group members from your database

//     _fetchGroupMembers();

//     _fetchPositions();
//   }

//   void _fetchGroupMembers() async {
//     final int? groupId = widget.groupId;
//     try {
//       final membersFromDb =
//           await DatabaseHelper.instance.getGroupMembersByGroupId(groupId!);
//       print('Fetched members: $membersFromDb');
//       setState(() {
//         members = membersFromDb.map((map) => Member.fromMap(map)).toList();
//         print('$members');
//       });
//     } catch (e) {
//       print('Error fetching members: $e');
//     }
//   }

//   void _fetchPositions() async {
//     try {
//       List<String> positionsFromDb =
//           await DatabaseHelper.instance.getAllPositions();
//       print('Fetched positions: $positionsFromDb');

//       print('positions: $positionsFromDb');

//       // if (positionsFromDb.isEmpty) {
//       //   // If positions are empty, sync with the API
//       //   print('Here sync');
//       //   await syncpositionWithApi();

//       //   // Fetch positions again after syncing
//       //   positionsFromDb = await DatabaseHelper.instance.getAllPositions();
//       //   print('Fetched positions after sync: $positionsFromDb');
//       // }

//       setState(() {
//         selectedLeaders = positionsFromDb;
//       });
//     } catch (e) {
//       print('Error fetching positions: $e');
//     }
//   }

//   List<String> selectedLeaders = [];

//   // Function to add a new position
//   void addNewPosition(String newPositionName) async {
//     if (!selectedLeaders.contains(newPositionName)) {
//       // Insert the new position into the database
//       await DatabaseHelper.instance.insertPosition(newPositionName);
//       setState(() {
//         selectedLeaders.add(newPositionName); // Update the selectedLeaders list
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Position already exists.'),
//         ),
//       );
//     }
//   }

//   Future<void> showAddPositionDialog() async {
//     String? newPositionName = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add New Position'),
//           content: TextField(
//             controller: _positionController,
//             decoration: const InputDecoration(labelText: 'Position Name'),
//             onChanged: (value) {
//               // You can add validation or further logic here
//               // if needed.
//             },
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Add'),
//               onPressed: () {
//                 // Get the position name from the text field
//                 Navigator.of(context).pop(_positionController.text);
//               },
//             ),
//           ],
//         );
//       },
//     );

//     if (newPositionName != null && newPositionName.isNotEmpty) {
//       addNewPosition(newPositionName);
//     }
//   }

//   void removePosition(String positionName) async {
//     if (positionName != 'Chairman' && positionName != 'Secretary') {
//       print('Removing position: $positionName');
//       if (selectedLeaders.contains(positionName)) {
//         // Remove the position from the database
//         await DatabaseHelper.instance.removePosition(positionName);
//         setState(() {
//           selectedLeaders
//               .remove(positionName); // Update the selectedLeaders list
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Position removed successfully.'),
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cannot remove default positions.'),
//         ),
//       );
//     }
//   }

//   Member? selectedMember;
//   final TextEditingController _positionController = TextEditingController();

//   @override
//   void dispose() {
//     _positionController.dispose();
//     super.dispose();
//   }

//   Map<String, Member?> selectedMembers = {};

//   // Create a map to associate positions with members
//   Map<String, Member?> positionToMember = {};

//   // Function to check if a member is assigned to a position
//   bool _isMemberAssigned(int? memberId) {
//     return positionToMember.values.any((member) => member?.id == memberId);
//   }

//   // Helper function to get the position ID by name
//   Future<int?> getPositionIdByName(String positionName) async {
//     final db = await DatabaseHelper.instance.database;
//     final result = await db.rawQuery(
//       'SELECT id FROM positions WHERE name = ?',
//       [positionName],
//     );
//     if (result.isNotEmpty) {
//       return result.first['id'] as int;
//     }
//     return null;
//   }

//   void navigateToGroupStart() async {
//     final DatabaseHelper databaseHelper = DatabaseHelper.instance;
//     bool assignmentsSuccessful = false; // Flag to track successful assignments

//     try {
//       // Iterate through the positionToMember map
//       for (var entry in positionToMember.entries) {
//         final positionName = entry.key;
//         final selectedMember = entry.value;

//         if (selectedMember != null) {
//           final positionId = await getPositionIdByName(positionName);

//           if (positionId != null) {
//             final int? groupId = widget.groupId;
//             // Assign the member to the position in the database
//             await databaseHelper.assignPosition(
//                 positionId, selectedMember.id, groupId!);
//             print(
//                 'Assigned: ${selectedMember.firstName} ${selectedMember.lastName} (ID: ${selectedMember.id}) to $positionName (ID: $positionId) in group with ID: $groupId');

//             // Set the flag to true since at least one assignment was successful
//             assignmentsSuccessful = true;
//             setState(() {
//               officersSaved = true;
//             });
//           }
//         }
//       }
//       // After assignments, navigate to the GroupStart screen
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => const GroupStart(),
//         ),
//       );
//     } catch (e) {
//       // Handle any exceptions or errors that occur
//       print('Error in navigateToGroupStart: $e');
//       // You can display a message to the user or perform other error handling here
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 1, 67, 3),
//         title: const Text(
//           'Select Leaders',
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Column(
//                     children: [
//                       const ListTile(
//                         title: Text(
//                           'Select Leadership Positions for your group',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Color.fromARGB(255, 17, 0, 0),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         dense: true,
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 showAddPositionDialog();
//                               },
//                               style: TextButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 0, 103, 4),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(10.0))),
//                               child: const Text('Add New Position'),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       const Divider(),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Column(
//                         children: selectedLeaders.map((title) {
//                           Member? selectedMember = positionToMember[title];
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 title,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color.fromARGB(255, 1, 73, 3),
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   DropdownButton<Member?>(
//                                     value: selectedMember,
//                                     onChanged: (Member? member) {
//                                       setState(() {
//                                         if (!_isMemberAssigned(member?.id)) {
//                                           positionToMember[title] = member;
//                                         } else {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             const SnackBar(
//                                               content: Text(
//                                                 'This member is already assigned to another position.',
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       });
//                                     },
//                                     items: [
//                                       const DropdownMenuItem<Member?>(
//                                         value: null,
//                                         child: Text('Select Member'),
//                                       ),
//                                       for (Member? member in members)
//                                         DropdownMenuItem<Member?>(
//                                           value: member,
//                                           child: Text(
//                                             '${member?.firstName ?? 'Unknown'} ${member?.lastName ?? 'Unknown'}',
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete,
//                                     ),
//                                     onPressed: () {
//                                       removePosition(title);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           navigateToGroupStart();
//                         },
//                         style: TextButton.styleFrom(
//                             foregroundColor: Colors.white,
//                             backgroundColor:
//                                 const Color.fromARGB(255, 0, 103, 4),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0))),
//                         child: const Text('Submit Leader names'),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/localStorage.dart';
import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:omulimisa_digi_save_v2/src/view/accounts/groups/group_start.dart';
import 'package:sqflite/sqflite.dart';

class ElectOfficersScreen extends StatefulWidget {
  final int? groupId;

  ElectOfficersScreen({Key? key, this.groupId}) : super(key: key);

  @override
  _ElectOfficersScreenState createState() => _ElectOfficersScreenState();
}

class _ElectOfficersScreenState extends State<ElectOfficersScreen> {
  late Database db;
  List<Position> positions = [];
  late Map<int, Position?> selectedPositions =
      {}; // Map to store selected positions for each member
  List<GroupMember> groupMembers = [];
  List<AssignedPosition> assignedPositions = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadPositions();
    _loadGroupMembers(widget.groupId!);
  }

  void _initDatabase() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    db = await databaseHelper.database;
  }

  void _loadPositions() async {
    positions = await DatabaseHelper.instance.loadPositions();
    if (positions.isEmpty) {
      syncpositionWithApi();
      positions = await DatabaseHelper.instance.loadPositions();
      setState(() {});
    }
    setState(() {});
  }

  void _loadGroupMembers(int groupId) async {
    groupMembers = await DatabaseHelper.instance.loadGroupMembers(groupId);
    // Initialize selected positions for each member to null
    groupMembers.forEach((member) {
      selectedPositions[member.id] = null;
    });
    setState(() {});
  }

  void _saveAssignedPositions() async {
    bool assignmentsSuccessful = false;
    assignedPositions.clear();
    // Add assigned positions to the list
    selectedPositions.forEach((memberId, position) {
      if (position != null) {
        assignedPositions.add(AssignedPosition(
          positionId: position.name,
          memberId: memberId,
          groupId: groupMembers.firstWhere((m) => m.id == memberId).groupId,
        ));
      }
    });

    try {
      await DatabaseHelper.instance.saveAssignedPositions(assignedPositions);
      setState(() {
        selectedPositions.clear();
        groupMembers.forEach((member) {
          selectedPositions[member.id] = null;
        });
      });
      assignmentsSuccessful = true;

      setState(() {
        officersSaved = true;
      });

      // After assignments, navigate to the GroupStart screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GroupStart(),
        ),
      );
    } on Exception catch (e) {
      print('Error in positions assignment $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Positions'),
      ),
      body: Column(
        children: [
          DropdownButton<Position>(
            value: null,
            onChanged: null,
            items: positions.map((position) {
              return DropdownMenuItem<Position>(
                value: position,
                child: Text(position.name),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groupMembers.length,
              itemBuilder: (context, index) {
                final groupMember = groupMembers[index];
                return ListTile(
                  title: Text(groupMember.name),
                  trailing: DropdownButton<Position>(
                    value: selectedPositions[groupMember.id],
                    onChanged: (position) {
                      setState(() {
                        selectedPositions[groupMember.id] = position;
                      });
                    },
                    items: positions.map((position) {
                      return DropdownMenuItem<Position>(
                        value: position,
                        child: Text(position.name),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: _saveAssignedPositions,
              child: Text('Save'),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 1, 67, 3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)))),
        ],
      ),
    );
  }
}

class Position {
  final int id;
  final String name;

  Position({required this.id, required this.name});

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class GroupMember {
  final int id;
  final int userId;
  final int groupId;
  String name; // Include name property

  GroupMember({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.name,
  });

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      userId: map['user_id'],
      groupId: map['group_id'],
      name: '', // Initialize with an empty string
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      // 'name': name, // You might not store the name directly in the 'group_members' table
    };
  }
}

class AssignedPosition {
  final String positionId;
  final int memberId;
  final int groupId;

  AssignedPosition({
    required this.positionId,
    required this.memberId,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'position_name': positionId,
      'member_id': memberId,
      'group_id': groupId,
    };
  }
}

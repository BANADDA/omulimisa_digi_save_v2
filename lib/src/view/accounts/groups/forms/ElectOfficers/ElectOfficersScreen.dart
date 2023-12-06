import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/localStorage.dart';
import 'package:omulimisa_digi_save_v2/database/positions.dart';
import 'package:omulimisa_digi_save_v2/src/view/accounts/groups/group_start.dart';
import 'package:sqflite/sqflite.dart';

class ElectOfficersScreen extends StatefulWidget {
  final String? groupId;

  ElectOfficersScreen({Key? key, this.groupId}) : super(key: key);

  @override
  _ElectOfficersScreenState createState() => _ElectOfficersScreenState();
}

class _ElectOfficersScreenState extends State<ElectOfficersScreen> {
  late Database db;
  List<Position> positions = [];
  late Map<String, Position?> selectedPositions = {};
  List<GroupMember> groupMembers = [];
  List<AssignedPosition> assignedPositions = [];
  bool isLoadingPositions = true; // Track whether positions are being loaded

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
    setState(() {
      isLoadingPositions =
          true; // Set loading to true when positions start loading
    });
    positions = await DatabaseHelper.instance.loadPositions();
    if (positions.isEmpty) {
      await syncpositionWithApi();
      positions = await DatabaseHelper.instance.loadPositions();
    }
    setState(() {
      isLoadingPositions =
          false; // Set loading to false after positions are loaded
    });
  }

  void _loadGroupMembers(String groupId) async {
    groupMembers = await DatabaseHelper.instance.loadGroupMembers(groupId);
    groupMembers.forEach((member) {
      selectedPositions[member.id] = null;
    });
    setState(() {});
  }

  void _saveAssignedPositions() async {
    bool assignmentsSuccessful = false;
    assignedPositions.clear();
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
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assign Positions',
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
      body: isLoadingPositions
          ? Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator while fetching positions
            )
          : Column(
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class Position {
  final String id;
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
  final String id;
  final String userId;
  final String groupId;
  String name;

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
      name: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
    };
  }
}

class AssignedPosition {
  final String positionId;
  final String memberId;
  final String groupId;
  String? id;

  AssignedPosition({
    required this.positionId,
    required this.memberId,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position_name': positionId,
      'member_id': memberId,
      'group_id': groupId,
    };
  }
}

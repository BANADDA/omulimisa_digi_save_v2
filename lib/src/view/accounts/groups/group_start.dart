import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omulimisa_digi_save_v2/database/getData.dart';
import 'package:omulimisa_digi_save_v2/database/getMeetings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/view/accounts/groups/forms/groupProfile/group_profile.dart';
import '/src/view/screens/start_screen.dart';

import '../../../../database/localStorage.dart';
import 'forms/Contituition/constitution_screen.dart';
import 'forms/ElectOfficers/ElectOfficersScreen.dart';
import 'forms/MemberProfile/MemberProfilesScreen.dart';
import 'forms/Schedule/schedule_screen.dart';

class GroupStart extends StatefulWidget {
  final int? constituionId; // Add the ? to make the parameter nullable.
  const GroupStart({Key? key, this.constituionId}) : super(key: key);

  @override
  State<GroupStart> createState() => _GroupStartState();
}

bool groupProfileSaved = false;
bool constitutionSaved = false;
bool scheduleSaved = false;
bool membersSaved = false;
bool officersSaved = false;

bool allFormsCompleted = false; // Move this variable inside the class

class _GroupStartState extends State<GroupStart> {
  void updateAllFormsCompleted() {
    setState(() {
      allFormsCompleted = groupProfileSaved &&
          constitutionSaved &&
          scheduleSaved &&
          membersSaved &&
          officersSaved;
    });
  }

  String selectedProfile = "";
  String errorMessage = "";

  Future<int?> getGroupIdFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? groupId = sharedPreferences.getInt('groupid');
    return groupId;
  }

  Future<void> retrieveGroups() async {
    // Initialize your database and tables

    // Retrieve all group profiles
    List<Map<String, dynamic>> groupProfiles =
        await DatabaseHelper.instance.getAllGroupProfiles();
    // Now, you can iterate through the group profiles and access the 'id' field along with other fields.
    print('Group data: $groupProfiles');
    // for (Map<String, dynamic> groupProfile in groupProfiles) {
    //   int id = groupProfile['id'];
    //   String groupName = groupProfile['groupName'];
    //   String countryOfOrigin = groupProfile['countryOfOrigin'];
    //   String groupLogoPath = groupProfile[
    //       'groupLogoPath']; // Add this line to retrieve the groupLogoPath

    //   // ...

    //   // Process the data as needed
    //   print(
    //       'ID: $id, Group Name: $groupName, Country of Origin: $countryOfOrigin, Group Logo Path: $groupLogoPath');
    // }
  }

  Future<void> retrieveConst() async {
    // Initialize your database and tables

    // Retrieve all group profiles with constitution data
    List<Map<String, dynamic>> profilesWithConstitution =
        await DatabaseHelper.instance.getAllGroupProfilesWithConstitution();

    // Now, you can iterate through the results and print all fields from both tables.
    for (Map<String, dynamic> row in profilesWithConstitution) {
      print('Group Profile:');
      row.forEach((key, value) {
        print('$key: $value');
      });
      print('\n');
    }
  }

  Future<void> retrieveCycle() async {
    // Initialize your database and tables

    // Retrieve all group profiles with constitution data
    List<Map<String, dynamic>> profilesWithConstitution =
        await DatabaseHelper.instance.getAllGroupProfilesWithConstitution();

    // Retrieve all cycle schedules
    List<Map<String, dynamic>> cycleSchedules =
        await DatabaseHelper.instance.getAllCycleSchedules();

    // Now, you can iterate through and print data from both tables.
    print('Group Profiles with Constitution:');
    for (Map<String, dynamic> row in profilesWithConstitution) {
      print('Row:');
      row.forEach((key, value) {
        print('$key: $value');
      });
      print('\n');
    }

    print('Cycle Schedules:');
    for (Map<String, dynamic> row in cycleSchedules) {
      print('Row:');
      row.forEach((key, value) {
        print('$key: $value');
      });
      print('\n');
    }
  }

  Future<void> retriveGroupMembers() async {
    // Initialize your database and tables

    // Retrieve all group members
    List<Map<String, dynamic>> groupMembers =
        await DatabaseHelper.instance.retAllGroupMembers();

    // Create a map to group members by their groups
    Map<int, List<Map<String, dynamic>>> groupedMembers = {};

    // Iterate through the group members and group them by their group IDs
    for (Map<String, dynamic> row in groupMembers) {
      int groupId = row['group_id'];

      // Initialize an empty list for the group if it doesn't exist in the map
      groupedMembers.putIfAbsent(groupId, () => []);

      // Add the member to the corresponding group
      groupedMembers[groupId]!.add(row);
    }

    // Now, you can iterate through the grouped members and print them by group.
    for (int groupId in groupedMembers.keys) {
      print('Group ID: $groupId');
      List<Map<String, dynamic>> members = groupedMembers[groupId]!;

      for (Map<String, dynamic> member in members) {
        print('Member:');
        member.forEach((key, value) {
          print('$key: $value');
        });
        print('\n');
      }
    }
  }

  Future<void> retriveAssigned() async {
    // Initialize your database and tables

    // Retrieve all group members
    List<Map<String, dynamic>> groupMembers =
        await DatabaseHelper.instance.getAllGroupMembers();

    // Retrieve all assigned positions
    List<Map<String, dynamic>> assignedPositions =
        await DatabaseHelper.instance.getAllAssignedPositions();

    // Create a map to group assigned positions by group
    Map<int, Map<String, dynamic>> groupedPositions = {};

    // Iterate through the assigned positions and group them by group ID
    for (Map<String, dynamic> position in assignedPositions) {
      int groupId = position['group_id'];

      // Initialize an inner map for the group if it doesn't exist in the outer map
      groupedPositions.putIfAbsent(groupId, () => {});

      // Add the position to the corresponding group's inner map
      groupedPositions[groupId]![position['id'].toString()] = position;
    }

    // Now, you can iterate through the grouped positions and print them by group.
    for (int groupId in groupedPositions.keys) {
      print('Group ID: $groupId');
      Map<String, dynamic> positionsInGroup = groupedPositions[groupId]!;

      for (String positionId in positionsInGroup.keys) {
        print('Position ID: $positionId');
        Map<String, dynamic> position = positionsInGroup[positionId]!;

        print('Position Details:');
        position.forEach((key, value) {
          print('$key: $value');
        });
        print('\n');
      }
    }
  }

  double? registrationFee = 0.0;
  List<int> userIDs = [];
  int? groupProfileId = 0;

  Future<void> IDs() async {
    try {
      // Retrieve the necessary data from your form or other sources
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? groupId = sharedPreferences.getInt('groupid');
      groupProfileId =
          await DatabaseHelper.instance.getGroupProfileId(groupId!);
      int? constitutionId =
          await DatabaseHelper.instance.getConstitutionId(groupId);
      int? cycleScheduleId =
          await DatabaseHelper.instance.getCycleScheduleId(groupId);
      int? groupMemberId =
          await DatabaseHelper.instance.getGroupMemberId(groupId);
      int? assignedPositionId =
          await DatabaseHelper.instance.getAssignedPositionId(groupId);
      print('Constituiton Id: $constitutionId');
      registrationFee =
          await DatabaseHelper.instance.getRegistrationFee(constitutionId!);

      if (registrationFee != null) {
        print('Registration Fee: $registrationFee');
      } else {
        print('No registration fee found for Constitution ID: $constitutionId');
      }

      userIDs = await DatabaseHelper.instance
          .getUserIdsForGroupProfile(groupProfileId!);

      if (userIDs.isNotEmpty) {
        print('User IDs for Group Profile ID $groupProfileId: $userIDs');
      } else {
        print('No user IDs found for Group Profile ID: $groupProfileId');
      }
    } catch (e) {
      // Handle any exceptions that may occur during data retrieval or insertion
      print('Error during form submission: $e');
      // You can show an error message to the user if needed
    }
  }

  Future<void> handleFormSubmission() async {
    try {
      // Retrieve the necessary data from your form or other sources
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      int? groupId = sharedPreferences.getInt('groupid');
      int? groupProfileId =
          await DatabaseHelper.instance.getGroupProfileId(groupId!);
      int? constitutionId =
          await DatabaseHelper.instance.getConstitutionId(groupId);
      int? cycleScheduleId =
          await DatabaseHelper.instance.getCycleScheduleId(groupId);
      int? groupMemberId =
          await DatabaseHelper.instance.getGroupMemberId(groupId);
      int? assignedPositionId =
          await DatabaseHelper.instance.getAssignedPositionId(groupId);
      final prefs = await SharedPreferences.getInstance();

      int loggedInUserId = prefs.getInt('userId') ?? -1;
      // Insert the data into the linked_data table
      int? insertedRowId = await DatabaseHelper.instance.insertLinkedData(
        groupId,
        loggedInUserId,
        groupProfileId,
        constitutionId,
        cycleScheduleId,
        groupMemberId,
        assignedPositionId,
      );

      if (insertedRowId != null) {
        // Data inserted successfully, navigate to the next screen
        print(
            'Data inserted into linked_data table with row ID: $insertedRowId');

        if (userIDs.isNotEmpty) {
          for (int userId in userIDs) {
            Map<String, dynamic> groupFeeData = {
              'member_id': userId,
              'group_id': insertedRowId,
              'registration_fee': registrationFee,
            };

            // Now you can use groupFeeData to insert the registration fee for each user
            int result =
                await DatabaseHelper.instance.insertGroupFee(groupFeeData);

            if (result != 0) {
              print('Registration Fee assigned for User ID $userId');
            } else {
              print('Failed to assign Registration Fee for User ID $userId');
            }
          }

          final int? groupProfileId =
              await DatabaseHelper.instance.getGroupProfileId(groupId);

          if (groupProfileId != -1) {
            print('Group Profile ID: $groupProfileId');
            final Map<String, dynamic> fundsPresent =
                await DatabaseHelper.instance.areFundsPresent(groupProfileId!);
            print('Funds Present: ${fundsPresent['socialFund']}');

            if (fundsPresent['socialFund'] != null ||
                fundsPresent['loanFund'] != null) {
              print('Either socialFund or loanFund is present.');

              int removeCommasAndConvertToInt(String text) {
                final withoutCommas = text.replaceAll(',', '');
                return int.parse(withoutCommas);
              }

              final String? socialFund = fundsPresent['socialFund'];
              final String? loanFund = fundsPresent['loanFund'];

              int socialFundAmount = removeCommasAndConvertToInt(socialFund!);
              int loanFundAmount = removeCommasAndConvertToInt(loanFund!);

              print('Funds: $socialFundAmount and $loanFundAmount');
              final int insertedCycleData = await DatabaseHelper.instance
                  .insertFundsIntoCycleMeeting(
                      groupId, socialFundAmount, loanFundAmount);
              if (insertedCycleData != null) {
                print('Inserted row ID: $insertedCycleData');

                // Update the 'is_cycle_started' field in the 'group_cycle_status' table
                bool isCycleStarted = true;
                await DatabaseHelper.instance
                    .insertGroupCycleStatus(groupId, true, insertedCycleData);
                await DatabaseHelper.instance
                    .updateGroupCycleStatus(groupId, insertedCycleData, true);

                final activeCycle = {
                  'group_id': groupId,
                  'cycleMeetingID': insertedCycleData,
                };

                int activeCycleMeetingID = await DatabaseHelper.instance
                    .insertActiveCycleMeeting(activeCycle);

                // await DatabaseHelper.instance
                //     .insertActiveCycleMeeting(insertedCycleData);
                double totalFees = await DatabaseHelper.instance
                    .getTotalRegistrationFeesForGroup(insertedRowId);

                print(
                    'Total Registration Fees for Group $insertedRowId: $totalFees');
                // Savings Account
                String formatDateWithoutTime(DateTime dateTime) {
                  final formatter =
                      DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
                  return formatter.format(dateTime);
                }

                String dateWithoutTime =
                    formatDateWithoutTime(DateTime.now().toLocal());

                double totalSavings = loanFundAmount + totalFees;

                final prefs = await SharedPreferences.getInstance();
                final loggedInUserId = prefs.getInt('userId');
                final deductionData = {
                  'group_id': groupId,
                  'logged_in_user_id': loggedInUserId,
                  'date': dateWithoutTime,
                  'purpose': 'Share Purchase',
                  'amount': totalSavings,
                };
                final Savings = await DatabaseHelper.instance
                    .insertSavingsAccount(deductionData);
                print('Savings Account Inserted for $Savings: $deductionData');
                if (Savings != 0) {
                  print(
                      'Savings data inserted successfully with ID: $Savings.');
                  print('Savings data: $deductionData.');

                  // Clear shared preferences data
                  sharedPreferences.remove('groupid');
                  // Navigate to the next screen (replace with the actual screen you want to navigate to)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const StartScreen()), // Replace NextScreen with your desired screen
                  );
                } else {
                  print('Error inserting data into cyclemeeting.');
                }
              } else {
                print('Group Form ID not found or an error occurred.');
              }
            } else {
              print(
                  'Neither socialFund nor loanFund is present or an error occurred.');
              // await DatabaseHelper.instance
              //     .insertGroupCycleStatus(groupId, false,);
              double totalFees = await DatabaseHelper.instance
                  .getTotalRegistrationFeesForGroup(insertedRowId);

              print(
                  'Total Registration Fees for Group $insertedRowId: $totalFees');
              // Savings Account
              String formatDateWithoutTime(DateTime dateTime) {
                final formatter =
                    DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
                return formatter.format(dateTime);
              }

              String dateWithoutTime =
                  formatDateWithoutTime(DateTime.now().toLocal());

              final prefs = await SharedPreferences.getInstance();
              final loggedInUserId = prefs.getInt('userId');
              final deductionData = {
                'group_id': groupId,
                'logged_in_user_id': loggedInUserId,
                'date': dateWithoutTime,
                'purpose': 'Registration Fees',
                'amount': totalFees,
              };
              final Savings = await DatabaseHelper.instance
                  .insertSavingsAccount(deductionData);
              print('Savings Account Inserted for $Savings: $deductionData');
              if (Savings != 0) {
                print('Savings data inserted successfully with ID: $Savings.');
                print('Savings data: $deductionData.');

                // Clear shared preferences data
                sharedPreferences.remove('groupid');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                );
              } else {
                print('Error inserting data into cyclemeeting.');
              }
            }
          } else {
            print('Failed to insert savings data.');
          }
        } else {
          print('No user IDs found for Group Profile ID: $groupProfileId');
        }

        bool cycle = await DatabaseHelper.instance.getGroupCycleStatus(groupId);
        print('Cycle started boolean: $cycle');
      } else {
        // Handle the case where data insertion fails
        print('Failed to insert data into linked_data table');
        // You can show an error message to the user if needed
      }
    } catch (e) {
      // Handle any exceptions that may occur during data retrieval or insertion
      print('Error during form submission: $e');
      // You can show an error message to the user if needed
    }
  }

  @override
  void initState() {
    super.initState();
    updateAllFormsCompleted();
    retrieveGroups();
    IDs();
    // retrieveConst();
    // retrieveCycle();
    // retriveGroupMembers();
    // retriveAssigned();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the groupId from shared preferences
    getGroupIdFromSharedPreferences().then((int? groupId) {
      if (groupId != null) {
        // Use the groupId as needed
        // print('Group ID from SharedPreferences Start SREEN: $groupId');
      } else {
        print('Error');
      }
    });
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 244, 255, 233),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          leading: IconButton(
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              // Show a confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Cancel Submission?"),
                    content: const Text(
                        "Are you sure you want to cancel the submission? Any unsaved changes will be lost."),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("No"), // Continue with the submission
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text(
                            "Yes"), // Cancel the submission and navigate to the start screen
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StartScreen(), // Replace with your desired screen
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          automaticallyImplyLeading: true,
          toolbarHeight: 50,
          elevation: 0.0,
        ),
        body: FutureBuilder(
            future: getGroupIdFromSharedPreferences(),
            builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Handle the case where the future is still running
                return const CircularProgressIndicator(); // Or any other loading indicator
              } else if (snapshot.hasError) {
                // Handle errors
                return Text('Error: ${snapshot.error}');
              } else {
                // Successfully retrieved the groupId
                int? groupId = snapshot.data;
                if (groupId != null) {
                  // Use the groupId as needed
                  print('Group ID from SharedPreferences: $groupId');
                } else {
                  print('Error: Group ID is null');
                }
                return SingleChildScrollView(
                  child: WillPopScope(
                    onWillPop: () async {
                      // Check the flag of the current section and prevent navigation if saved
                      if (constitutionSaved ||
                          scheduleSaved ||
                          membersSaved ||
                          officersSaved) {
                        return false; // Block back navigation
                      }
                      return true; // Allow back navigation
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 1, 67, 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 11, 0, 0)
                                      .withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Let's get started, create your new community group today 🙂",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildGroupProfile(
                                    "Group Profile",
                                    const GroupProfile(),
                                    groupProfileSaved,
                                    true,
                                    ""), // No prerequisite for Group Profile
                                _buildGroupProfile(
                                    "Constitution",
                                    Constitution(groupId: groupId),
                                    constitutionSaved,
                                    groupProfileSaved,
                                    "Group Profile"),
                                _buildGroupProfile(
                                    "Cycle Schedule",
                                    ScheduleScreen(
                                      groupId: groupId,
                                    ),
                                    scheduleSaved,
                                    constitutionSaved,
                                    "Constitution"),
                                _buildGroupProfile(
                                    "Add Members",
                                    MemberProfilesScreen(groupId: groupId),
                                    membersSaved,
                                    scheduleSaved,
                                    "Cycle Schedule"),
                                _buildGroupProfile(
                                    "Elect Officers",
                                    ElectOfficersScreen(groupId: groupId),
                                    officersSaved,
                                    membersSaved,
                                    "Add Members"),

                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (allFormsCompleted) {
                                print('Submitting');
                                handleFormSubmission(); // Call the form submission method when all forms are completed
                              } else {
                                // Handle the case where not all forms are completed, e.g., show an error message
                                _showErrorDialog("Error", " all forms");
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: allFormsCompleted
                                  ? const Color.fromARGB(255, 0, 103, 4)
                                  : Colors
                                      .grey, // Disable the button if not all forms are completed
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Submit Forms'),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Divider(),
                          GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    'Contact Support Team',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 1, 67, 3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }));
  }

  Widget _buildGroupProfile(String text, Widget route, bool isSaved,
      bool isAllowed, String prerequisiteSection) {
    return InkWell(
      onTap: () {
        // Allow navigation to Group Profile without any prerequisites
        if (isAllowed) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        } else {
          // For other sections, check if the section data has been saved and if it's allowed to navigate
          if (isSaved) {
            final result = Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => route),
            );
            // Do something with the returned data.
            print('Returned data: $result');
          } else {
            // Show an error dialog indicating that the prerequisite section needs to be completed first
            _showErrorDialog(text, prerequisiteSection);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 167, 6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          trailing: Checkbox(
            value: isSaved, // Use the appropriate boolean variable here
            onChanged: null, // Make the checkbox non-interactive
            activeColor: const Color.fromARGB(255, 1, 67, 3),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String sectionName, String prerequisiteSection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("Please complete $prerequisiteSection"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

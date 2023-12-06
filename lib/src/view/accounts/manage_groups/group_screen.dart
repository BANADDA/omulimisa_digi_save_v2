import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omulimisa_digi_save_v2/database/userData.dart';
import 'package:omulimisa_digi_save_v2/src/view/accounts/manage_groups/dashbord.dart';
import 'package:omulimisa_digi_save_v2/src/view/widgets/user_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '/src/view/accounts/manage_groups/Loans/loan_status.dart';
import '/src/view/accounts/manage_groups/meetings/StartCycle/start_cycle.dart';
import '/src/view/accounts/manage_groups/meetings/end_cycle/analysis/theme/colors.dart';
import '/src/view/accounts/manage_groups/meetings/start_meeting/start_meeting.dart';
import '/src/view/accounts/manage_groups/meetings/view_meetings.dart';
import '../../../../database/localStorage.dart';
import '../../models/custom_card.dart';
import '../../models/dashboard_data.dart';
import '../../models/financial_card.dart';
import '../../widgets/custom_tile.dart';
import 'Member_Details/membership_summary.dart';
import 'meetings/end_cycle/endMeetingCycle.dart';
import 'meetings/meetings_page.dart';

class GroupLeader {
  final String groupMemberId;
  final String leaderName;
  final String assignedPosition;

  GroupLeader({
    required this.groupMemberId,
    required this.leaderName,
    required this.assignedPosition,
  });
}

class GroupDashboard extends StatefulWidget {
  final groupName;
  final String? groupId;

  const GroupDashboard({Key? key, this.groupName, this.groupId})
      : super(key: key);

  @override
  _GroupDashboardState createState() => _GroupDashboardState();
}

class _GroupDashboardState extends State<GroupDashboard> {
  Uint8List? _bytesImage;

  String? group_Id;

  Future<void> getGroupIdForFormId(String formId) async {
    group_Id = (await DatabaseHelper.instance.getGroupIdFromFormId(formId));
    if (group_Id != null) {
    fetchMembersAndPositions(group_Id!);
      print('The group ID associated with form $formId is $group_Id');
    } else {
      print('No group found for form $formId');
    }
  }

  List<Map<String, dynamic>>? memberAndPositionData;
  Future<void> fetchMemberAndPositionData(String groupId) async {
    String currentPositionName;
    memberAndPositionData =
        await DatabaseHelper.instance.getMemberAndPositionNames(groupId);
    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getString('userId');
    print('Logged i n User: $loggedInUserId');
    final currentUserId =
        await DatabaseHelper.instance.getGroupUserId(groupId, loggedInUserId!);
    print('Current User Id: $currentUserId');
    if (memberAndPositionData != null) {
      // Process the data here
      for (var row in memberAndPositionData!) {
        final memberId = row['member_id'];
        final userId = row['user_id'];
        final positionName = row['position_name'];
        final positionId = row['position_id'];
        final firstName = row['fname'];
        final lastName = row['lname'];

        print('Member ID: $memberId');
        print('User ID: $userId');
        print('Position Name: $positionName');
        print('Position Id: $positionId');
        print('First Name: $firstName');
        print('Last Name: $lastName');
        currentPositionName = positionName;
        print('Current User Position Id: $currentPositionName');
      }

      setState(() {});
    } else {
      print('No data found for group $groupId');
    }
  }

  Map<String, dynamic>? cycleScheduleInfo;
  String? meetingId;
  String? cycleId;

  bool? cycleStarted;
  String? normalMeetingId;

  Future<String?> isCycleStarted(String groupId) async {
    final databaseHelper = DatabaseHelper.instance;
    final cycleStarted = await databaseHelper.isCycleStarted(groupId);

    if (cycleStarted != null) {
      print('Cycle has started for the group.');
      print('Active Cycle Meeting ID: $cycleStarted');

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Map<String, dynamic> meetingData = {
        'group_id': widget.groupId,
        'date': currentDate,
      };
      normalMeetingId =
          await DatabaseHelper.instance.insertMeeting(meetingData);
      print('Normal Meeting Data Saved: $normalMeetingId');

      return cycleStarted; // Return the cycle ID.
    } else {
      print('Cycle has not started for the group.');
      return null; // Default to returning null if no cycle has started.
    }
  }

  Future<void> NavigatorStartMeeting() async {
    // Use a loading flag to track whether the data is being loaded.
    bool isLoading = true;

    // Check if the cycle has started.
    final String? cycleId = await isCycleStarted(widget.groupId!);

    if (cycleId != null) {
      // Data loading is complete.
      isLoading = false;

      if (cycleId != null) {
        // Cycle has started.
        // Navigate to the StartMeeting screen.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StartMeeting(
              groupId: widget.groupId!,
              groupName: widget.groupName,
              meetingId:
                  normalMeetingId ?? '', // Provide a default value if it's null
            ),
          ),
        );
      } else {
        // Cycle has not started.
        // Display a message to the user.
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cycle has not started yet'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    if (isLoading) {
      // Show a CircularProgressIndicator while loading.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CircularProgressIndicator(),
          );
        },
      );
    }
  }

  void NavigatorScheduledMeetingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScheduledMeetingsScreen(),
      ),
    );
  }

  void NavigatorStartCycle() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => StartCycle(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> memberData = [];

  void fetchMembersAndPositions(String groupProfileId) async {
    memberData =
        await DatabaseHelper.instance.getMemberIdsForGroup(groupProfileId);
    print('Group members: $memberData');
    setState(() {
      memberData = memberData;
    });
  }

  Future<String> fetchMemberName(String groupMemberId) async {
    Map<String, dynamic> memberNameData =
        await DatabaseHelper.instance.getMemberName(groupMemberId);
    print('Member data; $memberNameData');

    // if (memberNameData.isNotEmpty) {
    String firstName = memberNameData['fname'] ?? '';
    String lastName = memberNameData['lname'] ?? '';
    String leaderName = '$firstName $lastName';

    return leaderName; // Return the combined name
    // }
    // else {
    // syncUserDataWithApi();
    // Map<String, dynamic> memberNameData =
    //     await DatabaseHelper.instance.getMemberName(groupMemberId);
    // String firstName = memberNameData['fname'] ?? '';
    // String lastName = memberNameData['lname'] ?? '';
    // String leaderName = '$firstName $lastName';

    // return leaderName;
    // }
  }

  void NavigatorEndCycle() {
    // Navigate to the EndCycle screen
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EndCycle(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    )
        .then((value) {
      // Use the returned meetingId value
      print('Meeting ID: $value');
      setState(() {
        meetingId = value;
      });
    });
  }

  void showEndCycleConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [Text('Warning')],
          ),
          content: const Text('Are you sure you want to end your group cycle?'),
          actions: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(
                  width: 15,
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    // Navigator.of(context).pop(); // Close the dialog
                    NavigatorEndCycle(); // End the cycle
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void NavigatorViewMeeting() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MeetingsScreen(),
      ),
    );
  }

  int selectedTabIndex = 0; // Initialize with the first tab selected

  final PageController _pageController = PageController(initialPage: 0);
  List<String> tabTitles = ["Dashboard", "Meetings", "Group Setup"];
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  final List<Map<String, String>> financialData = [
    {
      'label': FinancialData.totalSavingsText,
      'value': currencyFormat.format(FinancialData.totalSavingsValue),
    },
    {
      'label': FinancialData.outstandingLoansText,
      'value': currencyFormat.format(FinancialData.outstandingLoansValue),
    },
    {
      'label': FinancialData.loanRepaymentsText,
      'value': currencyFormat.format(FinancialData.loanRepaymentsValue),
    },
    {
      'label': FinancialData.interestsEarnedText,
      'value': currencyFormat.format(FinancialData.interestsEarnedValue),
    },
    {
      'label': FinancialData.groupBusinessFundsText,
      'value': currencyFormat.format(FinancialData.groupBusinessFundsValue),
    },
  ];

  final int totalValue = FinancialData.totalSavingsValue +
      FinancialData.outstandingLoansValue +
      FinancialData.loanRepaymentsValue +
      FinancialData.interestsEarnedValue +
      FinancialData.groupBusinessFundsValue;

  void onTabPressed(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  bool isContentVisible = false;

  void toggleContentVisibility() {
    setState(() {
      isContentVisible = !isContentVisible;
    });
  }

  Widget buildTab(String text, int index) {
    return GestureDetector(
      onTap: () => onTabPressed(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white, // Line color
              width: selectedTabIndex == index ? 3.0 : 0.0, // Line thickness
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 5), // Adjust the vertical padding here
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: selectedTabIndex == index ? Colors.white : Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFinancialItem(String text, String value) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(value),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Future<Uint8List?> getImageForMember() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userId = prefs.getInt('userId');
  //     print('User Id Member: $userId');
  //     final imageData =
  //         await DatabaseHelper.instance.getImagePathForMember(userId!);
  //     print('Image path Member: $imageData');

  //     if (imageData != null) {
  //       _bytesImage = const Base64Decoder().convert(imageData);
  //       return _bytesImage;
  //     }

  //     return null; // Return null if imageData is null.
  //   } catch (e) {
  //     print('Error: $e');
  //     return null; // Return null in case of an error.
  //   }
  // }

  double groupSavings = 0.0;
  double activeLoansDetails = 0.0;

  double totalGroupSavings = 0;

  Future<void> fetchGroupAccounts() async {
    // Fetch Total Savings
    totalGroupSavings =
    await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId!);
    print('New Savings: UGX $totalGroupSavings');

    // Fetch active loans
    activeLoansDetails = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId!);
    print('Total Active Loan Amount: UGX $activeLoansDetails');

    // Update UI after fetching values
    setState(() {});
  }

  Widget buildContent(int index) {
    // Function to get the user's name from SharedPreferences
    Future<String?> getUserName() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final firstName = prefs.getString('userFirstName');
      final lastName = prefs.getString('userLastName');
      print('User name: $firstName $lastName');
      if (firstName != null && lastName != null) {
        return '$firstName $lastName';
      }
      return null;
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 0,
    );

    switch (selectedTabIndex) {
      case 0:
        return SingleChildScrollView(
            child: Container(
                child: Column(children: [
          FutureBuilder(
            future: getUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final userName = snapshot.data;

                return ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Container(
                      height: 90,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 1, 67, 3),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      alignment: Alignment.center,
                      // decoration: BoxDecoration(
                      //   color: Color.fromARGB(255, 1, 67, 3),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color:
                      //           Color.fromARGB(255, 11, 0, 0).withOpacity(0.5),
                      //       spreadRadius: 5,
                      //       blurRadius: 7,
                      //       offset: Offset(0, 3),
                      //     ),
                      //   ],
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Column(
                                    children: [
                                      Text(
                                        'Logged In as: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // CircleAvatar(
                                      //   radius: 20,
                                      //   backgroundImage: MemoryImage(_bytesImage ??
                                      //       Uint8List(
                                      //           0)), // Use MemoryImage to display Uint8List
                                      // ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          Text(
                                            userName ?? 'Unknown User',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          // Text(
                                          //   'example@gmail.com',
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     color: Colors.white,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              children: [
                FinancialCard(
                    header: 'Group Savings', formattedSavings: totalGroupSavings),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 180,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(60.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(60.0),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 114, 226, 118)
                                    .withOpacity(0.5),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 20,
                                    bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.attach_money_outlined,
                                      color: Color.fromARGB(255, 0, 196, 7),
                                      size: 35,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Column(children: [
                                        Text(
                                          'WellFair Fund',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color:
                                                Color.fromARGB(255, 0, 31, 1),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'UGX 2,000,000',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 0, 139, 5),
                                          ),
                                        )
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 180,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(60.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(60.0),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 247, 129, 129)
                                    .withOpacity(0.5),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 20,
                                    bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.credit_score_outlined,
                                      color: Color.fromARGB(255, 196, 29, 0),
                                      size: 35,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Column(children: [
                                        const Text(
                                          'Loan Amount',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color:
                                                Color.fromARGB(255, 0, 31, 1),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          currencyFormat
                                              .format(activeLoansDetails),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 134, 9, 0),
                                          ),
                                        )
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  title: 'Group Management',
                  items: const [
                    {
                      'label': 'Group Membership',
                      'description':
                          'Provides a summary of members in the group, and gives an option of adding more members',
                      'route': '/membership_summary',
                    },
                    {
                      'label': 'Loan Eligibility',
                      'description':
                          'Provides a list of members and the amount of loan balance they are eligible for',
                      'route': '/loan_eligibility',
                    },
                    {
                      'label': 'Loan Status',
                      'description':
                          'Provides a list of members who have taken loan, their loan balance, and how much they have paid ( status of loan completion )',
                      'route': '/loan_status',
                    },
                  ],
                  onTap: (route, groupId, groupName) {
                    if (route == '/membership_summary') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembershipSummaryScreen(
                            groupId: groupId,
                            groupName: groupName,
                            refreshCallback: () {},
                          ),
                        ),
                      );
                    } else if (route == '/membership_details') {
                      // Handle membership details screen with groupId and groupName
                    } else if (route == '/loan_eligibility') {
                      // Handle loan eligibility screen with groupId and groupName
                    } else if (route == '/loan_status') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoanStatus(
                            groupId: groupId,
                            groupName: groupName,
                          ),
                        ),
                      );
                    }
                  },
                  groupId: widget.groupId!, // Pass the groupId to CustomCard
                  groupName:
                      widget.groupName, // Pass the groupName to CustomCard
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 1, 67, 3),
                              ),
                              // ignore: prefer_const_constructors
                              margin: const EdgeInsets.only(
                                  top: 0, left: 0, right: 0),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Group Transactions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  CustomListTile(
                                    title: 'Savings Deposit',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomListTile(
                                    title: 'WellFair Deposit',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomListTile(
                                    title: 'Loan Application',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomListTile(
                                    title: 'Loan Payments',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomListTile(
                                    title: 'Social Fund Application',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomListTile(
                                    title: 'Social Fund Payments',
                                    onTap: () {
                                      // Your custom onTap logic here
                                    },
                                  )
                                ],
                              ),
                            )
                          ]))
                ]),
                const SizedBox(
                  height: 20,
                ),
                // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //   Padding(
                //       padding: const EdgeInsets.all(0),
                //       child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Container(
                //               decoration: const BoxDecoration(
                //                 color: Color.fromARGB(255, 1, 67, 3),
                //               ),
                //               // ignore: prefer_const_constructors
                //               margin: const EdgeInsets.only(
                //                   top: 0, left: 0, right: 0),
                //               padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                //               child: const Align(
                //                 alignment: Alignment.center,
                //                 child: Padding(
                //                   padding: EdgeInsets.all(20),
                //                   child: Text(
                //                     'Group Leaders',
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 16,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             const SizedBox(
                //               height: 15,
                //             ),
                //             SingleChildScrollView(
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: memberData.map((member) {
                //                   final memberId = member['member_id'];
                //                   print('Member Id: $memberId');
                //                   final position = member['position_name'];

                //                   return FutureBuilder<String>(
                //                     future: fetchMemberName(memberId),
                //                     builder: (context, snapshot) {
                //                       if (snapshot.connectionState ==
                //                           ConnectionState.waiting) {
                //                         return CircularProgressIndicator(); // Display a loading indicator while fetching data
                //                       } else if (snapshot.hasError) {
                //                         return Text(
                //                             'Error fetching name'); // Display an error message if fetching fails
                //                       } else {
                //                         final name = snapshot.data ??
                //                             ''; // Retrieve the fetched name from the snapshot

                //                         return Padding(
                //                           padding: EdgeInsets.symmetric(
                //                               vertical: 8.0, horizontal: 16.0),
                //                           child: Column(
                //                             crossAxisAlignment:
                //                                 CrossAxisAlignment.start,
                //                             children: [
                //                               Text(
                //                                 name.isNotEmpty
                //                                     ? name
                //                                     : 'Name not available',
                //                                 style: TextStyle(
                //                                     fontSize: 18.0,
                //                                     fontWeight:
                //                                         FontWeight.bold),
                //                               ),
                //                               SizedBox(height: 4.0),
                //                               Text(
                //                                 'Position: $position',
                //                                 style:
                //                                     TextStyle(fontSize: 16.0),
                //                               ),
                //                               Divider(), // Adding a divider between entries
                //                             ],
                //                           ),
                //                         );
                //                       }
                //                     },
                //                   );
                //                 }).toList(),
                //               ),
                //             ),
                //           ]))
                // ]),
                // const SizedBox(
                //   height: 10,
                // ),
                const Divider(),
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
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color.fromARGB(255, 1, 67, 3),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Contact Support Team',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 1, 67, 3),
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
                const SizedBox(
                  height: 5,
                ),
                const Divider(),
              ],
            ),
          )
        ])));

      case 1:
        return SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.ads_click_sharp, color: Colors.blue),
                          TextButton(
                            onPressed: () {
                              NavigatorViewMeeting();
                            },
                            child: const Text(
                              'View Previous Meetings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Click to view minutes from previous meetings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.ads_click_sharp, color: Colors.blue),
                          TextButton(
                            onPressed: () {
                              NavigatorScheduledMeetingsScreen();
                            },
                            child: const Text(
                              'Schedule Meetings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Click button to be able to schedule future meetings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Divider(),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the buttons horizontally
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align the buttons to the top vertically
                          children: [
                            FutureBuilder<bool>(
                              future: DatabaseHelper.instance
                                  .getGroupCycleStatus(widget.groupId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // or any loading widget you prefer
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  final isCycleStarted = snapshot.data;

                                  return Visibility(
                                    visible: isCycleStarted ==
                                        true, // Display when the cycle is started
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 145,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              NavigatorStartMeeting();
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 0, 103, 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                            child: const Text(
                                              'Start Meeting',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: 145,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showEndCycleConfirmation(context);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 0, 103, 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                            child: const Text(
                                              'End Cycle',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox
                                      .shrink(); // Hide the buttons until data is fetched
                                }
                              },
                            ),
                            FutureBuilder<bool>(
                              future: DatabaseHelper.instance
                                  .getGroupCycleStatus(widget
                                      .groupId!), // Replace 'groupId' with the actual group ID
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // If the future is still waiting, you can show a loading indicator.
                                  return const CircularProgressIndicator(); // or any loading widget you prefer
                                } else if (snapshot.hasError) {
                                  // Handle errors, for example, display an error message.
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  final isCycleStarted = snapshot.data;

                                  return Visibility(
                                    visible: isCycleStarted ==
                                        false, // Display when the cycle is not started
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            NavigatorStartCycle();
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 0, 103, 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          child: const Text(
                                            'Start Cycle',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox
                                      .shrink(); // Hide the button until data is fetched
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  //
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
            ],
          ),
        ));
      case 2:
        return Container(
          child: const Column(
            children: [Text('Group Setup content')],
          ),
        );
      default:
        return Container();
    }
  }

  Future<void> fetchData(String groupId) async {
    try {
      bool cycle =
          await DatabaseHelper.instance.getGroupCycleStatus(widget.groupId!);
      print('Cycle started boolean: $cycle');
    } catch (e) {
      // Handle any potential errors
      print("Error: $e");
    }
  }

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    getGroupIdForFormId(widget.groupId!);
    fetchGroupAccounts();
    getleaders();
    isCycleStarted(widget.groupId!);
    fetchData(widget.groupId!);
    // fetchMemberAndPositionData(widget.groupId!);
    // getImageForMember();
  }

  Future<void> getleaders() async {
    print('Here');
    try {
      print('Group id: ${widget.groupId}');
      final data = await DatabaseHelper.instance.groupProfileId(widget.groupId!);
      print('Group form id: $data');
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replace 'UGX ' with your currency symbol
    // final formattedSavings = currencyFormat.format(activeLoansDetails);
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 1, 67, 3),
            title: Text(
              '${widget.groupName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            elevation: 0.0,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 1, 67, 3),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 11, 0, 0).withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < tabTitles.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: buildTab(tabTitles[i], i),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                  children: [
                    buildContent(0), // Dashboard
                    buildContent(1), // Meetings
                    buildContent(2), // Group Setup
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
        onWillPop: () => navigateDashBoard(context));
  }

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

  Future<bool> navigateDashBoard(BuildContext context) async {
    User? user = await getUserData();
    print('User Data: ${user?.firstName}');

    if (user != null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DashBoard(user: user), // Pass user to DashBoard
        ),
      );
      return true; // Return true to allow navigation
    } else {
      return false; // Return false to prevent navigation
    }
  }
}

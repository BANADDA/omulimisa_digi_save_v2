// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/view/accounts/manage_groups/meetings/start_meeting/Loans/recent_activity_screen.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/custom/dimensions.dart';
import '../../../../widgets/custom/styles.dart';
import '../../../../widgets/feature_card.dart';
import '../../../../widgets/history.dart';
import '../../../../widgets/image_data.dart';
import 'Loans/loanFundPayment.dart';
import 'Loans/loan_application_screen.dart';
import 'socialFunds/recent_activity_screen.dart';
import 'socialFunds/socialFundPayment.dart';
import 'socialFunds/social_fund_application.dart';

class LoanRequest {
  double amount;
  String purpose;
  DateTime repaymentDate;

  LoanRequest(
      {required this.amount,
      required this.purpose,
      required this.repaymentDate});
}

class StartMeeting extends StatefulWidget {
  final int groupId;
  final int meetingId;
  final String? groupName;
  const StartMeeting({
    super.key,
    required this.groupId,
    this.groupName,
    required this.meetingId,
  });

  @override
  State<StartMeeting> createState() => _StartMeetingState();
}

class _StartMeetingState extends State<StartMeeting> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  TextEditingController locationInput = TextEditingController();
  TextEditingController facilitatorInput = TextEditingController();
  TextEditingController meetingPurposeInput = TextEditingController();
  TextEditingController meetingReviewsInput = TextEditingController();
  TextEditingController meetingRemarksInput = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _address;

  List<Map<String, dynamic>> groupMembers = [];
  Map<String, Map<String, bool>> attendanceData = {};
  Map<String, String?> representativeData = {};
  final List<Color> circleColors = [Colors.green, Colors.orange, Colors.red];
  List<String> memberNames = [];
  String? selectedFacilitator;
  List<bool> socialFundContributions = [];
  List<int> shareQuantities = [];
  List<int> totalAmounts = [];
  List<String> userInputValues = [];
  // Define a List to store the input values for each member
  List<String> inputValues = [];
  int shareCost = 2000;
  List<Map<String, dynamic>> sharePurchasesList = [];
  double totalGroupSavings = 0;

  int cycleId = 0;

  // Create a new async function to retrieve activeCycleMeetingID
  void getCycleMeetingID() async {
    int? activeCycleMeetingID =
        await DatabaseHelper.instance.getCycleIdForGroup(widget.groupId);
    if (activeCycleMeetingID != null) {
      print('Active Cycle Meeting ID: $activeCycleMeetingID');
      cycleId = activeCycleMeetingID;
    } else {
      print('No active cycle meeting found.');
    }
  }

  @override
  void initState() {
    dateInput.text = "";
    timeInput.text = "";
    facilitatorInput.text = "";
    meetingPurposeInput;
    meetingReviewsInput;
    meetingRemarksInput;
    getCycleMeetingID();
    fetchShareData(widget.groupId);
    saveGroupInitialData();
    fetchGroupInitialData();
    fetchGroupMembers(); // Move this line here
    checkMeetingCount(widget.groupId, cycleId);
    super.initState();
  }

  Future<void> saveGroupInitialData() async {
    // Fetch Total Savings
    totalGroupSavings =
        await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId);
    print('New Savings: UGX $totalGroupSavings');
    // Fetch active loans
    final totalActiveLoanAmount = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId);
    print('Total Active Loan Amount: UGX $totalActiveLoanAmount');
    // Save data temporarily
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalGroupSavings', totalGroupSavings);
    await prefs.setDouble('activeLoans', totalActiveLoanAmount);
  }

  // Initial amounts
  double? groupSavings;
  double? activeLoansDetails;

  // amounts after
  bool isLoading = false;
  bool isSecondColumnVisible = false;
  double? groupSavingsAfter;
  double? activeLoansDetailsAfter;

  Future<void> fetchGroupInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch Total Savings
    groupSavings = prefs.getDouble('totalGroupSavings');

    // Fetch Active Loans
    activeLoansDetails = prefs.getDouble('activeLoans');
  }

  Future<Map<String, double>> groupAccountsAfter() async {
    double groupSavingsAfter;
    double activeLoansDetailsAfter;

    // Fetch Total Savings
    groupSavingsAfter =
        await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId);
    print('New Savings: UGX $groupSavingsAfter');

    // Fetch active loans
    activeLoansDetailsAfter = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId);
    print('Total Active Loan Amount: UGX $activeLoansDetailsAfter');

    return {
      'groupSavingsAfter': groupSavingsAfter,
      'activeLoansDetailsAfter': activeLoansDetailsAfter
    };
  }

  Future<void> fetchGroupMembers() async {
    try {
      List<Map<String, dynamic>> members =
          await DatabaseHelper.instance.getMembersForGroup(widget.groupId);
      print('Start Cycle Id: ${cycleId}');

      setState(() {
        groupMembers = members;
        socialFundContributions =
            List.generate(groupMembers.length, (index) => false);
        // Initialize shareQuantities and totalAmounts here
        shareQuantities = List.generate(groupMembers.length, (index) => 0);
        totalAmounts = List.generate(groupMembers.length, (index) => 0);

        userInputValues = List.generate(groupMembers.length, (index) => "");

        // Populate attendanceData and representativeData with data from the database
        for (var member in groupMembers) {
          String memberName = '${member['fname']} ${member['lname']}';
          attendanceData[memberName] = {
            'Green': false,
            'Orange': false,
            'Red': false,
          };
          representativeData[memberName] = null;
        }

        // Initialize memberNames after groupMembers is populated
        memberNames = groupMembers
            .map((member) =>
                '$member[id] ${member['fname']} ${member['lname']}}')
            .toList();
      });
    } catch (e) {
      print('Error fetching group members: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        dateInput.text = formattedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        timeInput.text = formattedTime;
      });
    }
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Get current location
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get the address from the coordinates
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = placemark.street ?? '';
        String city = placemark.locality ?? '';
        String state = placemark.administrativeArea ?? '';
        String postalCode = placemark.postalCode ?? '';
        String country = placemark.country ?? '';
        // Combine the address components into a complete address
        _address = '$address, $city, $state $postalCode, $country';

        setState(() {
          _address = _address;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  String getColorName(int index) {
    switch (index) {
      case 0:
        return 'Green';
      case 1:
        return 'Orange';
      case 2:
        return 'Red';
      default:
        return '';
    }
  }

  List<String> objectives = [];
  List<TextEditingController> discussionControllers = [];
  List<String> proposals = [];

  final ScrollController _scrollController = ScrollController();

  // Define a GlobalKey<FormState> to identify the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLocationObtained = false;
  bool isObjectiveEntered = false;

  bool validateGroupMemberAttendance() {
    for (final memberData in attendanceData.values) {
      bool hasSelection = false;
      for (final selection in memberData.values) {
        if (selection) {
          hasSelection = true;
          break;
        }
      }
      if (!hasSelection) {
        return false; // At least one member has no selection
      }
    }
    return true; // All members have at least one selection
  }

  String _formatTime(DateTime dateTime) {
    // Format the DateTime object as "hh:mm a" (e.g., "11:20 AM")
    return DateFormat('hh:mm a').format(dateTime);
  }

  int totalSharesSold = 0;
  void updateTotalSharesSold() {
    int totalShares = 0;
    for (int shares in shareQuantities) {
      totalShares += shares;
    }
    int totalAmount = totalShares * 2000; // Assuming each share costs $2000
    setState(() {
      totalSharesSold = totalAmount;
    });
  }

  double socialFundAmount = 1000.0;
  // Initialize a variable to store the total social fund
  double totalSocialFund = 0.0;

// Create a map to store the social fund contributed by each member
  Map<String, double> socialFundContributionsByMember = {};

  List<LoanRequest> loanRequests = [];
  Set<String> membersWithLoans = {};
  Map<String, double> loanedAmounts = {};
  Map<String, DateTime> returnDates = {};

  void _showLoanDialog(String memberName) {
    // Check if the member has already received a loan
    if (membersWithLoans.contains(memberName)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Loan Request Error'),
            content: Text('$memberName has already received a loan.'),
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
    } else {
      double savedAmount = 500.0;
      double maxLoanAmount = savedAmount / 3;
      double loanAmount = maxLoanAmount;
      DateTime repaymentDate = DateTime.now();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Loan Request for $memberName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount Needed'),
                  onChanged: (value) {
                    loanAmount = double.tryParse(value) ?? 0.0;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Purpose for Loan'),
                  onChanged: (value) {
                    // Store purpose
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 90)),
                    );

                    if (selectedDate != null) {
                      if (selectedDate.isAfter(DateTime.now()) &&
                          selectedDate.isBefore(
                              DateTime.now().add(Duration(days: 91)))) {
                        setState(() {
                          repaymentDate = selectedDate;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invalid Date'),
                              content: Text(
                                  'Please select a date within 1 to 3 months from today.'),
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
                  },
                  child: Text('Select Repayment Date'),
                ),
                Text(
                    'Repayment Date: ${repaymentDate != null ? repaymentDate.toLocal().toString() : 'Not Selected'}'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Request Loan'),
                onPressed: () {
                  if (loanAmount <= maxLoanAmount) {
                    LoanRequest request = LoanRequest(
                      amount: loanAmount,
                      purpose: 'Purpose', // Replace with the entered purpose
                      repaymentDate: repaymentDate ?? DateTime.now(),
                    );

                    membersWithLoans.add(memberName);
                    loanedAmounts[memberName] = loanAmount;
                    returnDates[memberName] = repaymentDate;

                    setState(() {
                      loanRequests.add(request);
                    });

                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Loan Amount'),
                          content: Text(
                              'You can only request up to one-third of your savings.'),
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
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showDeleteLoanConfirmation(String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Loan Confirmation'),
          content:
              Text('Are you sure you want to delete the loan for $memberName?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Remove the loan information for the member
                membersWithLoans.remove(memberName);
                loanedAmounts.remove(memberName);
                returnDates.remove(memberName);

                // Remove the loan request from the list (if it exists)
                loanRequests
                    .removeWhere((request) => request.purpose == memberName);

                setState(() {});

                Navigator.of(context).pop(); // Close the confirmation dialog
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, int> extractMemberSharePurchases(
      List<Map<String, dynamic>> sharePurchasesList) {
    Map<String, int> memberSharePurchases = {};

    for (var purchase in sharePurchasesList) {
      final memberName = purchase['memberName'];
      final shareQuantity = (purchase['shareQuantity'] as num).toInt();

      if (memberSharePurchases.containsKey(memberName)) {
        memberSharePurchases[memberName] =
            (memberSharePurchases[memberName] ?? 0) + shareQuantity;
      } else {
        memberSharePurchases[memberName] = shareQuantity;
      }
    }

    return memberSharePurchases;
  }

  void _showEditLoanDialog(String memberName) {
    double savedAmount =
        500.0; // Example saved amount (replace with actual saved amount)
    double maxLoanAmount =
        savedAmount / 3; // Maximum loan amount based on savings
    double loanAmount =
        loanedAmounts[memberName] ?? 0.0; // Get the current loan amount
    DateTime repaymentDate = returnDates[memberName] ??
        DateTime.now(); // Get the current repayment date

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Loan for $memberName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'New Amount Needed'),
                onChanged: (value) {
                  loanAmount = double.tryParse(value) ?? 0.0;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: repaymentDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 90)),
                  );

                  if (selectedDate != null) {
                    if (selectedDate.isAfter(DateTime.now()) &&
                        selectedDate
                            .isBefore(DateTime.now().add(Duration(days: 91)))) {
                      setState(() {
                        repaymentDate = selectedDate;
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Invalid Date'),
                            content: Text(
                                'Please select a date within 1 to 3 months from today.'),
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
                },
                child: Text('Select New Repayment Date'),
              ),
              Text('Repayment Date: ${repaymentDate.toLocal().toString()}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Update Loan'),
              onPressed: () {
                if (loanAmount <= maxLoanAmount) {
                  // Update the loan information
                  loanedAmounts[memberName] = loanAmount;
                  returnDates[memberName] = repaymentDate;

                  // Update the loan request from the list (if it exists)
                  loanRequests
                      .removeWhere((request) => request.purpose == memberName);

                  LoanRequest request = LoanRequest(
                    amount: loanAmount,
                    purpose: memberName,
                    repaymentDate: repaymentDate,
                  );

                  setState(() {
                    loanRequests.add(request);
                  });

                  Navigator.of(context).pop(); // Close the edit dialog
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Loan Amount'),
                        content: Text(
                            'You can only request up to one-third of your savings.'),
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
              },
            ),
          ],
        );
      },
    );
  }

  List<Map<dynamic, dynamic>> featurelist = [
    {"id": 1, "image": Images.loan, "title": "Loan Application"},
    {"id": 2, "image": Images.payment, "title": "Add Loan Payment"},
    // {"id": 3, "image": Images.score, "title": "Calculate Credit Score"}
  ];

  List<Map<dynamic, dynamic>> socialfeaturelist = [
    {"id": 1, "image": Images.coin, "title": "Assign Social Fund"},
    {"id": 2, "image": Images.payment, "title": "Social Fund Payment"},
    // {"id": 3, "image": Images.score, "title": "Calculate Credit Score"}
  ];

  List<Map<String, dynamic>> recentActivity = [];

  Future<void> checkAndNavigateToMeetingScreen(int groupId) async {
    final meetingCount =
        await DatabaseHelper.instance.countMeetingsForGroup(groupId, cycleId);

    if (meetingCount > 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SocialFundPaymentScreen(groupId: groupId),
        ),
      );
    } else {
      // Show a message indicating there are not enough meetings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There are not enough meetings to navigate.'),
        ),
      );
    }
  }

  int meetingNo = 0;

  Future<void> checkMeetingCount(int groupId, int cycleId) async {
    final meetingCount =
        await DatabaseHelper.instance.countMeetingsForGroup(groupId, cycleId);
    meetingNo = meetingCount;
    print('Actual Meeting Number: $meetingCount');

    print('Copy Meeting Number: $meetingNo');
  }

  String addNumberSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Future<void> checkAndNavigateToLoanRepayment(int groupId, int cycleId) async {
    final meetingCount =
        await DatabaseHelper.instance.countMeetingsForGroup(groupId, cycleId);
    meetingNo = meetingCount;
    print('Actual Meeting Number: $meetingCount');

    print('Copy Meeting Number: $meetingNo');

    // Check if there are any loan details present
    final hasLoans = await DatabaseHelper.instance.hasLoanDetails(groupId);
    print('Has Loans? $hasLoans');

    if (hasLoans) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LoanFundPaymentScreen(
              groupId: groupId, cycleId: cycleId, meetingId: widget.meetingId),
        ),
      );
    } else {
      // Show a message indicating there are no loan details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('There are no loan details available!'),
        ),
      );
    }
  }
  // Map<String, dynamic> loanApplicationData = {};

  int maxShare = 0;
  int minShare = 0;
  String pattern = '';
  RegExp myRegExp = RegExp(r'.*');

  Future<void> fetchShareData(int groupId) async {
    print('Here');
    try {
      // Call the getSharePurchase function
      final Map<String, dynamic> data =
          await DatabaseHelper.instance.getSharePurchase(groupId);

      // Handle the data you retrieved
      print("Data: ${data}");

      // Check if the data is null
      if (data == null) {
        // Handle the case where no group is found or the group does not have share purchase data
        print(
            "No such group found or the group does not have share purchase data.");
        return;
      }

      // Check if maxSharesPerMember and minSharesRequired are not null
      if (data['maxSharesPerMember'] != null &&
          data['minSharesRequired'] != null) {
        // Handle the data you retrieved
        print("Maximum Share Value: ${data['maxSharesPerMember']}");
        print("Minimum Share Value: ${data['minSharesRequired']}");
        maxShare = data['maxSharesPerMember'];
        print('Max: $maxShare');
        minShare = data['minSharesRequired'];
        print('Min: $minShare');
        pattern = '^[$minShare-$maxShare]\$';
        myRegExp = RegExp('^[$minShare-$maxShare]');
        print('Pattern; $pattern');
      } else {
        print("Maximum share value and/or Minimum share value is empty.");
      }
    } catch (e) {
      // Handle any potential errors
      print("Error: share min and max");
    }
  }

  Future<void> deleteMeetingData() async {
    await DatabaseHelper.instance
        .deleteCurrentMeeting(widget.groupId, cycleId, widget.meetingId);
  }

  void showFinesDialog() {
    String intialMember = groupMembers[0]["fname"] + groupMembers[0]["lname"];
    Map<String, dynamic>? selectedMember = groupMembers[0];

    print('Selected Member: $selectedMember}');
    print('Group Member Names: $groupMembers');
    TextEditingController fineAmountController = TextEditingController();
    TextEditingController fineReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Give Fine to Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                StatefulBuilder(builder: (context, setState) {
                  return DropdownButton<String>(
                    value: selectedMember!["id"].toString(),
                    items: groupMembers.map((member) {
                      return DropdownMenuItem<String>(
                        value: member["id"].toString(),
                        child: Text('${member["fname"]} ${member["lname"]}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMember = groupMembers.firstWhere(
                            (member) => member["id"].toString() == value);
                      });
                    },
                  );
                }),
                TextFormField(
                  controller: fineAmountController,
                  decoration: InputDecoration(labelText: 'Fine Amount'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: fineReasonController,
                  decoration: InputDecoration(labelText: 'Reason for Fine'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Process the fine entry, you can save it to the database.
                    String? selectedMemberId = selectedMember?["id"].toString();
                    int fineAmount = int.parse(fineAmountController.text);
                    String fineReason = fineReasonController.text;
                    giveFine(selectedMemberId!, fineAmount, fineReason);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Text(
                    'Give Fine',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                        color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> giveFine(
    String memberId,
    int amount,
    String reason,
  ) async {
    try {
      // You can perform additional actions if needed, such as updating UI or other logic.
      print('$memberId  || $amount || $reason');
      // Savings Account

      String formatDateWithoutTime(DateTime dateTime) {
        final formatter = DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
        return formatter.format(dateTime);
      }

      String dateWithoutTime = formatDateWithoutTime(DateTime.now().toLocal());

      final prefs = await SharedPreferences.getInstance();
      final loggedInUserId = prefs.getInt('userId');
      final finesAmount = {
        'group_id': widget.groupId,
        'logged_in_user_id': loggedInUserId,
        'date': dateWithoutTime,
        'purpose': 'Assign Fines for ($reason)',
        'amount': amount, // Negative amount represents a deduction
      };
      final savingsAccount =
          await DatabaseHelper.instance.insertSavingsAccount(finesAmount);
      print('Savings Account Inserted for $savingsAccount: $finesAmount');
      // Call the insertFine function to insert the fine into the database
      await DatabaseHelper.instance.insertFine(memberId, amount, reason,
          widget.groupId, cycleId, widget.meetingId, savingsAccount);
    } catch (e) {
      print('Error giving fine: $e');
      // Handle any errors that may occur during the insertion.
    }
  }

  String formatCurrency(double amount, String currencySymbol) {
    // Use the toFixed method to round the number to 2 decimal places.
    String formattedAmount = amount.toStringAsFixed(2);

    // Add commas as thousand separators.
    final parts = formattedAmount.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Combine the whole part and decimal part, and add the currency symbol.
    formattedAmount = '$currencySymbol $wholePart.${parts[1]}';

    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    final formattedSavings = formatCurrency(totalGroupSavings, 'UGX');
    final formattedloans = activeLoansDetails != null
        ? formatCurrency(activeLoansDetails!, 'UGX')
        : null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 67, 3),
        title: Text(
          '${widget.groupName} Meeting Agenda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            // Show a confirmation dialog before allowing the user to leave the screen
            bool shouldPop = await showDeleteConfirmationDialog(context);

            if (shouldPop) {
              // User confirmed, delete meeting data and pop the screen
              deleteMeetingData();
            }

            // Return whether the user should be allowed to leave the screen
            return shouldPop;
          },
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 225, 253, 227),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Container(
                            color: Colors.white,
                            child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(children: [
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter start date';
                                                }
                                                return null;
                                              },
                                              controller: dateInput,
                                              decoration: InputDecoration(
                                                icon:
                                                    Icon(Icons.calendar_today),
                                                labelText:
                                                    "Enter Meeting Start Date",
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                _selectDate(context);
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter start time';
                                                }
                                                return null;
                                              },
                                              controller: timeInput,
                                              decoration: InputDecoration(
                                                icon: Icon(Icons.access_time),
                                                labelText:
                                                    "Enter Meeting Start Time",
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 5),
                                              ),
                                              readOnly: true,
                                              onTap: () {
                                                _selectTime(context);
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await getLocation();
                                                    setState(() {
                                                      isLocationObtained = true;
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.green,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 0, 103, 4),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 5.0,
                                                    ),
                                                    child: Text(
                                                      'Get Location',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Divider(),
                                                Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(2),
                                                    1: FlexColumnWidth(3),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        Text(
                                                          'Latitude:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '$_latitude',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        Text(
                                                          'Longitude:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '$_longitude',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        Text(
                                                          'Address:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          _address ??
                                                              'Address not available',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(height: 10),
                                                DropdownButtonFormField<String>(
                                                  value:
                                                      selectedFacilitator, // This should be a state variable to store the selected facilitator
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedFacilitator =
                                                          newValue;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please select a facilitator';
                                                    }
                                                    return null;
                                                  },
                                                  items: groupMembers
                                                      .map((member) {
                                                    final String memberName =
                                                        '${member['fname']} ${member['lname']}';
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: memberName,
                                                      child: Text(memberName),
                                                    );
                                                  }).toList(),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Meeting Facilitator",
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                        'Group Members Attendance',
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              121,
                                                              120,
                                                              120),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        )),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                        "Please select group members' attendance based on the criteria below",
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 82, 81, 81),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ))
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Divider(),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 12,
                                                          backgroundColor:
                                                              Colors.green,
                                                          child: Icon(
                                                              Icons.check,
                                                              size: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text('Present',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 12,
                                                          backgroundColor:
                                                              Colors.red,
                                                          child: Icon(
                                                              Icons.check,
                                                              size: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text('Absent',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 12,
                                                          backgroundColor:
                                                              Colors.orange,
                                                          child: Icon(
                                                              Icons.check,
                                                              size: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            'Absent with Representative',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                Divider(),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(height: 10),
                                                    for (String name
                                                        in attendanceData.keys)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(name),
                                                              SizedBox(
                                                                  width: 10),
                                                              for (int i = 0;
                                                                  i <
                                                                      circleColors
                                                                          .length;
                                                                  i++)
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (attendanceData[name] !=
                                                                            null) {
                                                                          for (int j = 0;
                                                                              j < circleColors.length;
                                                                              j++) {
                                                                            attendanceData[name]![getColorName(j)] =
                                                                                (i == j);
                                                                          }

                                                                          // If orange circle is selected, show the dropdown
                                                                          if (getColorName(i) ==
                                                                              'Orange') {
                                                                            showRepresentativeDropdown(context,
                                                                                name);
                                                                          } else {
                                                                            // Clear representative data if a different circle is selected
                                                                            representativeData[name] =
                                                                                null;
                                                                          }
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: 25,
                                                                      height:
                                                                          25,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: attendanceData[name] != null &&
                                                                                attendanceData[name]![getColorName(i)]!
                                                                            ? circleColors[i]
                                                                            : Colors.white,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              circleColors[i],
                                                                          width:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                      child: attendanceData[name] != null &&
                                                                              attendanceData[name]![getColorName(i)]!
                                                                          ? Center(
                                                                              child: Icon(
                                                                                Icons.check,
                                                                                color: Colors.white,
                                                                                size: 20,
                                                                              ),
                                                                            )
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10),
                                                          // Display selected representative
                                                          if (representativeData[
                                                                      name] !=
                                                                  null &&
                                                              representativeData[
                                                                      name] !=
                                                                  name)
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Representative: ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Text(
                                                                    '${representativeData[name]}')
                                                              ],
                                                            ),
                                                          SizedBox(height: 15),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                Text('Meeting Agenda',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 121, 120, 120),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    )),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                    "In this section, you'll be required to provide the meeting agenda and discussion topics, including their duration",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 82, 81, 81),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ))
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 228, 247, 229),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Column(
                                                children: const [
                                                  Text(
                                                    '1. Objectives and Purpose of Meeting',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter meeting purpose';
                                                }
                                                return null;
                                              },
                                              controller: meetingPurposeInput,
                                              maxLines:
                                                  null, // Allow multiline input
                                              decoration: InputDecoration(
                                                labelText: "Meeting Purpose",
                                                hintText:
                                                    "Enter meeting purpose...",
                                                border:
                                                    OutlineInputBorder(), // Add a border
                                                contentPadding: EdgeInsets.all(
                                                    16), // Adjust content padding
                                              ),
                                              textInputAction:
                                                  TextInputAction.done,
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      String newObjective = "";

                                                      return AlertDialog(
                                                        title: Text(
                                                            "Add Objective"),
                                                        content: TextField(
                                                          onChanged: (value) {
                                                            newObjective =
                                                                value;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Enter Objective",
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                objectives.add(
                                                                    newObjective);
                                                                discussionControllers
                                                                    .add(
                                                                        TextEditingController()); // Create a new discussion controller
                                                              });
                                                              // Set the flag to true
                                                              isObjectiveEntered =
                                                                  true;
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text("Add"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 0, 103, 4),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0))),
                                                child: Text(
                                                  "Add Objective",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                            SizedBox(height: 15),
                                            Divider(),
                                            // Display objectives with tick numbering
                                            // Display objectives with tick numbering and delete option
                                            SizedBox(
                                              height: 100,
                                              child: ListView.builder(
                                                controller: _scrollController,
                                                shrinkWrap: true,
                                                itemCount: objectives.length,
                                                itemExtent:
                                                    40, // Adjust this value to reduce the gap
                                                itemBuilder: (context, index) {
                                                  String deletedObjective =
                                                      ""; // Store the deleted objective

                                                  return SingleChildScrollView(
                                                      child: Dismissible(
                                                          key: Key(objectives[
                                                              index]), // Unique key for each objective
                                                          onDismissed:
                                                              (direction) {
                                                            setState(() {
                                                              // Store the deleted objective
                                                              deletedObjective =
                                                                  objectives[
                                                                      index];
                                                              // Remove the objective when dismissed
                                                              objectives
                                                                  .removeAt(
                                                                      index);
                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    "Objective deleted"),
                                                                action:
                                                                    SnackBarAction(
                                                                  label: 'Undo',
                                                                  onPressed:
                                                                      () {
                                                                    // Add the deleted objective back to the list
                                                                    setState(
                                                                        () {
                                                                      objectives.insert(
                                                                          index,
                                                                          deletedObjective);
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          background: Expanded(
                                                            child: Container(
                                                              color: Colors.red,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          16),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: const [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Colors.white),
                                                                      Text(
                                                                        'Delete',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          child: Expanded(
                                                            child: ListTile(
                                                              leading: Text(
                                                                "✔️",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      8,
                                                                      138,
                                                                      12),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  objectives[
                                                                      index]),
                                                            ),
                                                          )));
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Divider(),

                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 228, 247, 229),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Column(
                                                children: const [
                                                  Text(
                                                    '2. Agenda Items',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            if (objectives.isEmpty)
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    'No agenda items',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: objectives.length,
                                                itemBuilder: (context, index) {
                                                  final objective =
                                                      objectives[index];

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Item ${index + 1}:    ",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(objective),
                                                        ],
                                                      ),
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter objective discussion';
                                                          }
                                                          return null;
                                                        },
                                                        maxLines: null,
                                                        controller:
                                                            discussionControllers[
                                                                index], // Use the appropriate discussion controller
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              "Item Discussion",
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            vertical: 10,
                                                          ),
                                                        ),
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Divider(),
                                            SizedBox(height: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 228, 247, 229),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Column(
                                                children: const [
                                                  Text(
                                                    '3. Review minutes from previous meeting',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter minutes from previous meeting';
                                                }
                                                return null;
                                              },
                                              controller: meetingReviewsInput,
                                              maxLines:
                                                  null, // Allow multiline input
                                              decoration: InputDecoration(
                                                labelText:
                                                    "Reviews from Previous Meetings",
                                                hintText:
                                                    "Enter minutes from previous meeting...",
                                                border:
                                                    OutlineInputBorder(), // Add a border
                                                contentPadding: EdgeInsets.all(
                                                    16), // Adjust content padding
                                              ),
                                              textInputAction:
                                                  TextInputAction.done,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Divider(),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Meeting Starting Balances',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 121, 120, 120),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  "These are the group's ${addNumberSuffix(meetingNo)} meeting starting balances",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 82, 81, 81),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            CustomListTileWithAmountAndIcon(
                                              text: 'Savings Account',
                                              amount: formattedSavings,
                                              amountColor: Color.fromARGB(
                                                  255, 2, 168, 7),
                                              icon: Icons.bar_chart,
                                              iconColor: Color.fromARGB(
                                                  255, 1, 190, 7),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            CustomListTileWithAmountAndIcon(
                                              text: 'WellFair Fund',
                                              amount: 'UGX 1,800,000',
                                              amountColor: Color.fromARGB(
                                                  255, 2, 168, 7),
                                              icon: Icons.health_and_safety,
                                              iconColor: const Color.fromARGB(
                                                  255, 141, 140, 140),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            CustomListTileWithAmountAndIcon(
                                              text: 'Active Loan Amount',
                                              amount: formattedloans ?? 'N/A',
                                              amountColor: const Color.fromARGB(
                                                  255, 143, 11, 1),
                                              icon: Icons.clean_hands,
                                              iconColor: const Color.fromARGB(
                                                  255, 221, 15, 0),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            CustomListTileWithAmountAndIcon(
                                              text: 'WellFair Given-Out',
                                              amount: 'UGX 100,000',
                                              amountColor: Color.fromARGB(
                                                  255, 170, 153, 0),
                                              icon: Icons.enhanced_encryption,
                                              iconColor: const Color.fromARGB(
                                                  255, 204, 184, 0),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(),

                                          SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Group Member Fines',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 121, 120, 120),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                "Assign Fines, including reason for fines to group members who have violated the group rules and regulations",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 82, 81, 81),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 226, 247, 227),
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 226, 247, 227),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: ListTile(
                                                  title: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/police.png',
                                                            width: 80,
                                                            height: 80,
                                                          ),
                                                          SizedBox(width: 20),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: const [
                                                                Text(
                                                                  'Fines',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                                Text(
                                                                  'Assign Fines to group members',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                showFinesDialog();
                                                                print(
                                                                    'Pressed');
                                                              },
                                                              style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .green,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      0.0,
                                                                ),
                                                                child: Text(
                                                                  'Assign Fines',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {},
                                                              style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .green,
                                                                  backgroundColor:
                                                                      const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          0,
                                                                          103,
                                                                          4),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      0.0,
                                                                ),
                                                                child: Text(
                                                                  'View Fines',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ])
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Divider(),

                                          SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Social Funds Contribution',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 121, 120, 120),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                "Mark group members who have made a contribution of $socialFundAmount to the social fund box",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 82, 81, 81),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: groupMembers.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  String memberName =
                                                      '${groupMembers[index]['fname']} ${groupMembers[index]['lname']}';
                                                  // Check if socialFundContributions has enough elements
                                                  if (socialFundContributions
                                                          .length <=
                                                      index) {
                                                    // If not, add a default value (false)
                                                    socialFundContributions
                                                        .add(false);
                                                  }

                                                  return CheckboxListTile(
                                                    title: Text(memberName),
                                                    value:
                                                        socialFundContributions[
                                                            index],
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        socialFundContributions[
                                                                index] =
                                                            value ?? false;
                                                      });

                                                      if (value == true) {
                                                        // If the member is marked as a contributor, add their contribution to the total social fund
                                                        totalSocialFund +=
                                                            socialFundAmount;
                                                        socialFundContributionsByMember[
                                                                memberName] =
                                                            socialFundAmount;
                                                      } else {
                                                        // If the member is unmarked, subtract their contribution from the total social fund
                                                        totalSocialFund -=
                                                            socialFundContributionsByMember[
                                                                    memberName] ??
                                                                0.0;
                                                        socialFundContributionsByMember
                                                            .remove(memberName);
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Cash in Social Fund Bag: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'UGX ${totalSocialFund.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 4, 189, 10),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            height: 10,
                                          ),

                                          Divider(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  'Share Purchase/Loan Fund Contribution',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 121, 120, 120),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  "Add members share contributions/group Savings",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 82, 81, 81),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ]),
                                          ElevatedButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadiusDirectional
                                                            .only(
                                                      topEnd:
                                                          Radius.circular(25),
                                                      topStart:
                                                          Radius.circular(25),
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.75,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft:
                                                                  const Radius
                                                                      .circular(
                                                                      25.0),
                                                              topRight:
                                                                  const Radius
                                                                      .circular(
                                                                      25.0),
                                                            ),
                                                          ),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      20,
                                                                      30,
                                                                      20,
                                                                      45),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    "Enter the number of shares purchased by each member in the group. Share range should be between $minShare to $maxShare and each shares costs UGX 2000",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          82,
                                                                          81,
                                                                          81),
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: List
                                                                        .generate(
                                                                      groupMembers
                                                                          .length,
                                                                      (index) {
                                                                        String
                                                                            memberName =
                                                                            '${groupMembers[index]['fname']} ${groupMembers[index]['lname']}';

                                                                        return ListTile(
                                                                          title:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                memberName,
                                                                                style: TextStyle(
                                                                                  color: const Color.fromARGB(255, 0, 27, 1),
                                                                                  fontWeight: FontWeight.w800,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 35,
                                                                                child: TextField(
                                                                                  keyboardType: TextInputType.number,
                                                                                  inputFormatters: [
                                                                                    FilteringTextInputFormatter.allow(myRegExp),
                                                                                  ],
                                                                                  onChanged: (value) {
                                                                                    // Store user input temporarily
                                                                                    userInputValues[index] = value;

                                                                                    if (value.isEmpty) {
                                                                                      // Remove the entry from sharePurchasesList if it exists
                                                                                      final memberId = groupMembers[index]['id'];
                                                                                      sharePurchasesList.removeWhere((entry) => entry['memberId'] == memberId);

                                                                                      // Reset values when input is empty
                                                                                      shareQuantities[index] = 0;
                                                                                      totalAmounts[index] = 0;
                                                                                    } else {
                                                                                      int shares = int.tryParse(value) ?? 0;
                                                                                      if (shares < minShare || shares > maxShare) {
                                                                                        // Show a Snackbar for an invalid share value
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(
                                                                                            content: Text(
                                                                                              'Invalid share value. Enter a value between $minShare and $maxShare.',
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      } else {
                                                                                        shareQuantities[index] = shares;
                                                                                        int totalAmount = shares * shareCost;
                                                                                        totalAmounts[index] = totalAmount;

                                                                                        // Update the share purchase data if the member already exists
                                                                                        final memberId = groupMembers[index]['id'];
                                                                                        final existingEntryIndex = sharePurchasesList.indexWhere((entry) => entry['memberId'] == memberId);

                                                                                        if (existingEntryIndex != -1) {
                                                                                          sharePurchasesList[existingEntryIndex]['shareQuantity'] = shares;
                                                                                        } else {
                                                                                          // If the member doesn't exist, add a new entry
                                                                                          sharePurchasesList.add({
                                                                                            'memberId': memberId,
                                                                                            'memberName': memberName,
                                                                                            'shareQuantity': shares,
                                                                                          });
                                                                                        }

                                                                                        print('Shares Sold: $sharePurchasesList');
                                                                                        print('Group Members: $groupMembers');
                                                                                      }
                                                                                    }

                                                                                    // Recalculate the total shares sold based on user input values
                                                                                    updateTotalSharesSold();
                                                                                    print('Total Shares: $totalSharesSold');
                                                                                  },
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          20),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      String formatDateWithoutTime(
                                                                          DateTime
                                                                              dateTime) {
                                                                        final formatter =
                                                                            DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
                                                                        return formatter
                                                                            .format(dateTime);
                                                                      }

                                                                      String
                                                                          dateWithoutTime =
                                                                          formatDateWithoutTime(
                                                                              DateTime.now().toLocal());

                                                                      final prefs =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      final loggedInUserId =
                                                                          prefs.getInt(
                                                                              'userId');
                                                                      final deductionData =
                                                                          {
                                                                        'group_id':
                                                                            widget.groupId,
                                                                        'logged_in_user_id':
                                                                            loggedInUserId,
                                                                        'date':
                                                                            dateWithoutTime,
                                                                        'purpose':
                                                                            'Share Purchase',
                                                                        'amount':
                                                                            totalSharesSold,
                                                                      };
                                                                      Map<String,
                                                                              dynamic>
                                                                          memberShareData =
                                                                          {
                                                                        'group_id':
                                                                            widget.groupId,
                                                                        'cycle_id':
                                                                            cycleId,
                                                                        'meetingId':
                                                                            widget.meetingId,
                                                                        'logged_in_user_id':
                                                                            loggedInUserId,
                                                                        'date':
                                                                            dateWithoutTime,
                                                                        'sharePurchases':
                                                                            json.encode(sharePurchasesList),
                                                                      };
                                                                      await DatabaseHelper
                                                                          .instance
                                                                          .insertMemberShare(
                                                                              memberShareData);

                                                                      print(
                                                                          'Member Shares Inserted: $memberShareData');
                                                                      final savingsAccount = await DatabaseHelper
                                                                          .instance
                                                                          .insertSavingsAccount(
                                                                              deductionData);
                                                                      print(
                                                                          'Savings Account Inserted for $savingsAccount: $deductionData');
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      backgroundColor: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          0,
                                                                          103,
                                                                          4),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      "Submit Shares",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )));
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
                                            child: Text(
                                              'Add Member Shares',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Cash in Loan Fund Bag: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'UGX $totalSharesSold',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 4, 189, 10),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // New social funds
                                          SizedBox(
                                            height: 20,
                                          ),
                                          // features
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Social Fund Features',
                                                style: urbanistBold.copyWith(
                                                  fontSize: Dimensions
                                                      .PADDING_SIZE_DEFAULT,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                child: ListView.builder(
                                                  itemCount:
                                                      socialfeaturelist.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder: (context, i) {
                                                    return FeatureCard(
                                                      image:
                                                          socialfeaturelist[i]
                                                              ['image'],
                                                      title:
                                                          socialfeaturelist[i]
                                                              ['title'],
                                                      onPress: () {
                                                        // Define the action to be taken when the card is pressed
                                                        if (socialfeaturelist[i]
                                                                ['title'] ==
                                                            'Assign Social Fund') {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SocialFundApplication(
                                                                groupId: widget
                                                                    .groupId,
                                                                cycleId:
                                                                    cycleId,
                                                                meetingId: widget
                                                                    .meetingId,
                                                                groupMembers:
                                                                    groupMembers,
                                                                onRecentActivityUpdated:
                                                                    (updatedRecentActivity) {
                                                                  setState(() {
                                                                    // Update the recent activity data in this screen
                                                                    recentActivity =
                                                                        updatedRecentActivity;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        } else if (socialfeaturelist[
                                                                i]['title'] ==
                                                            'Social Fund Payment') {
                                                          // Navigate to the screen for "Social Fund Payment"
                                                          checkAndNavigateToMeetingScreen(
                                                              widget.groupId);
                                                        }
                                                        // Add more conditions/actions as needed
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SocialRecentActivityScreen(
                                                                groupId: widget
                                                                    .groupId,
                                                                cycleId:
                                                                    cycleId,
                                                                meetingId: widget
                                                                    .meetingId)),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 103, 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Assigned Social Funds",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                            ],
                                          ),

                                          Divider(),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          // features
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Loan Fund Features',
                                                style: urbanistBold.copyWith(
                                                  fontSize: Dimensions
                                                      .PADDING_SIZE_DEFAULT,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                child: ListView.builder(
                                                  itemCount: featurelist.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder: (context, i) {
                                                    return FeatureCard(
                                                      image: featurelist[i]
                                                          ['image'],
                                                      title: featurelist[i]
                                                          ['title'],
                                                      onPress: () {
                                                        // Define the action to be taken when the card is pressed
                                                        if (featurelist[i]
                                                                ['title'] ==
                                                            'Loan Application') {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoanApplicationScreen(
                                                                groupId: widget
                                                                    .groupId,
                                                                cycleId:
                                                                    cycleId,
                                                                meetingId: widget
                                                                    .meetingId,
                                                                groupMembers:
                                                                    groupMembers,
                                                                onRecentActivityUpdated:
                                                                    (updatedRecentActivity) {
                                                                  setState(() {
                                                                    // Update the recent activity data in this screen
                                                                    recentActivity =
                                                                        updatedRecentActivity;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        } else if (featurelist[
                                                                i]['title'] ==
                                                            'Add Loan Payment') {
                                                          // Navigate to the screen for "Social Fund Payment"
                                                          checkAndNavigateToLoanRepayment(
                                                              widget.groupId,
                                                              cycleId);
                                                        }
                                                        // Add more conditions/actions as needed
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            RecentActivityScreen(
                                                                groupId: widget
                                                                    .groupId,
                                                                cycleId:
                                                                    cycleId,
                                                                meetingId: widget
                                                                    .meetingId)),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 103, 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Recent Activity",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                            ],
                                          ),
                                          Divider(),

                                          SizedBox(
                                            height: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                  'Concluding Remarks & Adjourments',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 121, 120, 120),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                  "Provide concluding remarks from group members",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 82, 81, 81),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 228, 247, 229),
                                                ),
                                                padding: EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: const [
                                                    Text(
                                                      'Proposals for Next Meeting Agenda',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              //
                                              ElevatedButton(
                                                  onPressed: () {
                                                    // Implement logic to add proposals here
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        String newProposal =
                                                            ""; // Store the new proposal

                                                        return AlertDialog(
                                                          title: Text(
                                                            "Add Proposal",
                                                          ),
                                                          content: TextField(
                                                            onChanged: (value) {
                                                              newProposal =
                                                                  value;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  "Enter Proposal",
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                // Clear the input field and close the dialog without adding the proposal
                                                                setState(() {
                                                                  newProposal =
                                                                      "";
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              },
                                                              child: Text(
                                                                  "Cancel"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                if (newProposal
                                                                    .isNotEmpty) {
                                                                  setState(() {
                                                                    // Add the new proposal to the list of proposals
                                                                    proposals.add(
                                                                        newProposal);

                                                                    // Clear the input field
                                                                    newProposal =
                                                                        "";

                                                                    // Close the dialog
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  });
                                                                }
                                                              },
                                                              child:
                                                                  Text("Add"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 0, 103, 4),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0))),
                                                  child: Text("Add Proposal",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),

                                              SizedBox(
                                                height: 15,
                                              ),
                                              // Display proposals using ListView.builder
                                              proposals.isEmpty
                                                  ? Text("No Proposals")
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          proposals.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final proposal =
                                                            proposals[index];

                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ListTile(
                                                              leading: Text(
                                                                "Proposal ${index + 1}:",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  proposal),
                                                              trailing:
                                                                  IconButton(
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    // Remove the proposal when the delete button is pressed
                                                                    proposals
                                                                        .removeAt(
                                                                            index);
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                              SizedBox(
                                                height: 10,
                                              ),

                                              Divider(),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Meeting End Balances',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 121, 120, 120),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    "These are the group's ${addNumberSuffix(meetingNo)} meeting ending balances",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 82, 81, 81),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading =
                                                        true; // Set isLoading to true when the button is pressed
                                                  });

                                                  try {
                                                    Map<String, dynamic> data =
                                                        await groupAccountsAfter();
                                                    final currencyFormat =
                                                        NumberFormat.currency(
                                                            symbol: 'UGX ');

                                                    setState(() {
                                                      isLoading = false;
                                                      isSecondColumnVisible =
                                                          true;
                                                      groupSavingsAfter = data[
                                                          'groupSavingsAfter'];
                                                      activeLoansDetailsAfter =
                                                          data[
                                                              'activeLoansDetailsAfter'];
                                                    });
                                                  } catch (e) {
                                                    // Handle any errors, e.g., show an error message
                                                    setState(() {
                                                      isLoading =
                                                          false; // Set isLoading to false on error
                                                    });
                                                  }
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 103, 4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                ),
                                                child: Text(
                                                    'Show Group Ending Balances',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              SizedBox(height: 15),
                                              isLoading
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(), // Show loading indicator when isLoading is true
                                                    )
                                                  : Visibility(
                                                      visible:
                                                          isSecondColumnVisible, // Conditionally set visibility
                                                      child: Column(
                                                        children: [
                                                          CustomListTileWithAmountAndIcon(
                                                            text:
                                                                'Savings Account',
                                                            amount:
                                                                'UGX $groupSavingsAfter',
                                                            amountColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    2,
                                                                    168,
                                                                    7),
                                                            icon:
                                                                Icons.bar_chart,
                                                            iconColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    1,
                                                                    190,
                                                                    7),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomListTileWithAmountAndIcon(
                                                            text:
                                                                'WellFair Fund',
                                                            amount:
                                                                'UGX 1,000,000',
                                                            amountColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    2,
                                                                    168,
                                                                    7),
                                                            icon: Icons
                                                                .health_and_safety,
                                                            iconColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    141,
                                                                    140,
                                                                    140),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomListTileWithAmountAndIcon(
                                                            text:
                                                                'Loan Amount Given-Out',
                                                            amount:
                                                                'UGX $activeLoansDetailsAfter',
                                                            amountColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    143,
                                                                    11,
                                                                    1),
                                                            icon: Icons
                                                                .clean_hands,
                                                            iconColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    221,
                                                                    15,
                                                                    0),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomListTileWithAmountAndIcon(
                                                            text:
                                                                'WellFair Given-Out',
                                                            amount:
                                                                'UGX 200,000',
                                                            amountColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    170,
                                                                    153,
                                                                    0),
                                                            icon: Icons
                                                                .enhanced_encryption,
                                                            iconColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    204,
                                                                    184,
                                                                    0),
                                                          ),
                                                        ],
                                                      )),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Divider(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 228, 247, 229),
                                                ),
                                                padding: EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: const [
                                                    Text(
                                                      'Concluding Remarks',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter concluding remarks';
                                                  }
                                                  return null;
                                                },
                                                controller: meetingRemarksInput,
                                                maxLines:
                                                    null, // Allow multiline input
                                                decoration: InputDecoration(
                                                  labelText: "Meeting Remarks",
                                                  hintText:
                                                      "Enter any remarks made...",
                                                  border:
                                                      OutlineInputBorder(), // Add a border
                                                  contentPadding: EdgeInsets.all(
                                                      16), // Adjust content padding
                                                ),
                                                textInputAction:
                                                    TextInputAction.done,
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              // Submit Button
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        if (objectives
                                                            .isEmpty) {
                                                          // No objectives are entered.
                                                          // Display an error message or take appropriate action.
                                                          // For example, show a SnackBar with an error message.
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Please enter at least one objective before submitting.',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      31,
                                                                      53,
                                                                      32),
                                                              action:
                                                                  SnackBarAction(
                                                                label: 'Close',
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        if (!validateGroupMemberAttendance()) {
                                                          // Group member attendance validation failed.
                                                          // Display an error message or take appropriate action.
                                                          // For example, show a SnackBar with an error message.
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Please select attendance for all group members before submitting.',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      31,
                                                                      53,
                                                                      32),
                                                              action:
                                                                  SnackBarAction(
                                                                label: 'Close',
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          if (!isLocationObtained) {
                                                            // Location is required, but it hasn't been obtained yet.
                                                            // Display an error message or take appropriate action.
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Please get the location before submitting.',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        31,
                                                                        53,
                                                                        32),
                                                                action:
                                                                    SnackBarAction(
                                                                  label:
                                                                      'Close',
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                            return;
                                                          }

                                                          // Capture the meeting end time (only the time component)
                                                          TimeOfDay
                                                              currentTime =
                                                              TimeOfDay.now();

// Convert TimeOfDay to DateTime
                                                          DateTime now =
                                                              DateTime.now();
                                                          DateTime endTime =
                                                              DateTime(
                                                            now.year,
                                                            now.month,
                                                            now.day,
                                                            currentTime.hour,
                                                            currentTime.minute,
                                                          );

// Format the end time as desired (e.g., 'hh:mm a')
                                                          String
                                                              formattedEndTime =
                                                              DateFormat(
                                                                      'hh:mm a')
                                                                  .format(
                                                                      endTime);

                                                          Map<String, dynamic>
                                                              meetingData = {
                                                            'group_id':
                                                                widget.groupId,
                                                            'cycle_id': cycleId,
                                                            'date':
                                                                dateInput.text,
                                                            'time':
                                                                timeInput.text,
                                                            'location':
                                                                locationInput
                                                                    .text,
                                                            'facilitator':
                                                                selectedFacilitator,
                                                            'meetingPurpose':
                                                                meetingPurposeInput
                                                                    .text,
                                                            'latitude':
                                                                _latitude,
                                                            'longitude':
                                                                _longitude,
                                                            'address': _address ??
                                                                'Address not available',
                                                            'objectives':
                                                                objectives.join(
                                                                    ', '), // Convert objectives list to a comma-separated string
                                                            'attendanceData':
                                                                json.encode(
                                                                    attendanceData), // Convert attendanceData map to JSON string
                                                            'representativeData':
                                                                json.encode(
                                                                    representativeData), // Convert representativeData map to JSON string
                                                            'proposals':
                                                                proposals.join(
                                                                    ', '), // Convert proposals list to a comma-separated string
                                                            'endTime':
                                                                formattedEndTime, // Save the current time as the meeting end time
                                                            'totalSocialFund':
                                                                totalSocialFund,
                                                            'totalLoanFund':
                                                                totalSharesSold,
                                                            'socialFundContributions':
                                                                socialFundContributionsByMember, // Add social fund contributions here
                                                            'sharePurchases':
                                                                json.encode(
                                                                    sharePurchasesList),
                                                            // Add share purchases here
                                                          };

                                                          try {
                                                            // Insert the meeting data into the database
                                                            int normalMeetingId =
                                                                await DatabaseHelper
                                                                    .instance
                                                                    .updateMeeting(
                                                                        widget
                                                                            .meetingId,
                                                                        meetingData);

                                                            if (normalMeetingId >
                                                                0) {
                                                              print(
                                                                  'Meeting updated successfully.');
                                                              print(
                                                                  'Meeting Data: $meetingData');
                                                              print(
                                                                  'Normal Meeting Data Saved: $normalMeetingId');
                                                            } else {
                                                              print(
                                                                  'Failed to update meeting.');
                                                            }

                                                            // Display a success message
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Meeting data saved with ID: $normalMeetingId',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        31,
                                                                        53,
                                                                        32),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            // Handle any exceptions that may occur during the process
                                                            print('Error: $e');
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'An error occurred while saving data. Please try again.',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                                backgroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        0,
                                                                        0),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      style: TextButton.styleFrom(
                                                          backgroundColor:
                                                              const Color.fromARGB(
                                                                  255, 0, 103, 4),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0))),
                                                      child: Text(
                                                          "Stop Meeting",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white))),
                                                ],
                                              )
                                            ],
                                          )
                                        ]))))))),
          )),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: Text(
              'Are you sure you want to close the meeting? All data will be lost.'),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      completer.complete(false); // User canceled
                    },
                  ),
                  TextButton(
                    child: Text('Proceed', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      completer.complete(true); // User confirmed
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );

    return completer.future;
  }

  // Function to show the representative dropdown
  void showRepresentativeDropdown(BuildContext context, String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Representative'),
          content: DropdownButtonFormField<String>(
            value: representativeData[memberName],
            items: attendanceData.keys
                .where((name) => name != memberName)
                .map<DropdownMenuItem<String>>((name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                representativeData[memberName] = newValue;
                Navigator.of(context).pop(); // Close the dialog
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
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

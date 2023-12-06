// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/services.dart'; // Import this line
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/history.dart';
import '../../group_screen.dart';

class StartCycle extends StatefulWidget {
  final String? groupId;
  final String? groupName;
  const StartCycle({
    super.key,
    this.groupId,
    this.groupName,
  });

  @override
  State<StartCycle> createState() => _StartCycleState();
}

class _StartCycleState extends State<StartCycle> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  TextEditingController locationInput = TextEditingController();
  TextEditingController facilitatorInput = TextEditingController();
  TextEditingController meetingPurposeInput = TextEditingController();
  TextEditingController meetingRemarksInput = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _address;
  String SocialFund = 'UGX 2000';
  List<Map<String, dynamic>> groupMembers = [];
  Map<String, Map<String, bool>> attendanceData = {};
  Map<String, String?> representativeData = {};
  final List<Color> circleColors = [Colors.green, Colors.orange, Colors.red];
  List<String> memberNames = [];
  String? selectedFacilitator;
  Map<String, double> assignedAmounts = {};
  List<bool> socialFundContributions = [];
  List<int> shareQuantities = [];
  List<int> totalAmounts = [];
  List<String> userInputValues = [];
  // Define a List to store the input values for each member
  List<String> inputValues = [];
  int shareCost = 2000;
  List<Map<String, dynamic>> sharePurchasesList = [];

  @override
  void initState() {
    saveGroupInitialData();
    fetchGroupInitialData();
    fetchShareData(widget.groupId!);
    dateInput.text = "";
    timeInput.text = "";
    facilitatorInput.text = "";
    meetingPurposeInput;
    meetingRemarksInput;
    fetchGroupMembers(); // Move this line here
    super.initState();
  }

  double totalGroupSavings = 0;

  Future<void> saveGroupInitialData() async {
    // Fetch Total Savings
    totalGroupSavings =
    await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId!);
    print('New Savings: UGX $totalGroupSavings');
    // Fetch active loans
    final totalActiveLoanAmount = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId!);
    print('Total Active Loan Amount: UGX $totalActiveLoanAmount');
    // Save data temporarily
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalGroupSavings', totalGroupSavings);
    await prefs.setDouble('activeLoans', totalActiveLoanAmount);
  }

  String formatCurrency(double? amount, String currencySymbol) {
    if (amount == null) {
      return ''; // Return an empty string or any default value for null amount
    }

    // Use the toFixed method to round the number to 2 decimal places.
    String formattedAmount = amount.toStringAsFixed(2);

    // Add the currency symbol and any other formatting you need.
    formattedAmount = '$currencySymbol $formattedAmount';

    return formattedAmount;
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
        await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId!);
    print('New Savings: UGX $groupSavingsAfter');

    // Fetch active loans
    activeLoansDetailsAfter = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId!);
    print('Total Active Loan Amount: UGX $activeLoansDetailsAfter');

    return {
      'groupSavingsAfter': groupSavingsAfter,
      'activeLoansDetailsAfter': activeLoansDetailsAfter
    };
  }

  Future<void> fetchGroupMembers() async {
    try {
      List<Map<String, dynamic>> members =
          await DatabaseHelper.instance.getMembersForGroup(widget.groupId!);

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
            .map((member) => '${member['first_name']} ${member['last_name']}')
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

  int maxShare = 0;
  int minShare = 0;
  String pattern = '';
  RegExp myRegExp = RegExp(r'.*');

  Future<void> fetchShareData(String groupId) async {
    try {
      // Call the getSharePurchase function
      final Map<String, dynamic>? data =
          await DatabaseHelper.instance.getSharesByGroupId(groupId);

      if (data == null) {
        // Handle the case where no group is found
        print("No such group found.");
      } else {
        // Check if maxSharesPerMember and minSharesRequired are not null
        if (data['maxSharesPerMember'] != null &&
            data['minSharesRequired'] != null) {
          // Handle the data you retrieved
          print("Maximum Share Value: ${data['maxSharesPerMember']}");
          print("Minimum Share Value: ${data['minSharesRequired']}");
          maxShare = data['maxSharesPerMember'];
          minShare = data['minSharesRequired'];
          pattern = '^[$minShare-$maxShare]\$';
          myRegExp = RegExp('^[$minShare-$maxShare]');
          print('Pattern; $pattern');
        } else {
          print("Maximum share value and/or Minimum share value is empty.");
        }
      }
    } catch (e) {
      // Handle any potential errors
      print("Error: $e");
    }
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
          title: const Text('Give Fine to Member'),
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
                  decoration: const InputDecoration(labelText: 'Fine Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: fineReasonController,
                  decoration:
                      const InputDecoration(labelText: 'Reason for Fine'),
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
                  child: const Text(
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
                  child: const Text(
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
      final loggedInUserId = prefs.getString('userId');
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
      await DatabaseHelper.instance.insertFine(
          memberId, amount, reason, widget.groupId!, '0', '0', savingsAccount);
      setState(() {
        groupAccountsAfter();
      });
    } catch (e) {
      print('Error giving fine: $e');
      // Handle any errors that may occur during the insertion.
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedSavings = formatCurrency(totalGroupSavings, 'UGX');
    final formattedloans = activeLoansDetails != null
        ? formatCurrency(activeLoansDetails!, 'UGX')
        : 'UGX 0.0'; // Handle null value safely

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: Text(
            '1st Cycle Meeting ${widget.groupName} Group',
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
        body: Scaffold(
            backgroundColor: const Color.fromARGB(255, 225, 253, 227),
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Container(
                            color: Colors.white,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
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
                                              decoration: const InputDecoration(
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
                                            const SizedBox(height: 10),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter start time';
                                                }
                                                return null;
                                              },
                                              controller: timeInput,
                                              decoration: const InputDecoration(
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
                                            const SizedBox(height: 20),
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
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                const Divider(),
                                                Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(2),
                                                    1: FlexColumnWidth(3),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        const Text(
                                                          'Latitude:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '$_latitude',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        const Text(
                                                          'Longitude:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          '$_longitude',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        const Text(
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
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Divider(),
                                                const SizedBox(height: 10),
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
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        "Meeting Facilitator",
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
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
                                                const SizedBox(height: 10),
                                                const Divider(),
                                                const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
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
                                                const Divider(),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    for (String name
                                                        in attendanceData.keys)
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(name),
                                                              const SizedBox(
                                                                  width: 10),
                                                              for (int i = 0;
                                                                  i <
                                                                      circleColors
                                                                          .length;
                                                                  i++)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
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
                                                                          ? const Center(
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
                                                          const SizedBox(
                                                              height: 10),
                                                          // Display selected representative
                                                          if (representativeData[
                                                                      name] !=
                                                                  null &&
                                                              representativeData[
                                                                      name] !=
                                                                  name)
                                                            Row(
                                                              children: [
                                                                const Text(
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
                                                          const SizedBox(
                                                              height: 15),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
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
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 228, 247, 229),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Column(
                                                children: [
                                                  Text(
                                                    '1. Objectives and Purpose of Meeting',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
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
                                              decoration: const InputDecoration(
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
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      String newObjective = "";

                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Add Objective"),
                                                        content: TextField(
                                                          onChanged: (value) {
                                                            newObjective =
                                                                value;
                                                          },
                                                          decoration:
                                                              const InputDecoration(
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
                                                            child: const Text(
                                                                "Add"),
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
                                                child: const Text(
                                                  "Add Objective",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                            const SizedBox(height: 15),
                                            const Divider(),
                                            // Display objectives with tick numbering
                                            // Display objectives with tick numbering and delete option
                                            ListView.builder(
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
                                                            objectives.removeAt(
                                                                index);
                                                          });

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: const Text(
                                                                  "Objective deleted"),
                                                              action:
                                                                  SnackBarAction(
                                                                label: 'Undo',
                                                                onPressed: () {
                                                                  // Add the deleted objective back to the list
                                                                  setState(() {
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
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 16),
                                                            child: const Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .white),
                                                                    Text(
                                                                      'Delete',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
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
                                                            leading: const Text(
                                                              "✔️",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                color: Color
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
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 228, 247, 229),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '2. Agenda Items',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            if (objectives.isEmpty)
                                              const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
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
                                                            "Objective ${index + 1}:    ",
                                                            style:
                                                                const TextStyle(
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
                                                            const InputDecoration(
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
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),

                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Divider(),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Meeting Starting Balances',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 121, 120, 120),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  "These are the group's ${addNumberSuffix(1)} meeting starting balances",
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 82, 81, 81),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                            CustomListTileWithAmountAndIcon(
                                              text: 'Savings Account',
                                              amount: formattedSavings,
                                              amountColor: const Color.fromARGB(
                                                  255, 2, 168, 7),
                                              icon: Icons.bar_chart,
                                              iconColor: const Color.fromARGB(
                                                  255, 1, 190, 7),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),

                                            const CustomListTileWithAmountAndIcon(
                                              text: 'WellFair Fund',
                                              amount: 'UGX 1,800,000',
                                              amountColor: Color.fromARGB(
                                                  255, 2, 168, 7),
                                              icon: Icons.health_and_safety,
                                              iconColor: Color.fromARGB(
                                                  255, 141, 140, 140),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),

                                            CustomListTileWithAmountAndIcon(
                                              text: 'Active Loan Amount',
                                              amount: formattedloans,
                                              amountColor: const Color.fromARGB(
                                                  255, 143, 11, 1),
                                              icon: Icons.clean_hands,
                                              iconColor: const Color.fromARGB(
                                                  255, 221, 15, 0),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),

                                            const CustomListTileWithAmountAndIcon(
                                              text: 'WellFair Given-Out',
                                              amount: 'UGX 100,000',
                                              amountColor: Color.fromARGB(
                                                  255, 170, 153, 0),
                                              icon: Icons.enhanced_encryption,
                                              iconColor: Color.fromARGB(
                                                  255, 204, 184, 0),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Group Member Fines',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 121, 120, 120),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              const Text(
                                                "Assign Fines, including reason for fines to group members who have violated the group rules and regulations",
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 82, 81, 81),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
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
                                                          const SizedBox(
                                                              width: 20),
                                                          const Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
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
                                                      const SizedBox(
                                                          height: 15),
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
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
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
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Social Funds Contribution',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 121, 120, 120),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                "Mark group members who have made a contribution of $socialFundAmount to the social fund box",
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 82, 81, 81),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
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
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'Cash in Social Fund Bag: UGX ${totalSocialFund.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
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
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.75,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      25.0),
                                                              topRight: Radius
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
                                                                        const TextStyle(
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
                                                                  const SizedBox(
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
                                                                                style: const TextStyle(
                                                                                  color: Color.fromARGB(255, 0, 27, 1),
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
                                                                  const SizedBox(
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
                                                                          prefs.getString(
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
                                                                            1,
                                                                        'meetingId':
                                                                            0,
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
                                                                    child:
                                                                        const Text(
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
                                            child: const Text(
                                              'Add Member Shares',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                'Cash in Loan Fund Bag: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'UGX $totalSharesSold',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 4, 189, 10),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Divider(),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
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
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 228, 247, 229),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: const Column(
                                                  children: [
                                                    Text(
                                                      'Proposals for Next Meeting Agenda',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              // Add a button to add proposals
                                              ElevatedButton(
                                                  onPressed: () {
                                                    // Implement logic to add proposals here
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        String newProposal =
                                                            ""; // Store the new proposal

                                                        return AlertDialog(
                                                          title: const Text(
                                                            "Add Proposal",
                                                          ),
                                                          content: TextField(
                                                            onChanged: (value) {
                                                              newProposal =
                                                                  value;
                                                            },
                                                            decoration:
                                                                const InputDecoration(
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
                                                              child: const Text(
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
                                                              child: const Text(
                                                                  "Add"),
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
                                                  child: const Text(
                                                      "Add Proposal",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),

                                              const SizedBox(
                                                height: 15,
                                              ),
                                              // Display proposals using ListView.builder
                                              proposals.isEmpty
                                                  ? const Text("No Proposals")
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
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  proposal),
                                                              trailing:
                                                                  IconButton(
                                                                icon:
                                                                    const Icon(
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
                                                            const SizedBox(
                                                              height: 15,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                              const SizedBox(
                                                height: 10,
                                              ),

                                              const Divider(),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Meeting End Balances',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 121, 120, 120),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    "These are the group's ${addNumberSuffix(1)} meeting ending balances",
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 82, 81, 81),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(
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
                                                child: const Text(
                                                    'Show Group Ending Balances',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              const SizedBox(height: 15),
                                              isLoading
                                                  ? const Center(
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
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    2,
                                                                    168,
                                                                    7),
                                                            icon:
                                                                Icons.bar_chart,
                                                            iconColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    1,
                                                                    190,
                                                                    7),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const CustomListTileWithAmountAndIcon(
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
                                                                Color.fromARGB(
                                                                    255,
                                                                    141,
                                                                    140,
                                                                    140),
                                                          ),
                                                          const SizedBox(
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
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          const CustomListTileWithAmountAndIcon(
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
                                                                Color.fromARGB(
                                                                    255,
                                                                    204,
                                                                    184,
                                                                    0),
                                                          ),
                                                        ],
                                                      )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Divider(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 228, 247, 229),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: const Column(
                                                  children: [
                                                    Text(
                                                      'Concluding Remarks',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
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
                                                decoration:
                                                    const InputDecoration(
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
                                              const SizedBox(
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
                                                      if (objectives.isEmpty) {
                                                        // No objectives are entered.
                                                        // Display an error message or take appropriate action.
                                                        // For example, show a SnackBar with an error message.
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: const Text(
                                                              'Please enter at least one objective before submitting.',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                              onPressed: () {},
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
                                                            content: const Text(
                                                              'Please select attendance for all group members before submitting.',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                              onPressed: () {},
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                        return;
                                                      }

                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        try {
                                                          if (!isLocationObtained) {
                                                            // Location is required, but it hasn't been obtained yet.
                                                            // Display an error message or take appropriate action.
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content:
                                                                    const Text(
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

                                                          // Filter members who have made a contribution
                                                          List<String>
                                                              loanFundContributors =
                                                              [];
                                                          for (int i = 0;
                                                              i <
                                                                  groupMembers
                                                                      .length;
                                                              i++) {
                                                            if (socialFundContributions[
                                                                i]) {
                                                              String
                                                                  memberName =
                                                                  '${groupMembers[i]['first_name']} ${groupMembers[i]['last_name']}';
                                                              loanFundContributors
                                                                  .add(
                                                                      memberName);
                                                            }
                                                          }

                                                          // Create a map to store the number of shares each member has bought
                                                          Map<String, int>
                                                              sharesBoughtByMember =
                                                              {};

                                                          for (int i = 0;
                                                              i <
                                                                  groupMembers
                                                                      .length;
                                                              i++) {
                                                            String memberName =
                                                                '${groupMembers[i]['first_name']} ${groupMembers[i]['last_name']}';
                                                            int sharesBought =
                                                                shareQuantities[
                                                                    i];
                                                            sharesBoughtByMember[
                                                                    memberName] =
                                                                sharesBought;
                                                          }

                                                          Map<String, dynamic>
                                                              meetingData = {
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
                                                                formattedEndTime,
                                                            'totalSocialFund':
                                                                totalSocialFund,
                                                            'totalLoanFund':
                                                                totalSharesSold,
                                                            'socialFundContributions':
                                                                socialFundContributionsByMember, // Add total shares sold
                                                            'sharePurchases':
                                                                json.encode(
                                                                    sharePurchasesList), // Add shares bought by each member
                                                          };

                                                          print(
                                                              'Meeting Data: $meetingData');

                                                          // Insert the meeting data into the database
                                                          String meetingId =
                                                              await DatabaseHelper
                                                                  .instance
                                                                  .insertCycleStartMeeting(
                                                                      meetingData);

                                                          final groupId =
                                                              widget.groupId;

                                                          await DatabaseHelper
                                                              .instance
                                                              .deleteGroupData(
                                                                  groupId!);

                                                          bool isCycleStarted =
                                                              true;
                                                          await DatabaseHelper
                                                              .instance
                                                              .insertCycleStatus(
                                                                  groupId,
                                                                  meetingId,
                                                                  isCycleStarted);

                                                          final activeCycle = {
                                                            'group_id': widget
                                                                .groupId, // Set the group ID from your widget
                                                            'cycleMeetingID':
                                                                meetingId,
                                                          };

                                                          try {
                                                            String activeCycleMeetingID =
                                                                await DatabaseHelper
                                                                    .instance
                                                                    .insertActiveCycleMeeting(
                                                                        activeCycle);
                                                            print(
                                                                'Active cycle: $activeCycleMeetingID');
                                                          } catch (e) {
                                                            print('Error: $e');
                                                          }

                                                          // Update the 'is_cycle_started' field in the 'group_cycle_status' table
                                                          await DatabaseHelper
                                                              .instance
                                                              .updateGroupCycleStatus(
                                                                  groupId,
                                                                  meetingId,
                                                                  true);

                                                          // Display a success message
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Meeting data saved with ID: $meetingId',
                                                                style: const TextStyle(
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
                                                          print(
                                                              'Meeting ID: $meetingId');
                                                          // Navigator.pop(
                                                          //     context, meetingId);
                                                          // SharedPreferences
                                                          //     prefs =
                                                          //     await SharedPreferences
                                                          //         .getInstance();
                                                          // prefs.setInt('cycleId',
                                                          //     meetingId);
                                                          // Navigator.of(context)
                                                          //     .pop(meetingId);

                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  GroupDashboard(
                                                                groupName: widget
                                                                    .groupName,
                                                                groupId:
                                                                    groupId,
                                                              ),
                                                            ),
                                                          );
                                                        } catch (e) {
                                                          // Handle database insertion error here
                                                          print('Error: $e');
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content:
                                                                  const Text(
                                                                'Error: An error occurred while saving the meeting data.',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
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
                                                        }
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 0, 103, 4),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                        "Stop Meeting",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ])))))))));
  }

  // Function to show the representative dropdown
  void showRepresentativeDropdown(BuildContext context, String memberName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Representative'),
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
              child: const Text('Cancel'),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import '../../group_screen.dart';
import '/src/view/accounts/manage_groups/meetings/end_cycle/passbook/passBook.dart';
import '../../../../../../database/localStorage.dart';
import 'analysis/analystics.dart';
import 'package:quickalert/quickalert.dart';

class MeetingData {
  String date;
  String time;
  String location;
  String facilitator;
  double latitude;
  double longitude;
  String address;
  String attendanceData;
  String representativeData;
  String endTime;

  MeetingData({
    required this.date,
    required this.time,
    required this.location,
    required this.facilitator,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.attendanceData,
    required this.representativeData,
    required this.endTime,
  });

  factory MeetingData.fromJson(Map<String, dynamic> json) {
    return MeetingData(
      date: json['date'],
      time: json['time'],
      location: json['location'],
      facilitator: json['facilitator'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      attendanceData: json['attendanceData'],
      representativeData: json['representativeData'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'location': location,
      'facilitator': facilitator,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'attendanceData': attendanceData,
      'representativeData': representativeData,
      'endTime': endTime,
    };
  }
}

class EndCycle extends StatefulWidget {
  final int? groupId;
  final bool? isNavigationEnabled;
  final String? groupName;
  const EndCycle({
    super.key,
    this.groupId,
    this.groupName,
    this.isNavigationEnabled,
  });

  @override
  State<EndCycle> createState() => _EndCycleState();
}

class _EndCycleState extends State<EndCycle> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  TextEditingController locationInput = TextEditingController();
  TextEditingController facilitatorInput = TextEditingController();
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

  int cycleId = 0;

  // Create a new async function to retrieve activeCycleMeetingID
  void getCycleMeetingID() async {
    int? activeCycleMeetingID =
        await DatabaseHelper.instance.getCycleIdForGroup(widget.groupId!);
    if (activeCycleMeetingID != null) {
      print('Active Cycle Meeting ID: $activeCycleMeetingID');
      cycleId = activeCycleMeetingID;
    } else {
      print('No active cycle meeting found.');
    }
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
            .map((member) => '${member['fname']} ${member['lname']}')
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

  List<TextEditingController> discussionControllers = [];

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

  List<Map<String, dynamic>> recentActivity = [];
  bool isNavigationEnabled = true;

  bool userConfirmed = false; // Initialize the confirmation flag

  // void showAwesomeDialog() async {
  //   await AwesomeDialog(
  //     context: context,
  //     dialogType: DialogType.warning,
  //     animType: AnimType.rightSlide,
  //     title: 'Warning',
  //     desc: "You're about to exit group cycle meeting!!!",
  //     btnCancelOnPress: () {
  //       userConfirmed = false; // Set the flag to false if user cancels
  //     },
  //     btnOkOnPress: () {
  //       userConfirmed = true; // Set the flag to true if user confirms
  //       Navigator.pop(context);
  //     },
  //   ).show();
  // }

  String getOrdinalIndicator(int number) {
    if (number % 10 == 1 && number % 100 != 11) {
      return 'st';
    } else if (number % 10 == 2 && number % 100 != 12) {
      return 'nd';
    } else if (number % 10 == 3 && number % 100 != 13) {
      return 'rd';
    } else {
      return 'th';
    }
  }

  Future<void> endCycleDalog() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    final groupId = widget.groupId;
    try {
      final deletedSavings =
          await dbHelper.deleteSavingsAccountsByGroupId(groupId!);

      if (deletedSavings > 0) {
        print('Deleted $deletedSavings rows with group_id 1');

        // Update the 'is_cycle_started' field in the 'group_cycle_status' table
        await dbHelper.updateGroupCycleStatus(groupId, cycleId, false);

        // Using the DatabaseHelper instance, call the deleteCycleDataForGroup method
        // await dbHelper.deleteCycleDataForGroup(groupId, cycleId);

        final deletedRow =
            await dbHelper.removeActiveCycleMeeting(groupId, cycleId);

        if (deletedRow > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDashboard(
                groupName: widget.groupName,
                groupId: widget.groupId,
              ),
            ),
          );
        } else {
          print('No record found to delete');
        }
      } else {
        print('No rows found to delete for group_id 1');
      }
    } catch (e) {
      print(e);
    }
  }

  void navigator() {
    if (widget.isNavigationEnabled != null) {
      isNavigationEnabled = widget.isNavigationEnabled!;
    } else {
      print('Error');
    }
  }

  @override
  void initState() {
    navigator();
    dateInput.text = "";
    timeInput.text = "";
    facilitatorInput.text = "";
    meetingReviewsInput;
    meetingRemarksInput;
    getCycleMeetingID();
    fetchGroupMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'End Group Cycle',
            style: TextStyle(
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
        body: WillPopScope(
            onWillPop: () async {
              Dialogs.bottomMaterialDialog(
                  msg:
                      'Are you sure you want to close this meeting? you can\'t undo this action',
                  title: 'Close End cycle meeting',
                  context: context,
                  actions: [
                    IconsOutlineButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      iconData: Icons.cancel_outlined,
                      textStyle: TextStyle(color: Colors.grey),
                      iconColor: Colors.grey,
                    ),
                    IconsButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupDashboard(
                              groupName: widget.groupName,
                              groupId: widget.groupId,
                            ),
                          ),
                        );
                      },
                      text: 'Yes',
                      iconData: Icons.close,
                      color: Colors.red,
                      textStyle: TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    ),
                  ]);
              return false; // Return false to prevent the screen from popping immediately
            },
            child: Scaffold(
                backgroundColor: const Color.fromARGB(255, 225, 253, 227),
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
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255)),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter start date';
                                                      }
                                                      return null;
                                                    },
                                                    controller: dateInput,
                                                    decoration:
                                                        const InputDecoration(
                                                      icon: Icon(
                                                          Icons.calendar_today),
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
                                                    decoration:
                                                        const InputDecoration(
                                                      icon: Icon(
                                                          Icons.access_time),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await getLocation();
                                                          setState(() {
                                                            isLocationObtained =
                                                                true;
                                                          });
                                                        },
                                                        style: TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.green,
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    0,
                                                                    103,
                                                                    4),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0))),
                                                        child: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 5.0,
                                                          ),
                                                          child: Text(
                                                            'Get Location',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white),
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
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '$_latitude',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            children: [
                                                              const Text(
                                                                'Longitude:',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                '$_longitude',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          TableRow(
                                                            children: [
                                                              const Text(
                                                                'Address:',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                _address ??
                                                                    'Address not available',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const Divider(),
                                                      const SizedBox(
                                                          height: 10),
                                                      DropdownButtonFormField<
                                                          String>(
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
                                                            return 'Please select a moderator';
                                                          }
                                                          return null;
                                                        },
                                                        items: groupMembers
                                                            .map((member) {
                                                          final String
                                                              memberName =
                                                              '${member['fname']} ${member['lname']}';
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: memberName,
                                                            child: Text(
                                                                memberName),
                                                          );
                                                        }).toList(),
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              "Meeting Moderator",
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          5),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Group Members Attendance',
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        121,
                                                                        120,
                                                                        120),
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              )),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          Text(
                                                              "Please select group members' attendance based on the criteria below",
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        82,
                                                                        81,
                                                                        81),
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ))
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      const Divider(),
                                                      const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 12,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                child: Icon(
                                                                    Icons.check,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text('Present',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
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
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text('Absent',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
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
                                                                    Colors
                                                                        .orange,
                                                                child: Icon(
                                                                    Icons.check,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                  'Absent with Representative',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
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
                                                          const SizedBox(
                                                              height: 10),
                                                          for (String name
                                                              in attendanceData
                                                                  .keys)
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(name),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    for (int i =
                                                                            0;
                                                                        i < circleColors.length;
                                                                        i++)
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              if (attendanceData[name] != null) {
                                                                                for (int j = 0; j < circleColors.length; j++) {
                                                                                  attendanceData[name]![getColorName(j)] = (i == j);
                                                                                }

                                                                                // If orange circle is selected, show the dropdown
                                                                                if (getColorName(i) == 'Orange') {
                                                                                  showRepresentativeDropdown(context, name);
                                                                                } else {
                                                                                  // Clear representative data if a different circle is selected
                                                                                  representativeData[name] = null;
                                                                                }
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                25,
                                                                            height:
                                                                                25,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: attendanceData[name] != null && attendanceData[name]![getColorName(i)]! ? circleColors[i] : Colors.white,
                                                                              border: Border.all(
                                                                                color: circleColors[i],
                                                                                width: 2,
                                                                              ),
                                                                            ),
                                                                            child: attendanceData[name] != null && attendanceData[name]![getColorName(i)]!
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
                                                                          color:
                                                                              Colors.black,
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
                                                    height: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      print('Tapped');
                                                      if (isNavigationEnabled) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Analystics(
                                                              cycleId: cycleId,
                                                              groupId: widget
                                                                  .groupId,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        // Handle the case where navigation is disabled
                                                        // Change the container color to gray
                                                        print(
                                                            'Navigation is disabled.');
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isNavigationEnabled
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    211,
                                                                    255,
                                                                    212)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    209,
                                                                    205,
                                                                    205),
                                                        border: Border.all(
                                                          color:
                                                              isNavigationEnabled
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      211,
                                                                      255,
                                                                      212)
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      209,
                                                                      205,
                                                                      205),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const ListTile(
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .analytics_rounded),
                                                            SizedBox(width: 5),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              'View Analytics',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    0), // Add this SizedBox widget
                                                          ],
                                                        ),
                                                        trailing: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: Color.fromARGB(
                                                              255, 78, 78, 78),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (isNavigationEnabled &&
                                                          cycleId != null &&
                                                          widget.groupId !=
                                                              null) {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PassBook(
                                                                          cycleId:
                                                                              cycleId,
                                                                          groupId:
                                                                              widget.groupId!,
                                                                        ))).then(
                                                            (value) {
                                                          if (value != null &&
                                                              value is Map) {
                                                            setState(() {
                                                              isNavigationEnabled =
                                                                  value[
                                                                      'isNavigationEnabled'];
                                                            });
                                                          }
                                                        });
                                                      } else {
                                                        // Handle the case where navigation is disabled
                                                        print(
                                                            'PassBook navigation is disabled.');
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isNavigationEnabled
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    211,
                                                                    255,
                                                                    212)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    209,
                                                                    205,
                                                                    205),
                                                        border: Border.all(
                                                          color:
                                                              isNavigationEnabled
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      211,
                                                                      255,
                                                                      212)
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      209,
                                                                      205,
                                                                      205),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const ListTile(
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons.wallet),
                                                            SizedBox(width: 5),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              'Passbook',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(width: 0),
                                                          ],
                                                        ),
                                                        trailing: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: Color.fromARGB(
                                                              255, 78, 78, 78),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      print('Tapped');
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //       builder: (context) =>
                                                      //           NextScreen()),
                                                      // );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 211, 255, 212),
                                                        border: Border.all(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              211, 255, 212),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const ListTile(
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons.group),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              'Update Group',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 0,
                                                            ), // Add this SizedBox widget
                                                          ],
                                                        ),
                                                        trailing: Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: Color.fromARGB(
                                                              255, 78, 78, 78),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                                horizontal:
                                                                    10), // Adjust the padding here
                                                      ),
                                                    ),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Concluding Remarks & Adjourments',
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
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
                                                          "Provide concluding remarks from group members",
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    82,
                                                                    81,
                                                                    81),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ))
                                                    ],
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
                                                    controller:
                                                        meetingRemarksInput,
                                                    maxLines:
                                                        null, // Allow multiline input
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          "Meeting Remarks",
                                                      hintText:
                                                          "Enter any remarks made...",
                                                      border:
                                                          OutlineInputBorder(), // Add a border
                                                      contentPadding:
                                                          EdgeInsets.all(
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                          onPressed: () async {
                                                            if (!validateGroupMemberAttendance()) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      const Text(
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

                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              if (!isLocationObtained) {
                                                                // Location is required, but it hasn't been obtained yet.
                                                                // Display an error message or take appropriate action.
                                                                ScaffoldMessenger.of(
                                                                        context)
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
                                                            }
                                                            QuickAlert.show(
                                                                context:
                                                                    context,
                                                                type: QuickAlertType
                                                                    .success,
                                                                confirmBtnText:
                                                                    'Done',
                                                                confirmBtnColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        0,
                                                                        103,
                                                                        4),
                                                                confirmBtnTextStyle:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                text:
                                                                    "${widget.groupName} group's ${cycleId}${getOrdinalIndicator(cycleId)} cycle eneded successfully",
                                                                showConfirmBtn:
                                                                    true,
                                                                onConfirmBtnTap:
                                                                    () => {
                                                                          endCycleDalog()
                                                                        });
                                                          },
                                                          style: TextButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255, 0, 103, 4),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          5.0))),
                                                          child: const Text(
                                                              "End Cycle",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ]))))))))));
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

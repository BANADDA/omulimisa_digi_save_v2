import 'package:flutter/material.dart';

import '../../../../../../database/localStorage.dart';
import '../../../../widgets/alert.dart';
import '../../group_start.dart';

class ScheduleScreen extends StatefulWidget {
  final int? groupId;

  const ScheduleScreen({
    super.key,
    this.groupId,
  });
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String meetingDuration = '';
  int numberOfMeetings = 0;
  String meetingFrequency = '';
  String selectedDayOfWeek = 'Monday'; // Default value for day of the week
  DateTime? startDate;
  DateTime? shareOutDate;
  String? groupName;

  void retrieveName() async {
    String? groupName = await DatabaseHelper.instance
        .getGroupNameByGroupId(widget.groupId.toString()); // Convert to String
    setState(() {
      this.groupName = groupName;
      print('Group Name is: $groupName');
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveName(); // Call the function when the widget is initialized
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    setState(() {
      if (field == 'start') {
        startDate = picked;
      } else if (field == 'shareOut') {
        shareOutDate = picked;
      }
    });
  }

  void navigateToGroupStart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GroupStart(),
      ),
    );
  }

  void calculateMeetingDetails() {
    if (startDate != null &&
        shareOutDate != null &&
        meetingFrequency.isNotEmpty) {
      // Calculate meeting duration based on the difference between start and share-out dates
      final Duration difference = shareOutDate!.difference(startDate!);
      final int totalDays = difference.inDays;

      // Calculate the number of meetings based on the selected frequency
      int frequencyMultiplier = 0;
      switch (meetingFrequency) {
        case 'Weekly':
          frequencyMultiplier = 1;
          break;
        case 'Bi-weekly':
          frequencyMultiplier = 2;
          break;
        case 'Monthly':
          frequencyMultiplier = 4;
          break;
      }

      // Calculate the number of meetings based on the selected frequency and total days
      numberOfMeetings = totalDays ~/ (7 * frequencyMultiplier);

      // Calculate meeting duration in weeks and days
      final int weeks = totalDays ~/ 7;
      final int remainingDays = totalDays % 7;
      meetingDuration = '$weeks weeks and $remainingDays days';
    } else {
      // Reset values if not all inputs are provided
      meetingDuration = '';
      numberOfMeetings = 0;
    }

    // Update the UI with calculated values
    setState(() {
      meetingDuration = meetingDuration;
      numberOfMeetings = numberOfMeetings;
    });
  }

  Widget buildMeetingFrequencyRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How often does $groupName group carry out meetings?',
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 17, 0, 0),
              fontWeight: FontWeight.bold,
            )),
        Column(
          children: [
            Row(
              children: [
                Radio(
                    value: 'Weekly',
                    groupValue: meetingFrequency,
                    onChanged: (value) {
                      setState(() {
                        meetingFrequency = value as String;
                      });
                    },
                    activeColor: Colors.green),
                const Text('Weekly',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 24, 23, 23),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            Row(
              children: [
                Radio(
                    value: 'Bi-weekly',
                    groupValue: meetingFrequency,
                    onChanged: (value) {
                      setState(() {
                        meetingFrequency = value as String;
                      });
                    },
                    activeColor: Colors.green),
                const Text('Two Weeks',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 24, 23, 23),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            Row(
              children: [
                Radio(
                    value: 'Monthly',
                    groupValue: meetingFrequency,
                    onChanged: (value) {
                      setState(() {
                        meetingFrequency = value as String;
                      });
                    },
                    activeColor: Colors.green),
                const Text('Monthly',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 24, 23, 23),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDayOfWeekDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select the day of the week for meetings:',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 17, 0, 0),
              fontWeight: FontWeight.bold,
            )),
        DropdownButton<String>(
          value: selectedDayOfWeek,
          onChanged: (String? newValue) {
            setState(() {
              selectedDayOfWeek = newValue!;
            });
          },
          items: <String>[
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 24, 23, 23),
                    fontWeight: FontWeight.w500,
                  )),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildDatePickers() {
    if (meetingFrequency.isEmpty) {
      return const SizedBox
          .shrink(); // Hide date pickers if meeting frequency is not selected
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Start Date of Meetings',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 17, 0, 0),
              fontWeight: FontWeight.bold,
            )),
        TextButton(
          onPressed: () => _selectDate(context, 'start'),
          child: Text(
              startDate != null
                  ? '${startDate!.toLocal()}'.split(' ')[0]
                  : 'Start Date',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              )),
        ),
        const Text('Select Share-Out Date / End Date for All Meetings',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 17, 0, 0),
              fontWeight: FontWeight.bold,
            )),
        TextButton(
          onPressed: () => _selectDate(context, 'shareOut'),
          child: Text(
              shareOutDate != null
                  ? '${shareOutDate!.toLocal()}'.split(' ')[0]
                  : 'Share-Out Date',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              )),
        ),
      ],
    );
  }

  // Validation
  bool validateForm() {
    if (meetingFrequency.isEmpty ||
        selectedDayOfWeek.isEmpty ||
        startDate == null ||
        shareOutDate == null) {
      // If any of the required fields is empty, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: const Text('Please fill out all fields before submitting.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }

    DateTime? minShareOutDate;

    if (meetingFrequency == 'Weekly') {
      minShareOutDate = startDate?.add(const Duration(days: 6));
    } else if (meetingFrequency == 'Bi-weekly') {
      minShareOutDate = startDate?.add(const Duration(days: 13));
    } else if (meetingFrequency == 'Monthly') {
      minShareOutDate = startDate?.add(const Duration(days: 29));
    }

    if (shareOutDate!.isBefore(minShareOutDate!)) {
      // If share-out date is before the minimum allowed date, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: const Text(
                'Share-Out Date must be greater than or equal to the minimum allowed date based on the selected frequency.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 1, 67, 3),
            title: const Text(
              'Cycle Schedule',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMeetingFrequencyRadio(),
                const SizedBox(height: 20),
                buildDayOfWeekDropdown(),
                const SizedBox(height: 20),
                buildDatePickers(),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                  ),
                  onPressed: () {
                    calculateMeetingDetails();
                  },
                  child: const Text('Calculate Meeting Details'),
                ),
                const SizedBox(height: 20),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              const Text('Meeting Duration: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(meetingDuration,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              const Text('Number of Meetings: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('$numberOfMeetings',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))
                            ],
                          ),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final int groupId = widget.groupId ?? 0;
                        try {
                          if (validateForm()) {
                            // Calculate meeting details
                            calculateMeetingDetails();
                            // Insert data into the database
                            // await DatabaseHelper.instance.insertScheduleData(
                            //   meetingDuration: meetingDuration,
                            //   numberOfMeetings: numberOfMeetings,
                            //   meetingFrequency: meetingFrequency,
                            //   dayOfWeek: selectedDayOfWeek,
                            //   startDate: startDate.toString(),
                            //   shareOutDate: shareOutDate.toString(),
                            //   groupId: groupId,
                            // );

                            Map<String, dynamic> scheduleData = {
                              'group_id': groupId,
                              'meeting_duration': meetingDuration,
                              'number_of_meetings': numberOfMeetings,
                              'meeting_frequency': meetingFrequency,
                              'day_of_week': selectedDayOfWeek,
                              'start_date': startDate.toString(),
                              'share_out_date': shareOutDate.toString(),
                            };

                            print('Scheduled Data: $scheduleData');

                            await DatabaseHelper.instance
                                .insertScheduleData(scheduleData);

                            setState(() {
                              scheduleSaved = true;
                            });
                            // print(
                            //     'Cycle SChedule data for group $groupId submitted successfully');
                            // Navigate to the next screen
                            navigateToGroupStart();

                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Submission successful!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          // Handle any exceptions or errors that occur during submission
                          print('Error during submission: $e');

                          // Show an error message
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                    'An error occurred during submission. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
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
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          final bool? closeForm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                description: "Are you sure you want to close this form?",
                onYesPressed: () {
                  Navigator.pop(context, true); // Return true to close the form
                },
                onNoPressed: () {
                  Navigator.pop(
                      context, false); // Return false to stay on the form
                },
                onOkPressed: () {},
              );
            },
          );

          return closeForm ??
              false; // If the dialog is dismissed, default to false (stay on the form)
        });
  }
}

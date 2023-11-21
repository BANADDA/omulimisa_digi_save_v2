import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Initialize the local notifications plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize the time zone database
void initializeNotifications() {
  tz.initializeTimeZones();
}

// Schedule a local notification for the meeting
Future<void> scheduleNotification(
  String meetingName,
  DateTime meetingDate,
  bool enableNotifications, {
  TimeOfDay? startTime,
  TimeOfDay? endTime,
}) async {
  if (enableNotifications) {
    // Get the user's time zone
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(meetingDate, tz.local);

    // Calculate the notification time for 5 minutes before the meeting
    final notificationTimeBefore = scheduledDate.subtract(const Duration(minutes: 5));

    // Calculate the notification time for the exact meeting start time
    final notificationTimeExact = scheduledDate;

    // Set up the notification details
    var platformDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'Channel Name',
        channelDescription: 'Description',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Create the notification messages
    final notificationMessageBefore =
        '5 minutes until your meeting: $meetingName at ${scheduledDate.hour}:${scheduledDate.minute}';

    final notificationMessageExact =
        'Meeting Reminder: $meetingName starts now at ${scheduledDate.hour}:${scheduledDate.minute}';

    // Schedule the notification 5 minutes before the meeting
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Meeting Reminder',
      notificationMessageBefore,
      notificationTimeBefore,
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Schedule the notification at the exact meeting start time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Meeting Reminder',
      notificationMessageExact,
      notificationTimeExact,
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class MeetingSchedular extends StatefulWidget {
  const MeetingSchedular({super.key});

  @override
  _MeetingSchedularState createState() => _MeetingSchedularState();
}

class _MeetingSchedularState extends State<MeetingSchedular> {
  final TextEditingController _meetingNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _enableNotifications = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Meeting Scheduler',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _meetingNameController,
                    decoration: const InputDecoration(labelText: 'Meeting Name'),
                  ),
                  const SizedBox(height: 16.0),
                  // TextFormField(
                  //   controller: _meetingNameController,
                  //   decoration: InputDecoration(labelText: 'Location'),
                  // ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text('Select Meeting Date: '),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          "${_selectedDate.toLocal()}".split(' ')[0],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text('Select Start Time: '),
                      TextButton(
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _startTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          _startTime != null
                              ? "${_startTime!.hour}:${_startTime!.minute}"
                              : 'Select Time',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text('Select End Time: '),
                      TextButton(
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _endTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          _endTime != null
                              ? "${_endTime!.hour}:${_endTime!.minute}"
                              : 'Select Time',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text('Enable Notifications: '),
                      Checkbox(
                        value: _enableNotifications,
                        onChanged: (value) {
                          setState(() {
                            _enableNotifications = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      // Call your scheduleNotification function here
                      final meetingName = _meetingNameController.text;
                      scheduleNotification(
                        meetingName,
                        _selectedDate,
                        _enableNotifications,
                        startTime: _startTime,
                        endTime: _endTime,
                      );
                      // Optionally, navigate to the ScheduledMeetingsScreen and pass the data as a Map
                      Navigator.of(context).pop({
                        'meetingName': meetingName,
                        'selectedDate': _selectedDate,
                        'startTime': _startTime,
                        'endTime': _endTime,
                      });
                    },
                    child: const Text('Schedule Meeting'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

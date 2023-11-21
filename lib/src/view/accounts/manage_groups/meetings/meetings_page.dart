import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/src/view/accounts/manage_groups/meetings/schedule_meetings.dart';

class ScheduledMeetingsScreen extends StatefulWidget {
  const ScheduledMeetingsScreen({super.key});

  @override
  _ScheduledMeetingsScreenState createState() =>
      _ScheduledMeetingsScreenState();
}

class _ScheduledMeetingsScreenState extends State<ScheduledMeetingsScreen> {
  List<Map<String, dynamic>> meetings =
      []; // Initialize meetings as a list of maps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Scheduled Meetings',
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
      body: meetings.isEmpty
          ? const Center(
              child: Text('No meetings available.'),
            )
          : ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                final meetingName = meeting['meetingName'] as String;
                final selectedDate = meeting['selectedDate'] as DateTime;
                final startTime = meeting['startTime'] as TimeOfDay;
                final endTime = meeting['endTime'] as TimeOfDay;

                final now = DateTime.now();
                final meetingDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                // Check if the meeting date and time have passed
                if (meetingDateTime.isBefore(now)) {
                  // Skip this meeting and do not add it to the list of widgets
                  return const SizedBox.shrink();
                }

                final formattedDate =
                    DateFormat('MMMM d, y').format(selectedDate);
                final formattedStartTime = _formatTimeOfDay(startTime);
                final formattedEndTime = _formatTimeOfDay(endTime);

                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 1, 67, 3),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                meetingName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Meeting Date:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(formattedDate),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text(
                                        'Start Time:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(formattedStartTime),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Text(
                                        'End Time:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(formattedEndTime),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  const Divider(),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Remove the meeting when the delete button is pressed
                                        setState(() {
                                          meetings.removeAt(index);
                                        });
                                      },
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // Align the Row's contents to the right
                                        children: [
                                          Text(
                                            'Cancel Meeting',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the meeting scheduling screen and wait for a result
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MeetingSchedular(),
            ),
          ) as Map<String, dynamic>?;

          if (result != null) {
            // Extract the data and add it to the list
            final meetingName = result['meetingName'] as String;
            final selectedDate = result['selectedDate'] as DateTime;
            final startTime = result['startTime'] as TimeOfDay;
            final endTime = result['endTime'] as TimeOfDay;

            setState(() {
              meetings.add({
                'meetingName': meetingName,
                'selectedDate': selectedDate,
                'startTime': startTime,
                'endTime': endTime,
              });
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime);
  }
}

import 'package:flutter/material.dart';

import '../../../../../database/localStorage.dart';
import 'meeting_details_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  List<Map<String, dynamic>> meetings = []; // Store the list of meetings

  @override
  void initState() {
    super.initState();
    // Fetch the list of meetings when the screen loads
    _fetchMeetings();
  }

  // Function to fetch meetings from the database
  _fetchMeetings() async {
    List<Map<String, dynamic>> fetchedMeetings =
        await DatabaseHelper.instance.getAllMeetings();
    setState(() {
      meetings = fetchedMeetings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Previous Meetings',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height -
            kToolbarHeight, // Subtract the height of the AppBar
        child: Container(
          decoration: const BoxDecoration(color: Color.fromARGB(255, 197, 250, 198)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color.fromARGB(255, 235, 233, 233),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListTile(
                          title: Text('Meeting ID: ${meeting['id']}'),
                          subtitle: Text('Date: ${meeting['date']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              // Navigate to the MeetingDetailsScreen with meeting details
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MeetingDetailsScreen(meeting: meeting),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

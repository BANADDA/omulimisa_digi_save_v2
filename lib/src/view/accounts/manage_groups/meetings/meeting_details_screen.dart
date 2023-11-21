import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class MeetingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const MeetingDetailsScreen({super.key, required this.meeting});

  String calculateDuration() {
    // Parse the time and end time strings using DateFormat
    DateFormat timeFormat = DateFormat('hh:mm a');
    DateTime startTime = timeFormat.parse(meeting['time']);
    DateTime endTime = timeFormat.parse(meeting['endTime']);

    // Calculate the difference between start and end times
    Duration duration = endTime.difference(startTime);

    // Format the start and end times as desired (e.g., 'hh:mm a')
    String formattedStartTime = DateFormat('hh:mm a').format(startTime);
    String formattedEndTime = DateFormat('hh:mm a').format(endTime);

    // Format the duration as hours and minutes
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return 'Duration: $minutes minutes\nStart Time: $formattedStartTime\nEnd Time: $formattedEndTime';
    } else {
      return 'Duration: $hours hours $minutes minutes\nStart Time: $formattedStartTime\nEnd Time: $formattedEndTime';
    }
  }

  void _printMeetingMinutes(BuildContext context) {
    Printing.layoutPdf(
      onLayout: (format) {
        return generateMeetingMinutes(format);
      },
    );
  }

  Future<Uint8List> generateMeetingMinutes(PdfPageFormat format) {
    final pdf = pw.Document();

    // Add your meeting minutes content here using pdf widgets
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Text('Meeting Minutes Content'),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    // Parse attendanceData and representativeData from JSON strings to maps
    final Map<String, dynamic> attendanceData =
        json.decode(meeting['attendanceData']);
    final Map<String, dynamic> representativeData =
        json.decode(meeting['representativeData']);

    // Parse meeting purpose and objectives
    final String meetingPurpose = meeting['meetingPurpose'];
    final List<String> objectives =
        (meeting['objectives'] as String).split(', ');

    // Parse next meeting proposals
    final List<String> proposals = (meeting['proposals'] as String).split(', ');

    final Map<String, dynamic> assignedFunds =
        json.decode(meeting['assignedFunds']);

    return RepaintBoundary(
      key: GlobalKey(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 88, 3),
            title: const Text(
              'Meeting Minutes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Scaffold(
              backgroundColor: const Color.fromARGB(255, 225, 253, 227),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Meeting ID: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 35,
                                  ),
                                  Text(
                                    '${meeting['id']}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Text(
                                    'Date: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 75,
                                  ),
                                  Text(
                                    '${meeting['date']}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Text(
                                    'Time: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 75,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${meeting['time']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      const Text('-',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue)),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        '${meeting['endTime']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Text(
                                    'Facilitator: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  Text(
                                    '${meeting['facilitator']}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Text(
                                    'Location: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 45),
                                  Expanded(
                                    child: Text(
                                      '${meeting['address']} (${meeting['latitude']}, ${meeting['longitude']})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Member Attendence: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        attendanceData.entries.map((entry) {
                                      final attendeeName = entry.key;
                                      final attendanceStatus = entry.value;
                                      String statusText;
                                      Color statusColor;
                                      FontWeight fontWeight;
                                      double fontSize;

                                      if (attendanceStatus['Green']) {
                                        statusText = 'Present';
                                        statusColor = Colors.green;
                                        fontWeight = FontWeight.bold;
                                        fontSize = 14.0;
                                      } else if (attendanceStatus['Orange']) {
                                        statusText = 'Represented';
                                        statusColor = const Color.fromARGB(
                                            255, 207, 125, 2);
                                        fontWeight = FontWeight.bold;
                                        fontSize = 14.0;
                                      } else if (attendanceStatus['Red']) {
                                        statusText = 'Absent';
                                        statusColor = Colors.red;
                                        fontWeight = FontWeight.bold;
                                        fontSize = 14.0;
                                      } else {
                                        statusText = 'Unknown';
                                        statusColor = Colors.black;
                                        fontWeight = FontWeight.bold;
                                        fontSize = 14.0;
                                      }

                                      return Row(
                                        children: [
                                          Text('$attendeeName:',
                                              style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: fontWeight)),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: fontWeight,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Representatives:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 15,
                              ),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(3),
                                },
                                children: [
                                  const TableRow(
                                    children: [
                                      Text(
                                        'Member',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 204, 123, 2)),
                                      ),
                                      Text(
                                        'Representative',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 204, 123, 2)),
                                      ),
                                    ],
                                  ),
                                  ...representativeData.entries
                                      .where((entry) => entry.value != null)
                                      .map((entry) {
                                    final attendeeName = entry.key;
                                    final representativeName = entry.value;

                                    return TableRow(
                                      children: [
                                        Text(
                                          '$attendeeName: ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          representativeName,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blue),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                          // Display assigned funds section
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Assigned Social Funds:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: assignedFunds.entries.map((entry) {
                                    final memberName = entry.key;
                                    final assignedAmount = entry.value;
                                    return Row(
                                      children: [
                                        Text(
                                          '$memberName:',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          'UGX ${assignedAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Meeting Purpose:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(meetingPurpose),
                              const Divider()
                            ],
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Meeting Objectives:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: objectives
                                    .map((objective) => Row(
                                          children: [
                                            const Text(
                                              '✓ ',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green),
                                            ),
                                            Text(
                                              objective,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Next Meeting Proposals:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: proposals
                                    .map((proposals) => Row(
                                          children: [
                                            const Text(
                                              '• ',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green),
                                            ),
                                            Text(
                                              proposals,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        )),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _printMeetingMinutes(context);
                            },
                            child: const Text('Print Minutes'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}

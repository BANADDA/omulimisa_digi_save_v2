import 'package:flutter/material.dart';

import '../../../users/data_repository.dart';

class SummaryReport extends StatefulWidget {
  const SummaryReport({super.key});

  @override
  State<SummaryReport> createState() => _SummaryReportState();
}

class _SummaryReportState extends State<SummaryReport> {
  bool isAscending = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Membership Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the icon color to white
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DataTable(
              sortAscending: isAscending,
              sortColumnIndex: 1,
              columnSpacing: 35.0,
              columns: [
                DataColumn(
                  label: const Text(
                    'Name',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  onSort: (index, b) {
                    setState(() {
                      // Sort the membersData list based on name.
                      membersData.sort((a, b) => a.name.compareTo(b.name));
                    });
                  },
                ),
                DataColumn(
                  label: const Text(
                    'Age',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      isAscending = ascending;
                      // Sort the membersData list based on age.
                      ascending
                          ? membersData.sort(
                              (a, b) => a.startDate.compareTo(b.startDate))
                          : membersData.sort(
                              (a, b) => b.startDate.compareTo(a.startDate));
                    });
                  },
                ),
                const DataColumn(
                  label: Text(
                    'Membership',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                ),
                // Add other DataColumn widgets for additional properties.
              ],
              rows: membersData.map((member) {
                return DataRow(
                  cells: [
                    DataCell(Text(member.name)), // Display member name.
                    DataCell(Text(member.startDate
                        .toString())), // Display member age or start date.
                    DataCell(Text(member.membershipType
                        .toString())), // Display membership type.
                    // Add other DataCell widgets for additional properties.
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

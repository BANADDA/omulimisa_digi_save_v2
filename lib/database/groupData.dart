import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

Future<void> getGroups(
  String retrieveEndpoint,
  String tableName,
  String token,
) async {
  print('======= Meeting data for table========');
  print(tableName);
  final database = await openDatabase('app_database.db');
  final serverDataResponse = await http.get(
    Uri.parse(retrieveEndpoint),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );
  print('Test $tableName response: $serverDataResponse');
  // Inside the 'getGroups' function
  if (serverDataResponse.statusCode == 200) {
    // Step 4: Clear local SQLite database for this table
    await database.rawDelete('DELETE FROM $tableName');

    // Reset the auto-increment counter for the primary key column
    await database.rawDelete(
        'DELETE FROM sqlite_sequence WHERE name = ?', ['$tableName']);
    final Map<String, dynamic>? responseData =
        json.decode(serverDataResponse.body);

    // Check if responseData is not null
    if (responseData != null) {
      print('$tableName response: $responseData');

      for (final key in responseData.keys) {
        if (key != 'status') {
          final List<dynamic> tableData = responseData[key];
          print('Table name: $tableData');

          if (tableData.isNotEmpty) {
            print('Here');
            for (final data in tableData) {
              final Map<String, dynamic> rowData =
                  {}; // Create a new map for each row
              for (final key in data.keys) {
                rowData[key] = data[key]; // Add key-value pairs to the map
              }

              final columns = rowData.keys.join(', ');

              print('Inserted columns: ${data}');
              final values =
                  List.generate(rowData.length, (index) => '?').join(', ');

              if (columns.isNotEmpty && values.isNotEmpty) {
                final query = 'INSERT INTO $key ($columns) VALUES ($values)';
                final args = rowData.values.toList();

                await database.rawInsert(query, args);
              } else {
                print('Columns or values are empty. Skipping insertion.');
              }
            }

            // Step 4: Update the sync flag to 1 for all rows in that table
            await database.rawUpdate('UPDATE $tableName SET sync_flag = 1');
            continue;
          } else {
            print('Server is empty');
          }
        }
      }
    } else {
      print('Response for $tableName is null or not a map');
    }
  }

  print('========End Meeting data for table========');
  print(tableName);
}

Future<void> sendGroups(String sendEndpoint, String tableName,
    List<Map<String, Object?>> unsyncedData, String token) async {
  print('========Meeting data for table========');
  print(tableName);
  final database = await openDatabase('app_database.db');
  print('Unsynced data for table $tableName: $unsyncedData');
  for (final data in unsyncedData) {
    final dataToSend = Map.from(data);
    if (tableName != 'positions') {
      // dataToSend.remove('id');
      try {
        final response = await http.post(
          Uri.parse(sendEndpoint),
          body: json.encode(dataToSend),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        );
        print('$tableName response: $response');

        if (response.statusCode == 200) {
          // Data uploaded successfully, update sync_flag to 1 in local SQLite
          await database.rawUpdate(
            'UPDATE $tableName SET sync_flag = ? WHERE id = ?',
            [1, data['id']],
          );
          print('Success');
        } else {
          print(response.body);
        }
      } catch (e) {
        print('Error uploading data $data for table $tableName: $e');
      }
    }
    print('========End Meeting data for table========');
    print(tableName);
  }
}

Future<void> syncDataGroupWithApi() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final database = await openDatabase('app_database.db');
  final userEndpoint = {
    'group_profile': {
      'sendEndpoint': '${ApiConstants.baseUrl}/group_profiles/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/group_profiles/',
    },
    'constitution_table': {
      'sendEndpoint': '${ApiConstants.baseUrl}/constitution_tables/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/constitution_tables/',
    },
    'cycle_schedules': {
      'sendEndpoint': '${ApiConstants.baseUrl}/cycle_schedules/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/cycle_schedules/',
    },
    'group_members': {
      'sendEndpoint': '${ApiConstants.baseUrl}/group_members/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/group_members/',
    },
    'assigned_positions': {
      'sendEndpoint': '${ApiConstants.baseUrl}/assigned_positions/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/assigned_positions/',
    },
    'group_form': {
      'sendEndpoint': '${ApiConstants.baseUrl}/group_forms/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/group_forms/',
    },
    'group_fees': {
      'sendEndpoint': '${ApiConstants.baseUrl}/group_fees/',
      'retrieveEndpoint': '${ApiConstants.baseUrl}/group_fees/',
    },
  };
  for (final tableName in userEndpoint.keys) {
    final endpoints = userEndpoint[tableName];
    final sendEndpoint = endpoints!['sendEndpoint'];
    final retrieveEndpoint = endpoints['retrieveEndpoint'];

    var tebleCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM $tableName'));
    if (tebleCount == 0) {
      getGroups(retrieveEndpoint!, tableName, token!);
    } else {
      final unsyncedData = await database.rawQuery(
        'SELECT * FROM $tableName WHERE sync_flag = ?',
        [0],
      );
      if (unsyncedData.isNotEmpty &&
          sendEndpoint != null &&
          retrieveEndpoint != null &&
          token != null) {
        // Step 4: Clear local SQLite database for this table

        await sendGroups(sendEndpoint, tableName, unsyncedData, token);
        await getGroups(retrieveEndpoint, tableName, token);
      } else if (retrieveEndpoint != null && token != null) {
        print('No Unsynced data');

        await getGroups(retrieveEndpoint, tableName, token);
      }
    }
  }
}

import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> getUsers(
    String retrieveEndpoint, String tableName, String token) async {
  final database = await openDatabase('app_database.db');
  final serverDataResponse =
      await http.get(Uri.parse(retrieveEndpoint), headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  });
  if (serverDataResponse.statusCode == 200) {
    // Step 4: Clear local SQLite database for this table
    await database.rawDelete('DELETE FROM $tableName');

    // Reset the auto-increment counter for the primary key column
    await database.rawDelete(
        'DELETE FROM sqlite_sequence WHERE name = ?', ['$tableName']);

    final Map<String, dynamic> responseData =
        json.decode(serverDataResponse.body);

    for (final key in responseData.keys) {
      if (key != 'status') {
        final List<dynamic> tableData = responseData[key];
        print('Table data: $tableData');

        if (tableData.isNotEmpty) {
          print('Here');
          for (final data in tableData) {
            final columns = data.keys
                .join(', '); // Create a comma-separated list of column names
            final values = List.generate(data.length, (index) => '?')
                .join(', '); // Create placeholders for values
            final query = 'INSERT INTO $key ($columns) VALUES ($values)';
            final args = data.values
                .toList(); // Get the values in the same order as the columns

            await database.rawInsert(query, args);
          }

          // Step 4: Update the sync flag to 1 for all rows in that table
          await database.rawUpdate('UPDATE $tableName SET sync_flag = 1');
          final data = await database.query(tableName);
          continue;
        } else {
          print('Server is empty');
        }
      }
    }
  }
}

Future<void> sendUsers(String sendEndpoint, String tableName,
    List<Map<String, Object?>> unsyncedData, String token) async {
  final database = await openDatabase('app_database.db');
  for (final data in unsyncedData) {
    final dataToSend = Map.from(data);
    dataToSend.remove('id');
    try {
      final response = await http.post(
        Uri.parse(sendEndpoint!),
        body: json.encode(dataToSend),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );
      // print('Response: $response');
      // print('Data: ${json.encode(dataToSend)}');

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
      // print('Error uploading data $data for table $tableName: $e');
    }
  }
}

Future<void> syncUserDataWithApi() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final database = await openDatabase('app_database.db');

  if (await checkInternetConnectivity()) {
    final userEndpoint = {
      'users': {
        'sendEndpoint': '${ApiConstants.baseUrl}/users/',
        'retrieveEndpoint': '${ApiConstants.baseUrl}/users/',
      },
    };
    try {
      for (final tableName in userEndpoint.keys) {
        final endpoints = userEndpoint[tableName];
        final sendEndpoint = endpoints!['sendEndpoint'];
        final retrieveEndpoint = endpoints['retrieveEndpoint'];

        var userCount = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM users'));
        if (userCount == 0 && token != null) {
          getUsers(retrieveEndpoint!, tableName, token);
        } else {
          final unsyncedData = await database.rawQuery(
            'SELECT * FROM $tableName WHERE sync_flag = ?',
            [0],
          );
          if (unsyncedData.isNotEmpty && token != null) {
            // Step 4: Clear local SQLite database for this table
            try {
              sendUsers(sendEndpoint!, tableName, unsyncedData, token);
              getUsers(retrieveEndpoint!, tableName, token);
            } on Exception catch (e) {
              print('Error: $e');
            }
          } else if (token != null) {
            print('Getting data');
            getUsers(retrieveEndpoint!, tableName, token);
          }
        }
      }
    } catch (e) {
      print('Error uploading user data: $e');
    }
  }
}

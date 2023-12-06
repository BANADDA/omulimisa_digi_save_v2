import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'localStorage.dart';
import 'location.dart';

Future<void> fetchAndSaveLocations() async {
  final response =
      await http.get(Uri.parse('${ApiConstants.baseUrl}/locations/'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);

    final List<District> districts =
        (data['districts'] as List<dynamic>).map((item) {
      return District(id: item['id'] as String, name: item['name'] as String);
    }).toList();

    final List<Subcounty> subcounties =
        (data['subcounties'] as List<dynamic>).map((item) {
      return Subcounty(id: item['id'] as String, name: item['name'] as String);
    }).toList();

    final List<Village> villages =
        (data['villages'] as List<dynamic>).map((item) {
      return Village(id: item['id'] as String, name: item['name'] as String);
    }).toList();

    DatabaseHelper dbHelper = DatabaseHelper.instance;

    // Delete existing data before inserting new data
    await dbHelper.deleteDistricts();
    await dbHelper.deleteSubcounties();
    await dbHelper.deleteVillages();

    // Save districts to SQLite
    await dbHelper.saveDistrictsToDatabase(districts);

    // Save subcounties to SQLite
    await dbHelper.saveSubcountiesToDatabase(subcounties);

    // Save villages to SQLite
    await dbHelper.saveVillagesToDatabase(villages);
  } else {
    throw Exception('Failed to load locations');
  }
}

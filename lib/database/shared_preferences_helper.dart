import 'package:omulimisa_digi_save_v2/database/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? userToken;

// Fetch the user token from shared preferences
Future<String?> fetchUserToken() async {
  final prefs = await SharedPreferences.getInstance();
  userToken = prefs.getString(AppConstants.userTokenKey);
  return userToken;
}

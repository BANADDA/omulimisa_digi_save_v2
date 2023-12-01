import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:omulimisa_digi_save_v2/database/groupData.dart';
import 'package:omulimisa_digi_save_v2/database/userData.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/localStorage.dart';
import 'database/meetingData.dart';
import 'database/notification_helper.dart';
import 'database/positions.dart';
import 'src/view/accounts/groups/forms/groupProfile/group_profile.dart';
import 'src/view/accounts/groups/group_start.dart';
import 'src/view/accounts/manage_groups/Loans/loan_status.dart';
import 'src/view/accounts/manage_groups/dashbord.dart';
import 'src/view/accounts/manage_groups/meetings/schedule_meetings.dart';
import 'src/view/accounts/manage_groups/members/reports/membership_summary.dart';
import 'src/view/accounts/users/edit_profile.dart';
import 'src/view/authentication/login_screen.dart';
import 'src/view/authentication/signup_screen.dart';
import 'src/view/screens/home_screen.dart';
import 'src/view/screens/start_screen.dart';
import 'src/view/widgets/user_class.dart';
import 'package:http/http.dart' as http;

// Load user data from shared preferences
Future<User?> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('User data: $token');
  final userFirstName = prefs.getString('userFirstName');
  final userLastName = prefs.getString('userLastName');

  if (token != null && userFirstName != null && userLastName != null) {
    return User(
      token: token,
      firstName: userFirstName,
      lastName: userLastName,
    );
  } else {
    return null; // User data not found in shared preferences
  }
}

// Future<void> initializeSharedPreferences() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

//   if (isFirstRun) {
//     // Call your function here
//     syncUserDataWithApi();
//     syncpositionWithApi();
//     syncDataGroupWithApi();
//     syncDataMeetingWithApi();

//     // Set isFirstRun to false to indicate that the function has been called
//     prefs.setBool('isFirstRun', false);
//   }
// }

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

void main() async {
  // showNoInternetSnackBar(context);
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your notification service
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  initializeNotifications();
  WidgetsFlutterBinding.ensureInitialized();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  await dbHelper.database;
  //

  final User? user = await loadUserData();

  runApp(
    MyApp(
      initialRoute: user != null
          ? '/startSCreen'
          : '/', // Set the initial route based on login status
      user: user, // Pass the user object to MyApp
    ),
  );
}

void initializeFilePicker() {
  FilePicker.platform = FilePicker.platform;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final User? user;

  const MyApp({Key? key, required this.initialRoute, this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // startSynchronizationTimer(context);
    initializeFilePicker();

    return WillPopScope(
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        title: 'DigiSave VSLA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 103, 255, 108)),
          useMaterial3: true,
        ),
        initialRoute: initialRoute, // Set the initial route
        routes: {
          '/login': (context) => const Loginscreen(),
          '/signup': (context) => const SignUpSCreen(),
          '/': (context) => const Homescreen(),
          '/startSCreen': (context) => const StartScreen(),
          '/userProfile': (context) => const ProfileScreen(),
          '/group': (context) => const GroupStart(),
          '/groupProfile': (context) => const GroupProfile(),
          '/membership_summary': (context) => const SummaryReport(),
          '/meeting_schedule': (context) => const MeetingSchedular(),
          '/dashboard': (context) => DashBoard(user: user),
          '/loan_status': (context) => const LoanStatus(),
        },
      ),
      onWillPop: () async {
        // Handle the back button press event here
        // Return true to prevent navigating back, or false to allow it
        return false;
      },
    );
  }
}

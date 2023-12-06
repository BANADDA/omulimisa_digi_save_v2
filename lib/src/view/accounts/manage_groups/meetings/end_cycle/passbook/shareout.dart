import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:standard_dialogs/standard_dialogs.dart';
import '../../../../../../../database/localStorage.dart';
import '../analysis/shareout_container.dart';
import 'package:lottie/lottie.dart';

class ShareOutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? shares;
  final num? shareOut;
  final String? groupId;
  final String? cycleId;

  const ShareOutScreen(
      {Key? key, this.shares, this.shareOut, this.groupId, this.cycleId})
      : super(key: key);

  @override
  State<ShareOutScreen> createState() => _ShareOutScreenState();
}

class _ShareOutScreenState extends State<ShareOutScreen> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  double totalShareQuantitySum = 0.0;
  Map<String, double> memberShareTotal = {};

  Future<String> fetchGroupMemberFullName(String groupMemberId) async {
    // Call the function to get the full names of the group member
    Map<String, dynamic> groupMemberNames =
        await DatabaseHelper.instance.getGroupMemberFullNames(groupMemberId);
    print('Group Members: $groupMemberNames');

    if (groupMemberNames != null) {
      String firstName = groupMemberNames['fname'];
      String lastName = groupMemberNames['lname'];

      // Return the full name of the group member
      return '$firstName $lastName';
    } else {
      // Return an error message if the group member is not found
      return 'Group member not found';
    }
  }

  List<Map<String, dynamic>> sharePurchases = [];

  Future<void> fetchSharePurchases(String cycleMeetingId, String groupId) async {
    sharePurchases = (await dbHelper.getMemberShares(groupId, cycleMeetingId))!;

    if (sharePurchases != null) {
      // print('Share Purchases: $sharePurchases');

      // Clear the memberShareTotal map before iterating over the sharePurchases list the second time
      memberShareTotal.clear();

      for (var purchase in sharePurchases) {
        var sharePurchasesList =
            json.decode(purchase['sharePurchases']); // Parse the JSON text

        // Check if the sharePurchasesList is empty before trying to parse it
        if (sharePurchasesList.isNotEmpty) {
          for (var share in sharePurchasesList) {
            String memberId = share['memberId'];
            double shareQuantity =
                share['shareQuantity'].toDouble(); // Convert to double

            // Check if the member already exists in the map, and update their total shareQuantity
            memberShareTotal[memberId] =
                (memberShareTotal[memberId] ?? 0) + shareQuantity;
          }
        }
      }

      // Print the total shareQuantity for each unique member
      memberShareTotal.forEach((memberId, totalShareQuantity) {
        print('memberShareTotal: $memberShareTotal');
        print('Member $memberId: Total Share Quantity = $totalShareQuantity');
      });
    } else {
      print('No sharePurchases found for the given parameters.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch share purchases when the screen is initialized
    print(('Group Id: ${widget.groupId}'));
    fetchSharePurchases(widget.cycleId!, widget.groupId!);
  }

  Future<void> navigateToUpdateProfile() async {
    final dbHelper = DatabaseHelper.instance;
    final groupId = widget.groupId;
    final cycleId = widget.cycleId;

    bool success = true;
    String errorMessage = '';

    for (String memberId in memberShareTotal.keys) {
      double shareValue = memberShareTotal[memberId]!;
      String? userId = await dbHelper.getUserIdFromGroupMember(
          await dbHelper.database, memberId);
      final data = {
        'group_id': groupId,
        'cycleId': cycleId,
        'user_id': userId,
        'share_value': shareValue,
      };
      print('Data: $data');

      try {
        await dbHelper.insertShareOut(data);
      } catch (error) {
        success = false;
        errorMessage = 'Share out failed for member ID $memberId: $error';
      }
    }

    if (success) {
      // ignore: use_build_context_synchronously
      Dialogs.materialDialog(
          color: Colors.white,
          msg: "You have successfully sharedout the group's savings",
          title: 'Congratulations',
          lottieBuilder: Lottie.asset(
            'assets/cong_example.json',
            fit: BoxFit.contain,
          ),
          context: context,
          actions: [
            IconsButton(
              onPressed: () {
                Navigator.pop(context, {'isNavigationEnabled': false});
                Navigator.pop(context, {'isNavigationEnabled': false});
                Navigator.pop(context, {'isNavigationEnabled': false});
                Navigator.pop(context, {'isNavigationEnabled': false});
              },
              text: 'Done',
              iconData: Icons.done,
              color: const Color.fromARGB(255, 0, 103, 4),
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('Share out successful'),
      // ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 219, 247, 220),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Group Shareout',
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
        body: FutureBuilder<void>(
          future: fetchSharePurchases(widget.cycleId!, widget.groupId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Snapshot Error: ${snapshot.error}'));
            } else {
              print('Snapshot data = $snapshot');
              return buildShareoutScreen();
            }
          },
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              SizedBox(
                width: 150, // Set a custom width
                height: 50, // Set a custom height
                child: FloatingActionButton(
                  onPressed: () {
                    navigateToUpdateProfile(); // Call the function to show the AwesomeDialog
                  },
                  backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Shareout Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // void showAwesomeDialog() {
  //   AwesomeDialog(
  //     context: context,
  //     dialogType: DialogType.warning,
  //     animType: AnimType.rightSlide,
  //     title: 'Shareout Alert',
  //     desc: "Are you sure you want to shareout the group's savings?",
  //     btnCancelOnPress: () {},
  //     btnOkOnPress: () {
  //       navigateToUpdateProfile();
  //     },
  //   ).show();
  // }

  Widget buildShareoutScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Final Group Members Shareout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 64, 64, 64),
                  ),
                ),
                const SizedBox(width: 25),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  color: const Color.fromARGB(255, 1, 99, 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.info,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          'Tips & Advice',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        const Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                            ),
                                            Text(
                                              'Final Shareout',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            "Distribute group savings among group members basing on the shares they hold and the share value of each share",
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color.fromARGB(200, 2, 121, 6)),
                    ),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.question_mark_rounded,
                        color: Color.fromARGB(200, 2, 121, 6),
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(
            height: 25,
          ),
          Column(
            children: memberShareTotal.keys.map((String memberId) {
              double totalShareQuantity = memberShareTotal[memberId] ?? 0.0;
              double shareValue = totalShareQuantity *
                  (widget.shareOut!); // Calculate shareValue as needed

              print('Membershares: $memberShareTotal');

              return FutureBuilder<String>(
                future: fetchGroupMemberFullName(memberId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print('Here loading');
                    return const Text('Loading...');
                  } else if (snapshot.hasError) {
                    print('Here error');
                    return Text('Snap share Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    print('Here success');
                    String groupMemberFullName = snapshot.data!;
                    return ShareoutContainer(
                      applicantName: groupMemberFullName,
                      sharesOwned: totalShareQuantity,
                      shareValue: shareValue,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

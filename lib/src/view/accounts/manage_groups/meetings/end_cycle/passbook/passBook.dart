import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import '/src/view/accounts/manage_groups/meetings/end_cycle/passbook/shareout.dart';

import '../../../../../../../database/localStorage.dart';

class PassBook extends StatefulWidget {
  final String groupId;
  final String cycleId;

  const PassBook({Key? key, required this.groupId, required this.cycleId})
      : super(key: key);

  @override
  State<PassBook> createState() => _PassBookState();
}

class _PassBookState extends State<PassBook> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  bool isNavigationEnabled = false;

  // Create a map to store the total shareQuantity for each unique member
  List<Map<String, dynamic>>? sharePurchases;
  Map<int, double> memberShareTotal = {};

  Future<void> getShares() async {
    final shares =
        await dbHelper.getMemberShares(widget.groupId, widget.cycleId);
    for (var share in shares!) {
      print('Share person: $share');
    }
  }

  Future<void> fetchSharePurchases(String cycleMeetingId, String groupId) async {
    print('cycle Id = $cycleMeetingId || group Id = $groupId');
    if (cycleMeetingId != null && groupId != null) {
      sharePurchases = await dbHelper.getMemberShares(groupId, cycleMeetingId);
      print('Fetched shares: $sharePurchases');

      if (sharePurchases != null) {
        for (var purchase in sharePurchases!) {
          var sharePurchasesList =
              json.decode(purchase['sharePurchases']); // Parse the JSON text

          for (var share in sharePurchasesList) {
            int memberId = share['memberId'];
            double shareQuantity =
                share['shareQuantity'].toDouble(); // Convert to double

            // Check if the member already exists in the map, and update their total shareQuantity
            memberShareTotal[memberId] =
                (memberShareTotal[memberId] ?? 0) + shareQuantity;
          }
        }

        // Print the total shareQuantity for each unique member
        memberShareTotal.forEach((memberId, totalShareQuantity) {
          print('Member $memberId: Total Share Quantity = $totalShareQuantity');
        });
      } else {
        print('No sharePurchases found for the given parameters.');
      }
    } else {
      print('No sharePurchases found for the given parameters.');
      print('Error');
    }
  }

  Future<double> savingsAcocunt() async {
    double groupSavings =
        await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId);
    return groupSavings;
  }

  Map<int, double> calculateTotalShares(
      List<Map<String, dynamic>> memberShares) {
    Map<int, double> totalShares = {};

    for (var shareData in memberShares) {
      List<dynamic> sharePurchases = json.decode(shareData['sharePurchases']);

      for (var purchase in sharePurchases) {
        int? memberId = purchase['memberId'];
        double shareQuantity = purchase['shareQuantity'].toDouble();

        if (memberId != null) {
          totalShares[memberId] =
              (totalShares[memberId] ?? 0.0) + shareQuantity;
        }
      }
    }

    return totalShares;
  }

  List<Map<String, dynamic>> memberShares = [];
  Map<int, double> totalSharesByMember = {};

  // Future<double> retrieveSharePurchases(int cycleMeetingId, int groupId) async {
  //   if (widget.groupId != null && widget.cycleId != null) {
  //     memberShares = (await DatabaseHelper.instance
  //         .getMemberShares(groupId, cycleMeetingId))!;

  //     totalSharesByMember = calculateTotalShares(memberShares);

  //     double totalSum = totalSharesByMember.values
  //         .fold(0.0, (prev, element) => prev + element);

  //     setState(() {
  //       memberShares;
  //     });

  //     print('Member Shares: $totalSum');

  //     return totalSum;
  //   } else {
  //     return 0.0; // or return a default value as needed
  //   }
  // }

  Future<double> retrieveSharePurchases(String cycleMeetingId, String groupId) async {
    // Check if widget.groupId and widget.cycleId are not null
    if (widget.groupId != null && widget.cycleId != null) {
      // Get the member shares for the current cycle and group
      memberShares = (await DatabaseHelper.instance
          .getMemberShares(widget.groupId!, widget.cycleId!))!;

      totalSharesByMember = calculateTotalShares(memberShares);
      print('Member Shares: $totalSharesByMember');

      // Calculate the total sum of shares
      double totalSumOfShares =
          totalSharesByMember.values.fold(0, (a, b) => a + b);
      print('Total Sum of Shares: $totalSumOfShares');

      // setState(() {
      //   memberShares;
      // });

      return totalSumOfShares;
    } else {
      return 0.0; // or any other default value you prefer
    }
  }

  // Future<double> _loadSharesData() async {
  //   // print('Group Id: ${widget.groupId} Cycle Id ${widget.cycleId}');
  //   // Check if widget.groupId and widget.cycleId are not null
  //   if (widget.groupId != null && widget.cycleId != null) {
  //     // Get the member shares for the current cycle and group
  //     memberShares = (await DatabaseHelper.instance
  //         .getMemberShares(widget.groupId!, widget.cycleId!))!;

  //     totalSharesByMember = calculateTotalShares(memberShares);
  //     print('Member Shares: $totalSharesByMember');
  //     setState(() {
  //       memberShares;
  //     });
  //     double totalShares = 0.0;
  //     for (var member in memberShares) {
  //       totalShares += member['shareQuantity'].toDouble();
  //     }
  //     return totalShares;
  //   } else {
  //     return 0.0;
  //   }
  // }

  // Future<double> retrieveSharePurchases(int cycleMeetingId, int groupId) async {
  //   List<Map<String, dynamic>> sharePurchases = [];
  //   double totalShareQuantitySum = 0.0;
  //   if (cycleMeetingId != null && groupId != null) {
  //     sharePurchases =
  //         (await dbHelper.getMemberShares(groupId, cycleMeetingId))!;
  //     print('Fetched member shares = $sharePurchases');
  //     if (sharePurchases != []) {
  //       for (var purchase in sharePurchases) {
  //         var sharePurchasesList =
  //             json.decode(purchase['sharePurchases']); // Parse the JSON text

  //         for (var share in sharePurchasesList) {
  //           double shareQuantity = share['shareQuantity'].toDouble();
  //           totalShareQuantitySum += shareQuantity;
  //         }
  //       }
  //     } else {
  //       print('sharePurchases is empty');
  //     }
  //   } else {
  //     print('Null ids');
  //   }

  //   return totalShareQuantitySum;
  // }

  Future<double> retriveDefaultedLoan(String groupId) async {
    double defaultedLoans = 0.0;
    if (groupId != null) {
      defaultedLoans = await dbHelper.getSumOfActiveLoans(groupId);
    } else {}
    return defaultedLoans;
  }

  Future<double> getFines(String groupId, String cycleId) async {
    double totalFinesAmount = 0.0;
    if (cycleId == null && groupId == null) {
      print('Null Ids:');
    } else {
      totalFinesAmount = await dbHelper.getTotalFinesAmount(groupId, cycleId);
    }
    return totalFinesAmount;
  }

  Future<double> getInterests(String groupId, String cycleId) async {
    double totalLoanAmount = 0.0;
    double? interestRate =
        await DatabaseHelper.instance.getInterestRate(groupId);

    if (cycleId != null && groupId != null) {
      totalLoanAmount =
          await dbHelper.getTotalLoanDisbursement(groupId, cycleId);
    } else {}
    double interestsGained = totalLoanAmount * (interestRate! / 100);

    return interestsGained;
  }

  @override
  void initState() {
    getShares();
    fetchSharePurchases(widget.cycleId, widget.groupId);
    retriveDefaultedLoan(widget.groupId);
    super.initState();
  }

  String formatCurrency(double amount, String currencySymbol) {
    // Use the toFixed method to round the number to 2 decimal places.
    String formattedAmount = amount.toStringAsFixed(2);

    // Add commas as thousand separators.
    final parts = formattedAmount.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Combine the whole part and decimal part, and add the currency symbol.
    formattedAmount = '$currencySymbol $wholePart';

    return formattedAmount;
  }

  // ShareOutScreen.dart

  void navigateToUpdateProfile() {
    print('Pop context: $context');
    print('Pop value: ${{"isNavigationEnabled": false}}');
    Navigator.pop(context, {"isNavigationEnabled": false});
  }

// NavigatorViewMeeting.dart

  void NavigatorViewMeeting(
      List<Map<String, dynamic>> sharePurchases, double totalShareOut) {
    print('Navigating to ShareOutScreen');
    print('ShareOutScreen Shares: $sharePurchases');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShareOutScreen(
                shares: sharePurchases,
                shareOut: totalShareOut,
                cycleId: widget.cycleId,
                groupId: widget.groupId))).then((value) {
      print('Navigator.push returned: $value');
      if (value != null && value is Map) {
        setState(() {
          isNavigationEnabled = value['isNavigationEnabled'];
          print('Navigate: $isNavigationEnabled');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 247, 220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Members PassBook',
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
      body: FutureBuilder(
        future: Future.wait([
          retrieveSharePurchases(widget.groupId, widget.cycleId),
          getFines(widget.groupId, widget.cycleId),
          retriveDefaultedLoan(widget.groupId),
          getInterests(widget.groupId, widget.cycleId),
          savingsAcocunt(),
        ]),
        builder: (context, AsyncSnapshot<List<double>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              double totalShare = snapshot.data![0];
              double sharePurchase = snapshot.data![0] * 1000;
              double totalShareQuantitySum = snapshot.data![1];
              double defaultedLoanAmount = snapshot.data![2];
              double interestsGained = snapshot.data![3];
              double savingsAccount = snapshot.data![4];
              double totalSavings = savingsAccount - totalShareQuantitySum;
              double totalShareOut = totalSavings +
                  interestsGained +
                  totalShareQuantitySum +
                  totalShareQuantitySum -
                  totalShareQuantitySum;
              defaultedLoanAmount;
              double shareValue = totalShareOut / totalShare;

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
                            'Shareout Summary',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            color: const Color.fromARGB(
                                                255, 1, 99, 4),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(Icons.info,
                                                        size: 35,
                                                        color: Colors.white),
                                                  ),
                                                  const Text(
                                                    'Tips & Advice',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    onTap: () =>
                                                        Navigator.pop(context),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                      ),
                                                      Text(
                                                        'Shareout Data',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Text(
                                                      "View and manage group's accounts and share out expenses for the group members in this end cycle meeting",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600),
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
                                    color:
                                        const Color.fromARGB(200, 2, 121, 6)),
                              ),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.question_mark_rounded,
                                    color: Color.fromARGB(200, 2, 121, 6),
                                    size: 15),
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
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: const Text(
                              'Total Saving',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(formatCurrency(totalSavings, 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: const Text(
                              'loan Interests',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(
                                formatCurrency(interestsGained, 'UGX'),
                                // formatCurrency(interestsGained, 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: const Text(
                              'Total Fines',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(
                                formatCurrency(
                                    totalShareQuantitySum.toDouble(), 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: const Text(
                              'Defaulted Loans',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(
                                formatCurrency(defaultedLoanAmount, 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: Wrap(
                              children: [
                                const Text(
                                  'Shareout Amount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  color: const Color.fromARGB(
                                                      255, 1, 99, 4),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Icon(
                                                              Icons.info,
                                                              size: 35,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        const Text(
                                                          'Tips & Advice',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                  context),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                            ),
                                                            Text(
                                                              'Shareout Amount',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            "This is the total money in the savings acocunt after all expenses have been added",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        )
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
                                          color: const Color.fromARGB(
                                              200, 2, 121, 6)),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Icons.question_mark_rounded,
                                          color: Color.fromARGB(200, 2, 121, 6),
                                          size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(formatCurrency(totalShareOut, 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: const Text(
                              'Total Shares Owned',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            trailing: Text(totalShare.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 233, 233),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            title: Wrap(
                              children: [
                                const Text(
                                  'Current Share Value',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SingleChildScrollView(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  color: const Color.fromARGB(
                                                      255, 1, 99, 4),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Icon(
                                                              Icons.info,
                                                              size: 35,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        const Text(
                                                          'Tips & Advice',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () =>
                                                              Navigator.pop(
                                                                  context),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                            ),
                                                            Text(
                                                              'Share Value',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            "This is the amount each share costs in the current group constitution",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        )
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
                                          color: const Color.fromARGB(
                                              200, 2, 121, 6)),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Icons.question_mark_rounded,
                                          color: Color.fromARGB(200, 2, 121, 6),
                                          size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(formatCurrency(shareValue, 'UGX'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Dialogs.materialDialog(
                              msg:
                                  "Are you sure you want to shareout group's funds? you can\'t undo this",
                              title: "Shareout",
                              color: Colors.white,
                              context: context,
                              actions: [
                                IconsOutlineButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: 'No',
                                  iconData: Icons.cancel_outlined,
                                  textStyle: TextStyle(color: Colors.grey),
                                  iconColor: Colors.grey,
                                ),
                                IconsButton(
                                  onPressed: () {
                                    NavigatorViewMeeting(
                                        sharePurchases!, shareValue);
                                  },
                                  text: 'Yes',
                                  iconData: Icons.done,
                                  color: const Color.fromARGB(255, 1, 138, 6),
                                  textStyle: TextStyle(color: Colors.white),
                                  iconColor: Colors.white,
                                ),
                              ]);
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                            backgroundColor:
                                const Color.fromARGB(255, 0, 103, 4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        child: const Text(
                          'Shareout Now',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              );
            } else {
              print("Error fetching data ${snapshot.error.toString()}");
              return const Center(child: Text("Error fetching data"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

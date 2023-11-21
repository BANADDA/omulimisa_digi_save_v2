import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../../database/localStorage.dart';
import '../../start_meeting/Loans/PaymentInfo.dart';
import 'LoanContainer.dart';
import 'widgets/Debt.dart';
import 'widgets/accounts.dart';
import 'widgets/analytics_widget.dart';
import 'widgets/icon.dart';
import 'widgets/member.dart';

class Analystics extends StatefulWidget {
  final int? groupId;
  final int? cycleId;
  const Analystics({super.key, this.groupId, this.cycleId});

  @override
  State<Analystics> createState() => _AnalysticsState();
}

class _AnalysticsState extends State<Analystics> {
  List<Map<String, dynamic>>? shares;
  double loanFund = 0.0; // Initialize loanFund
  double loanAmount = 0.0;
  String defaultImage = '';
  @override
  void initState() {
    super.initState();
    _loadSharesData();
    _loadLoanData();
    // _loadDefaultImage();
    // _loadSharesData();
    groupAccountsAfter();
  }

  double groupSavings = 0.0;
  double activeLoansDetails = 0.0;

  final currencyFormat = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );

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
  List<Map<String, dynamic>> memberLoans = [];
  Map<int, double> totalSharesByMember = {};
  Map<int, double> totalLoansByMember = {};

  Future<List<Map<String, dynamic>>> _loadSharesData() async {
    // print('Group Id: ${widget.groupId} Cycle Id ${widget.cycleId}');
    // Check if widget.groupId and widget.cycleId are not null
    if (widget.groupId != null && widget.cycleId != null) {
      // Get the member shares for the current cycle and group
      memberShares = (await DatabaseHelper.instance
          .getMemberShares(widget.groupId!, widget.cycleId!))!;
      print('Member Shares: $memberShares');

      totalSharesByMember = calculateTotalShares(memberShares);
      setState(() {
        memberShares;
      });
      return memberShares;
    } else {
      return [];
    }
  }

  int loanId = 0;

  Future<List<Map<String, dynamic>>> _loadLoanData() async {
    // print('Group Id: ${widget.groupId} Cycle Id ${widget.cycleId}');
    // Check if widget.groupId and widget.cycleId are not null
    if (widget.groupId != null && widget.cycleId != null) {
      // Get the member shares for the current cycle and group
      memberLoans =
          (await DatabaseHelper.instance.getMemberActiveLoans(widget.groupId!));
      print('Member Loan Data: $memberLoans');

      setState(() {
        memberLoans;
      });
      return memberLoans;
    } else {
      return [];
    }
  }

  void _calculateLoanFund() {
    double totalSavings = 0.0;

    if (shares != null) {
      for (var share in shares!) {
        List<Map<String, dynamic>> sharePurchases =
            (json.decode(share['sharePurchases']) as List<dynamic>)
                .cast<Map<String, dynamic>>();

        for (var purchase in sharePurchases) {
          double shareQuantity = purchase['shareQuantity'].toDouble();
          totalSavings += shareQuantity * 2000.0;
        }
      }
    }

    setState(() {
      loanFund = totalSavings;
    });
  }

  int memberId = 0;

  Future<List<Widget>> _buildMemberLoansWidgets() async {
    List<Widget> widgets = [];
    Set<int> memberIds = {};

    if (shares != null) {
      for (var share in shares!) {
        List<Map<String, dynamic>> sharePurchases =
            (json.decode(share['sharePurchases']) as List<dynamic>)
                .cast<Map<String, dynamic>>();

        for (var purchase in sharePurchases) {
          int memberId = purchase['memberId'];
          double shareQuantity = purchase['shareQuantity'];
          String memberName = purchase['memberName'];

          if (memberIds.contains(memberId)) {
            continue; // Skip if loan data has already been retrieved for this member
          }

          List<Map<String, dynamic>>? memberLoansData = await DatabaseHelper
              .instance
              .getMemberLoans(widget.groupId!, memberId);

          for (var loanData in memberLoansData!) {
            double? loanAmount = loanData['amount_needed'] as double?;
            loanId = loanData['id'];
            memberId = loanData['member_id'];
            String? repaymentDate = loanData['repayment_date'] as String?;
            String formattedRepaymentDate = repaymentDate != null
                ? DateFormat('d MMM y').format(DateTime.parse(repaymentDate))
                : 'No Date Available';

            print('Loan Data: $loanData');

            final imageData =
                await DatabaseHelper.instance.getImagePathForMember(memberId);
            Uint8List? bytesImage = imageData != null
                ? const Base64Decoder().convert(imageData)
                : null;

            if (loanAmount != null &&
                repaymentDate != null &&
                bytesImage != null) {
              widgets.add(MemberDebt(
                personName: memberName,
                bytesImage: bytesImage,
                loanAmount: currencyFormat.format(loanAmount),
                dueDate: formattedRepaymentDate,
              ));
            }
          }

          memberIds.add(
              memberId); // Add member ID to Set to avoid retrieving loan data again
        }
      }
    }

    return widgets;
  }

  String formattedSavings = '';
  String formattedloans = '';

  Future<Map<String, double>> groupAccountsAfter() async {
    // Fetch Total Savings
    groupSavings =
        await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId!);
    print('New Savings: UGX $groupSavings');

    // Fetch active loans
    activeLoansDetails = await DatabaseHelper.instance
        .getTotalActiveLoanAmountForGroup(widget.groupId!);
    print('Total Active Loan Amount: UGX $activeLoansDetails');
    setState(() {
      formattedSavings = formatCurrency(groupSavings, 'UGX');
      print('Formated: $formattedSavings');
      formattedloans = formatCurrency(activeLoansDetails, 'UGX');
    });

    return {
      'groupSavingsAfter': groupSavings,
      'activeLoansDetailsAfter': activeLoansDetails
    };
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
    formattedAmount = '$currencySymbol $wholePart.${parts[1]}';

    return formattedAmount;
  }

  Future<String> fetchGroupMemberFullName(int groupMemberId) async {
    // Call the function to get the full names of the group member
    Map<String, dynamic> groupMemberNames =
        await DatabaseHelper.instance.getGroupMemberFullNames(groupMemberId);

    if (groupMemberNames != null) {
      String firstName = groupMemberNames['fname'];
      String lastName = groupMemberNames['lname'];

      return '$firstName $lastName';
    } else {
      return 'Group member not found';
    }
  }

  Future<void> clearLoan(int groupId, int memberId, double loanAmount,
      int loanId, double amountNeeded) async {
    print('Here');
    // Add your logic to clear the loan and update shares owned and total savings
    // For example, deduct loanAmount from shares owned
    print('Member Id: $memberId');

    print('TotaL Shares: ${totalSharesByMember[memberId]!}');
    // double updatedShares =
    //     ((totalSharesByMember[memberId]!) - (loanAmount / 2000));
    print('loanAmount: $loanAmount');
    double updatedShares = loanAmount / 2000;
    double updatedSavings = loanAmount;
    print('Bug: ${(loanAmount)}');

    print('New Shares: $updatedShares');

    // Update shares and savings in the database
    String formatDateWithoutTime(DateTime dateTime) {
      final formatter = DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
      return formatter.format(dateTime);
    }

    String dateWithoutTime = formatDateWithoutTime(DateTime.now().toLocal());

    final prefs = await SharedPreferences.getInstance();
    final loggedInUserId = prefs.getInt('userId');
    List<Map<String, dynamic>> sharePurchasesList = [];
    // String memberName = fetchGroupMemberFullName(memberId) as String;
    sharePurchasesList.add({
      'memberId': memberId,
      'memberName': await fetchGroupMemberFullName(memberId),
      'shareQuantity': -updatedShares,
    });

    final deductionData = {
      'group_id': groupId,
      'logged_in_user_id': loggedInUserId,
      'date': dateWithoutTime,
      'purpose': 'Loan Repayment',
      'amount': updatedSavings,
    };
    final encodedSharePurchases = json.encode(sharePurchasesList);

    Map<String, dynamic> memberShareData = {
      'group_id': groupId,
      'cycle_id': widget.cycleId,
      'meetingId': 0,
      'logged_in_user_id': loggedInUserId,
      'date': dateWithoutTime,
      'sharePurchases': encodedSharePurchases,
    };
    print('Share data: $memberShareData');
    await DatabaseHelper.instance.insertMemberShare(memberShareData);

    print('Member Shares Inserted: $memberShareData');
    //Loan payment
    DateTime now = DateTime.now();
    DateTime paymentDate = DateTime(now.year, now.month, now.day);

    PaymentInfo paymentInfo = PaymentInfo(
      groupId: groupId,
      loanId: loanId,
      memberID: memberId,
      amount: loanAmount,
      paymentDate: paymentDate,
    );
    print('Payment Data: $paymentInfo');

    await DatabaseHelper.instance.savePaymentInfo(paymentInfo);
    final savingsAccount =
        await DatabaseHelper.instance.insertSavingsAccount(deductionData);
    double remainingBalance = amountNeeded - loanAmount;
    print('amountNeeded: $amountNeeded');
    print('loanAmount: $loanAmount');
    print('Remaining balance: $remainingBalance');
    if (remainingBalance <= 0.0) {
      print('Updating loan status to Cleared for loan id: $loanId');
      await DatabaseHelper.instance
          .updateLoanStatus(widget.groupId!, loanId, memberId, 'Cleared');
      print('Savings Account Inserted for $savingsAccount: $deductionData');
      // Reload the data to reflect the changes
      await _loadSharesData();
      await groupAccountsAfter();
      await _loadLoanData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 226, 243, 226),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Group Analytics',
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(0.0),
                margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
                child: Column(children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Column(
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Group Savings',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Accounts(
                          leftText: 'Group Savings',
                          rightText: formattedSavings,
                          leftTextColor:
                              const Color.fromARGB(255, 105, 104, 104),
                          rightTextColor: const Color.fromARGB(255, 0, 128, 4),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        const Center(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Current Accounts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const AnalyticsWidget(
                            title: 'Social Fund',
                            subtitle: 'Social fund bag',
                            amount: 'UGX 3,000,000',
                            customIcon: CustomDonationIcon(
                              imageAssetPath: 'assets/charity.png',
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        AnalyticsWidget(
                            title: 'Loan Amount',
                            subtitle: 'Money loaned to members',
                            amount: formattedloans,
                            customIcon: const CustomDonationIcon(
                              imageAssetPath: 'assets/signature.png',
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Member Savings',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: totalSharesByMember.entries.map((entry) {
                              int memberId = entry.key;
                              double totalShares = entry.value;

                              return FutureBuilder<String>(
                                future: fetchGroupMemberFullName(memberId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      String? fullName = snapshot.data;
                                      return UserProfileContainer(
                                        personName: fullName!,
                                        sharesOwned: double.parse(
                                            totalShares.toStringAsFixed(2)),
                                        totalSavings: totalShares.toDouble(),
                                      );
                                    } else {
                                      return const Text(
                                          "Group member not found");
                                    }
                                  } else {
                                    return const CircularProgressIndicator(); // Show a loading indicator while waiting for data
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Current Loans',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: memberLoans.isNotEmpty
                              ? memberLoans.map((loanData) {
                                  String loanApplicant =
                                      loanData['loan_applicant'];
                                  double loanAmount = loanData['loan_amount'];
                                  double interestRate =
                                      loanData['interest_rate'];
                                  String loanPurpose = loanData['loan_purpose'];

                                  return FutureBuilder<String>(
                                    builder: (context, snapshot) {
                                      String fullName = loanApplicant;
                                      return LoanContainer(
                                        applicantName: fullName,
                                        loanAmount: loanAmount,
                                        interestRate: interestRate,
                                        loanPurpose: loanPurpose,
                                        onClearLoanPressed: () {
                                          clearLoan(
                                              widget.groupId!,
                                              loanData['member_id'],
                                              loanAmount,
                                              loanData['id'],
                                              loanData['loan_amount']);
                                        },
                                      );
                                    },
                                    future: null,
                                  );
                                }).toList()
                              : [
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 235, 233, 233),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Text(
                                      'No defaulted loans',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                        )
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ));
  }
}

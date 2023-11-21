import 'package:flutter/material.dart';

import 'loanDetails/details1.dart';
import 'loanDetails/details2.dart';
import 'loan_class.dart';

class SwipeScreens extends StatefulWidget {
  final Loan loan;
  final Map<String, dynamic> loanApplicationDetails;
  final Map<String, dynamic> paymentInfo;

  const SwipeScreens({super.key, 
    required this.loan,
    required this.loanApplicationDetails,
    required this.paymentInfo,
  });
  @override
  _SwipeScreensState createState() => _SwipeScreensState();
}

class _SwipeScreensState extends State<SwipeScreens> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  @override
  void initState() {
    // Access and print the loan application details and payment information
    print('Loan Application Details: ${widget.loanApplicationDetails}');
    print('Payment Information: ${widget.paymentInfo}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Loan Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Loan Details',
                  style: TextStyle(
                    decoration: _currentPageIndex == 0
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decorationColor: Colors.white,
                  )),
              Text('Loan Payments',
                  style: TextStyle(
                    decoration: _currentPageIndex == 1
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decorationColor: Colors.white,
                  )),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: <Widget>[
          FirstScreen(
              loanApplicationDetails: widget.loanApplicationDetails,
              paymentInfo: widget.paymentInfo),
          SecondScreen(
              loanApplicationDetails: widget.loanApplicationDetails,
              paymentInfo: widget.paymentInfo),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

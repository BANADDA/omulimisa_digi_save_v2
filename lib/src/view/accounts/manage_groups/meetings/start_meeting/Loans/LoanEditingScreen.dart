import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../../../database/localStorage.dart';

class LoanEditingScreen extends StatefulWidget {
  final int groupId;
  final Map<String, dynamic> loanData;

  const LoanEditingScreen(
      {super.key, required this.loanData, required this.groupId});

  @override
  _LoanEditingScreenState createState() => _LoanEditingScreenState();
}

class _LoanEditingScreenState extends State<LoanEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _loanPurposeController = TextEditingController();
  final TextEditingController _repaymentDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.loanData['loan_amount'].toString();
    _loanPurposeController.text = widget.loanData['loan_purpose'];
    _repaymentDateController.text = widget.loanData['end_date'];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _loanPurposeController.dispose();
    _repaymentDateController.dispose();
    super.dispose();
  }

  void _updateLoanData() async {
    if (_formKey.currentState!.validate()) {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final int loanId = widget.loanData['id'];
      final double updatedAmount = double.parse(_amountController.text);
      final String updatedLoanPurpose = _loanPurposeController.text;
      final String updatedRepaymentDate = _repaymentDateController.text;

      double? InterestRate =
          await DatabaseHelper.instance.getInterestRate(widget.groupId);
      print('Interest Rate: $InterestRate');
      double newAmount =
          updatedAmount + ((updatedAmount.toDouble()) * InterestRate! / 100);

      await dbHelper.updateLoanEntry(
        loanId,
        newAmount,
        updatedLoanPurpose,
        updatedRepaymentDate,
      );

      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectRepaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _repaymentDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Edit Loan',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration:
                    const InputDecoration(labelText: 'Loan Amount (UGX)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid loan amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _loanPurposeController,
                decoration: const InputDecoration(labelText: 'Loan Purpose'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a loan purpose';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _repaymentDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Repayment Date',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _selectRepaymentDate(context);
                    },
                    icon: const Icon(Icons.calendar_today),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid repayment date';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _updateLoanData,
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

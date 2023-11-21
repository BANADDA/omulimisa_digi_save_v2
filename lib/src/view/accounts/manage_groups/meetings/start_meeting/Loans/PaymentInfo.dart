class PaymentInfo {
  final int groupId;
  final int loanId;
  final int memberID;
  final double amount;
  final DateTime paymentDate;
  double remainingBalance; // Add this property
  double totalPaidAmount; // Add this property

  PaymentInfo({
    required this.groupId,
    required this.loanId,
    required this.memberID,
    required this.amount,
    required this.paymentDate,
    this.remainingBalance = 0, // Initialize to 0
    this.totalPaidAmount = 0, // Initialize to 0
  });
}

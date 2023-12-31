class LoanApplication {
  final String id;
  final String groupId;
  final String submissionDate;
  final String loanApplicant;
  final String groupMemberId;
  final double amountNeeded;
  final String loanPurpose;
  final String repaymentDate;
  String LoanStatus;

  LoanApplication({
    required this.id,
    required this.groupId,
    required this.submissionDate,
    required this.loanApplicant,
    required this.groupMemberId,
    required this.amountNeeded,
    required this.loanPurpose,
    required this.repaymentDate,
    required this.LoanStatus,
  });
}

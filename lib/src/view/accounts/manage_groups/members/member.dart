class Member {
  final String name;
  final MembershipType membershipType;
  final DateTime startDate;
  final int shares;
  final double contributionAmount;

  Member({
    required this.name,
    required this.membershipType,
    required this.startDate,
    required this.shares,
    required this.contributionAmount,
  });
}

enum MembershipType {
  Chairman,
  Secretary,
  Treasurer,
  FineCollector,
  NormalMember,
}

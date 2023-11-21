class Member {
  final String id;
  final String image;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String gender;
  final int numberOfFamilyDependants;
  final String familyInfo;
  final String location;

  Member({
    required this.id,
    required this.image,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.gender,
    required this.numberOfFamilyDependants,
    required this.familyInfo,
    required this.location,
  });
}

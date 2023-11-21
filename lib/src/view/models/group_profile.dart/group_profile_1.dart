class GroupProfile {
  final int id;
  final String groupName;
  final String countryOfOrigin;
  final String meetingLocation;
  final String groupStatus;
  final String? groupLogoPath;
  final String? partnerID;
  final String? workingWithPartner;
  final bool isWorkingWithPartner;
  final String numberOfCycles;
  final String numberOfMeetings; // New field for number of meetings
  final String loanFund; // New field for loan fund
  final String socialFund; // New field for social fund

  GroupProfile({
    required this.id,
    required this.groupName,
    required this.countryOfOrigin,
    required this.meetingLocation,
    required this.groupStatus,
    this.groupLogoPath,
    this.partnerID,
    this.workingWithPartner,
    required this.isWorkingWithPartner,
    required this.numberOfCycles,
    required this.numberOfMeetings,
    required this.loanFund,
    required this.socialFund,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupName': groupName,
      'countryOfOrigin': countryOfOrigin,
      'meetingLocation': meetingLocation,
      'groupStatus': groupStatus,
      'groupLogoPath': groupLogoPath,
      'partnerID': partnerID,
      'workingWithPartner': workingWithPartner,
      'isWorkingWithPartner': isWorkingWithPartner ? 1 : 0,
      'numberOfCycles': numberOfCycles,
      'numberOfMeetings': numberOfMeetings, // Added field
      'loanFund': loanFund, // Added field
      'socialFund': socialFund, // Added field
    };
  }

  factory GroupProfile.fromMap(Map<String, dynamic> map) {
    return GroupProfile(
      id: map['id'],
      groupName: map['groupName'],
      countryOfOrigin: map['countryOfOrigin'],
      meetingLocation: map['meetingLocation'],
      groupStatus: map['groupStatus'],
      groupLogoPath: map['groupLogoPath'],
      partnerID: map['partnerID'],
      workingWithPartner: map['workingWithPartner'],
      isWorkingWithPartner: map['isWorkingWithPartner'] == 1,
      numberOfCycles: map['numberOfCycles'],
      numberOfMeetings: map['numberOfMeetings'], // Added field
      loanFund: map['loanFund'], // Added field
      socialFund: map['socialFund'], // Added field
    );
  }
}


class MeetingData {
  int? id; // Unique identifier for the meeting (primary key)
  String? date;
  String? time;
  String? location;
  String? facilitator;
  String? meetingPurpose;
  double? latitude;
  double? longitude;
  String? address;
  String endTime;

  // List of objectives
  List<String> objectives = [];

  // Map to store group member attendance
  Map<String, Map<String, bool>> attendanceData = {};

  // Map to store representatives
  Map<String, String?> representativeData = {};

  // List of proposals
  List<String> proposals = [];

  // Constructor
  MeetingData({
    this.id,
    this.date,
    this.time,
    this.location,
    this.facilitator,
    this.meetingPurpose,
    this.latitude,
    this.longitude,
    this.address,
    required this.objectives,
    required this.attendanceData,
    required this.representativeData,
    required this.proposals,
    required this.endTime,
  });

  // Convert MeetingData to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'location': location,
      'facilitator': facilitator,
      'meetingPurpose': meetingPurpose,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'objectives': objectives
          .join(';'), // Store objectives as a single string separated by ';'
      'attendanceData': attendanceData,
      'representativeData': representativeData,
      'proposals': proposals
          .join(';'), // Store proposals as a single string separated by ';'
      'endTime': endTime,
    };
  }

  // Create MeetingData object from Map retrieved from the database
  factory MeetingData.fromMap(Map<String, dynamic> map) {
    // Split the stored objectives and proposals back into lists
    final objectivesList = (map['objectives'] as String).split(';');
    final proposalsList = (map['proposals'] as String).split(';');

    return MeetingData(
      id: map['id'],
      date: map['date'],
      endTime: map['endTime'],
      time: map['time'],
      location: map['location'],
      facilitator: map['facilitator'],
      meetingPurpose: map['meetingPurpose'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      objectives: objectivesList,
      attendanceData: map['attendanceData'],
      representativeData: map['representativeData'],
      proposals: proposalsList,
    );
  }
}

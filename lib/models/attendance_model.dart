class AttendanceModel {
  String attendanceId;
  int dateTime;
  Map<String, dynamic> studentsData;
  Map<String, String> takenBy;
  int counts;

  AttendanceModel({
    required this.attendanceId,
    required this.dateTime,
    required this.studentsData,
    required this.takenBy,
    required this.counts,
  });

  factory AttendanceModel.empty() {
    return AttendanceModel(
      attendanceId: '',
      dateTime: -1,
      studentsData: {},
      takenBy: {},
      counts: -1,
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'],
      dateTime: json['dateTime'],
      studentsData: Map<String, dynamic>.from(json['studentsData']),
      takenBy: Map<String, String>.from(json['takenBy']),
      counts: json['counts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'dateTime': dateTime,
      'studentsData': studentsData,
      'takenBy': takenBy,
      'counts': counts,
    };
  }
}

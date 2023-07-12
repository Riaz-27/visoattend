class AttendanceModel {
  String attendanceId;
  int dateTime;
  Map<String, dynamic> studentsData;
  Map<String, String> takenBy;

  AttendanceModel({
    required this.attendanceId,
    required this.dateTime,
    required this.studentsData,
    required this.takenBy,
  });

  factory AttendanceModel.empty() {
    return AttendanceModel(
      attendanceId: '',
      dateTime: -1,
      studentsData: {},
      takenBy: {},
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendanceId'],
      dateTime: json['dateTime'],
      studentsData: Map<String, dynamic>.from(json['studentsData']),
      takenBy: Map<String, String>.from(json['takenBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'dateTime': dateTime,
      'studentsData': studentsData,
      'takenBy': takenBy,
    };
  }
}

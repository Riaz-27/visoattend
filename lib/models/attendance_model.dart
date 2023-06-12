class AttendanceModel {
  String classroomId;
  String dateTime;
  List<String> presentStudents;
  Map<String, String> takenByUser;
  int counts;

  AttendanceModel({
    required this.classroomId,
    required this.dateTime,
    required this.presentStudents,
    required this.takenByUser,
    required this.counts,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      classroomId: json['classroomId'],
      dateTime: json['dateTime'],
      presentStudents: List<String>.from(json['presentStudents']),
      takenByUser: Map<String, String>.from(json['takenByUser']),
      counts: json['counts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classroomId': classroomId,
      'dateTime': dateTime,
      'presentStudents': presentStudents,
      'takenByUser': takenByUser,
      'counts': counts,
    };
  }
}

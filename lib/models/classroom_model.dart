class ClassroomModel {
  String attendanceId;
  String courseCode;
  String courseTitle;
  String section;
  List<String> weekTimes;
  List<String> teachers;
  List<String> cRs;
  List<String> students;

  ClassroomModel({
    required this.attendanceId,
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.weekTimes,
    required this.teachers,
    required this.cRs,
    required this.students,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      attendanceId: json['attendanceId'],
      courseCode: json['courseCode'],
      courseTitle: json['courseTitle'],
      section: json['section'],
      weekTimes: List<String>.from(json['weekTimes']),
      teachers: List<String>.from(json['teachers']),
      cRs: List<String>.from(json['cRs']),
      students: List<String>.from(json['students']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'section': section,
      'weekTimes': weekTimes,
      'teachers': teachers,
      'cRs': cRs,
      'students': students,
    };
  }
}

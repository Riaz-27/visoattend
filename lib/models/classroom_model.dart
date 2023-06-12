class ClassroomModel {
  String courseCode;
  String courseTitle;
  String section;
  String session;
  List<String> weekTimes;
  List<String> teachers;
  List<String> cRs;
  List<String> students;

  ClassroomModel({
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.session,
    required this.weekTimes,
    required this.teachers,
    required this.cRs,
    required this.students,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      courseCode: json['courseCode'],
      courseTitle: json['courseTitle'],
      section: json['section'],
      session: json['session'],
      weekTimes: List<String>.from(json['weekTimes']),
      teachers: List<String>.from(json['teachers']),
      cRs: List<String>.from(json['cRs']),
      students: List<String>.from(json['students']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'section': section,
      'session': session,
      'weekTimes': weekTimes,
      'teachers': teachers,
      'cRs': cRs,
      'students': students,
    };
  }
}

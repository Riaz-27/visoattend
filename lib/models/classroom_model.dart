class ClassroomModel {
  bool isArchived;
  String classroomId;
  String courseCode;
  String courseTitle;
  String section;
  String session;
  Map<String, dynamic> weekTimes;
  List<Map<String, dynamic>> teachers;
  List<Map<String, dynamic>> cRs;
  List<Map<String, dynamic>> students;

  ClassroomModel({
    required this.isArchived,
    required this.classroomId,
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.session,
    required this.weekTimes,
    required this.teachers,
    required this.cRs,
    required this.students,
  });

  factory ClassroomModel.empty() {
    return ClassroomModel(
      isArchived: false,
      classroomId: '',
      courseCode: '',
      courseTitle: '',
      section: '',
      session: '',
      weekTimes: {},
      teachers: [],
      cRs: [],
      students: [],
    );
  }

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      isArchived: json['isArchived'],
      classroomId: json['classroomId'],
      courseCode: json['courseCode'],
      courseTitle: json['courseTitle'],
      section: json['section'],
      session: json['session'],
      weekTimes: Map<String,dynamic>.from(json['weekTimes']),
      teachers: List<Map<String,dynamic>>.from(json['teachers']),
      cRs: List<Map<String,dynamic>>.from(json['cRs']),
      students: List<Map<String,dynamic>>.from(json['students']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isArchived': isArchived,
      'classroomId': classroomId,
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
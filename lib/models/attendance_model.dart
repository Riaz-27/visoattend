class AttendanceModel {
  int dateTime;
  List<Map<String,dynamic>> studentsData;
  Map<String, String> takenBy;
  int counts;

  AttendanceModel({
    required this.dateTime,
    required this.studentsData,
    required this.takenBy,
    required this.counts,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      dateTime: json['dateTime'],
      studentsData: List<Map<String,dynamic>>.from(json['studentsData']),
      takenBy: Map<String, String>.from(json['takenBy']),
      counts: json['counts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime,
      'studentsData': studentsData,
      'takenBy': takenBy,
      'counts': counts,
    };
  }
}

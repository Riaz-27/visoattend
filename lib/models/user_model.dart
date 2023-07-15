class UserModel {
  String authUid;
  String profilePic;
  String userId;
  String name;
  String email;
  String mobile;
  String gender;
  String dob;
  String semesterOrDesignation;
  String department;
  Map<String,dynamic> classrooms;
  List<dynamic> faceDataFront; // List<double>
  List<dynamic> faceDataLeft; // List<double>
  List<dynamic> faceDataRight; // List<double>

  UserModel({
    required this.authUid,
    required this.profilePic,
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.dob,
    required this.semesterOrDesignation,
    required this.department,
    required this.classrooms,
    required this.faceDataFront,
    required this.faceDataLeft,
    required this.faceDataRight,
  });

  factory UserModel.empty() {
    return UserModel(
      authUid: '',
      userId: '',
      profilePic: '',
      name: '',
      email: '',
      mobile: '',
      gender: '',
      dob: '',
      semesterOrDesignation: '',
      department: '',
      classrooms: {},
      faceDataFront: [],
      faceDataLeft: [],
      faceDataRight: [],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authUid: json['authUid'],
      userId: json['userId'],
      profilePic: json['profilePic'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      gender: json['gender'],
      dob: json['dob'],
      semesterOrDesignation: json['semesterOrDesignation'],
      department: json['department'],
      classrooms: Map<String,dynamic>.from(json['classrooms']),
      faceDataFront: json['faceDataFront'],
      faceDataLeft: json['faceDataLeft'],
      faceDataRight: json['faceDataRight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authUid': authUid,
      'profilePic': profilePic,
      'userId': userId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'dob': dob,
      'semesterOrDesignation': semesterOrDesignation,
      'department': department,
      'classrooms': classrooms,
      'faceDataFront': faceDataFront,
      'faceDataLeft': faceDataLeft,
      'faceDataRight': faceDataRight,
    };
  }
}
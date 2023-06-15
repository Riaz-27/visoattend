
class UserModel {
  String authUid;
  String userId;
  String name;
  String email;
  List<Map<String,dynamic>> classrooms;
  List<dynamic> faceDataFront; // List<double>
  List<dynamic> faceDataLeft; // List<double>
  List<dynamic> faceDataRight; // List<double>

  UserModel({
    required this.authUid,
    required this.userId,
    required this.name,
    required this.email,
    required this.classrooms,
    required this.faceDataFront,
    required this.faceDataLeft,
    required this.faceDataRight,
  });

  factory UserModel.empty() {
    return UserModel(
      authUid: '',
      userId: '',
      name: '',
      email: '',
      classrooms: [],
      faceDataFront: [],
      faceDataLeft: [],
      faceDataRight: [],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authUid: json['authUid'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      classrooms: List<Map<String,dynamic>>.from(json['classrooms']),
      faceDataFront: json['faceDataFront'],
      faceDataLeft: json['faceDataLeft'],
      faceDataRight: json['faceDataRight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authUid': authUid,
      'userId': userId,
      'name': name,
      'email': email,
      'classrooms': classrooms,
      'faceDataFront': faceDataFront,
      'faceDataLeft': faceDataLeft,
      'faceDataRight': faceDataRight,
    };
  }
}

class UserModel {
  String authUid;
  String userId;
  String name;
  String email;
  List<dynamic> faceDataFront; // List<double>
  List<dynamic> faceDataLeft; // List<double>
  List<dynamic> faceDataRight; // List<double>

  UserModel({
    required this.authUid,
    required this.userId,
    required this.name,
    required this.email,
    required this.faceDataFront,
    required this.faceDataLeft,
    required this.faceDataRight,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authUid: json['authUid'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
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
      'faceDataFront': faceDataFront,
      'faceDataLeft': faceDataLeft,
      'faceDataRight': faceDataRight,
    };
  }
}
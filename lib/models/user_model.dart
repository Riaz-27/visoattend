
class UserModel {
  String authUid;
  String userId;
  String name;
  String email;
  List<double>? faceDataFront;
  List<double>? faceDataLeft;
  List<double>? faceDataRight;

  UserModel({
    required this.authUid,
    required this.userId,
    required this.name,
    required this.email,
    this.faceDataFront,
    this.faceDataLeft,
    this.faceDataRight,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authUid: json['authUid'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      faceDataFront: json['faceDataFront'] as List<double>,
      faceDataLeft: json['faceDataLeft'] as List<double>,
      faceDataRight: json['faceDataRight'] as List<double>,
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
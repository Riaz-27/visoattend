import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String password;
  late String name;
  late List<double> faceDataFront;
  late List<double> faceDataRight;
  late List<double> faceDataLeft;
}
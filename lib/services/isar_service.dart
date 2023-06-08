import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/entities/isar_user.dart';

class IsarService {
  late Future<Isar> _db;
  Future<Isar> get db => _db;

  IsarService() {
    _db = openDb();
  }

  Future<Isar> openDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      print('The Path : ${dir.path}');
      return await Isar.open(
        [IsarUserSchema],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }

}

import 'package:get/get.dart';

import '../models/classroom_model.dart';

class LeaveRequestController extends GetxController{

  final _selectedClassrooms = <ClassroomModel>[].obs;
  List<ClassroomModel> get selectedClassrooms => _selectedClassrooms;

  final _availableClassrooms = <ClassroomModel>[].obs;
  List<ClassroomModel> get availableClassrooms => _availableClassrooms;


}
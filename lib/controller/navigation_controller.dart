import 'package:get/get.dart';

class NavigationController extends GetxController{
  ///For detailed classroom pages
  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeIndex(int index){
    _selectedIndex.value = index;
  }

  /// For selected attendance pages
  final _selectedAttendanceIndex = 0.obs;
  int get selectedAttendanceIndex => _selectedAttendanceIndex.value;

  void changeAttendanceIndex(int index){
    _selectedAttendanceIndex.value = index;
  }
}
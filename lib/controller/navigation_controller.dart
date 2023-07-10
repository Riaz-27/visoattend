import 'package:get/get.dart';

class NavigationController extends GetxController{
  ///For detailed classroom pages
  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeIndex(int index){
    _selectedIndex.value = index;
  }

  /// For selected home pages
  final _selectedHomeIndex = 0.obs;
  int get selectedHomeIndex => _selectedHomeIndex.value;

  void changeHomeIndex(int index){
    _selectedHomeIndex.value = index;
  }

}
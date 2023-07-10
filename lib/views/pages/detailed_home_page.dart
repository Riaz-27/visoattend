import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/navigation_controller.dart';
import 'package:visoattend/views/pages/all_classroom_page.dart';
import 'package:visoattend/views/pages/home_page.dart';

class DetailedHomePage extends GetView<NavigationController> {
  const DetailedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationPages = [
      const HomePage(),
      const AllClassroomPage()
    ];
    return const Placeholder();
  }
}

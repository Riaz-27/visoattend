import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../controller/attendance_controller.dart';

class GenerateExcelService {
  Future<void> generateReport(String filename) async {
    final attendanceController = Get.find<AttendanceController>();
    final attendances = attendanceController.attendances.toList().reversed;
    final totalStudents = attendanceController.cRsData.toList() +
        attendanceController.studentsData.toList();

    totalStudents.sort((a, b) => a.userId.compareTo(b.userId));

    final Workbook workbook = Workbook();
    workbook.worksheets.create(1);
    final Worksheet detailsWorksheet = workbook.worksheets[0]..name = 'Details';
    final Worksheet reportWorksheet = workbook.worksheets[1]..name = 'Report';

    int row = 6;
    int column = 1;

    _buildTitle(detailsWorksheet);
    _buildTitle(reportWorksheet, report: true);

    List<int> studentsAbsents = List.filled(totalStudents.length, 0);
    List<int> studentsPresents = List.filled(totalStudents.length, 0);
    List<int> studentsLeaves = List.filled(totalStudents.length, 0);

    //Generating headers text
    for (final attendance in attendances) {
      Range detailsCell = detailsWorksheet.getRangeByIndex(row, column);
      final reportCell = reportWorksheet.getRangeByIndex(row, column);

      detailsCell.cellStyle.bold = true;
      reportCell.cellStyle.bold = true;
      detailsCell.cellStyle.hAlign = HAlignType.center;
      reportCell.cellStyle.hAlign = HAlignType.center;
      if (column == 1) {
        detailsCell.columnWidth = 5;
        detailsCell.setText('SL');
        reportCell.columnWidth = 5;
        reportCell.setText('SL');
      } else if (column == 2) {
        detailsCell.columnWidth = 15;
        detailsCell.setText('ID No.');
        reportCell.columnWidth = 15;
        reportCell.setText('ID No.');
      } else if (column == 3) {
        detailsCell.columnWidth = 30;
        detailsCell.setText('Name');
        reportCell.columnWidth = 30;
        reportCell.setText('Name');
      } else if (column == 4) {
        reportCell.columnWidth = 15;
        reportCell.setText('Presents');
      } else if (column == 5) {
        reportCell.columnWidth = 15;
        reportCell.setText('Leaves');
      } else if (column == 6) {
        reportCell.columnWidth = 15;
        reportCell.setText('Absents');
      } else if (column == 7) {
        reportCell.columnWidth = 25;
        reportCell.setText('Percentage(%)');
      } else if (column == 8) {
        reportCell.columnWidth = 15;
        reportCell.setText('Marks');
      } else if (column == 9) {
        reportCell.columnWidth = 25;
        reportCell.setText('Comments');
      }
      detailsCell = detailsWorksheet.getRangeByIndex(row, column+3);
      detailsCell.cellStyle.bold = true;
      detailsCell.cellStyle.hAlign = HAlignType.center;
      final dateTime =
      DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
      detailsCell.setText(DateFormat('d/M/yy').format(dateTime));
      column++;
    }

    row = 7;
    //Generating attendance details
    for (int i = 0; i < totalStudents.length; i++) {
      for (int j = 1; j <= 3; j++) {
        final cell = detailsWorksheet.getRangeByIndex(row, j);
        if (j == 1) {
          cell.setText((row - 6).toString());
        } else if (j == 2) {
          cell.setText(totalStudents[i].userId);
        } else if (j == 3) {
          cell.setText(totalStudents[i].name);
        }
      }
      column = 4;
      for (final attendance in attendances) {
        final cell = detailsWorksheet.getRangeByIndex(row, column);
        String text = 'P';
        Color? backColor;
        cell.cellStyle.hAlign = HAlignType.center;
        final attendanceStatus =
            attendance.studentsData[totalStudents[i].authUid] as String?;
        if (attendanceStatus == null ||
            attendanceStatus.toLowerCase().contains('absent')) {
          text = '----';
          backColor = Colors.red.shade100;
          studentsAbsents[i]++;
        } else if (attendanceStatus.contains('Leave')) {
          text = 'P(L)';
          backColor = Colors.amberAccent;
          studentsLeaves[i]++;
        } else if (attendanceStatus.toLowerCase().contains('present')) {
          text = 'P';
          studentsPresents[i]++;
        }

        cell.setText(text);
        if (backColor != null) {
          cell.cellStyle.backColorRgb = backColor;
        }
        column++;
      }
      row++;
    }

    //Generating attendance report
    row = 7;
    for (int i = 0; i < totalStudents.length; i++) {
      column = 1;
      for (int j = 0; j < 9; j++) {
        final cell = reportWorksheet.getRangeByIndex(row, column);
        final percent =
            (attendances.length - studentsAbsents[i]) / attendances.length;
        Color? backColor;
        if (percent < 0.6) {
          backColor = Colors.red.shade100;
        } else if (percent < 0.7) {
          backColor = Colors.amberAccent;
        }
        String text = '';
        if (column == 1) {
          cell.columnWidth = 5;
          text = (row - 6).toString();
        } else if (column == 2) {
          cell.columnWidth = 15;
          text = totalStudents[i].userId;
        } else if (column == 3) {
          cell.columnWidth = 30;
          text = totalStudents[i].name;
        }
        cell.cellStyle.hAlign = HAlignType.center;
        if (column == 4) {
          cell.columnWidth = 15;
          text = studentsPresents[i].toString();
        } else if (column == 5) {
          cell.columnWidth = 15;
          text = studentsLeaves[i].toString();
        } else if (column == 6) {
          cell.columnWidth = 15;
          text = studentsAbsents[i].toString();
        } else if (column == 7) {
          cell.columnWidth = 25;
          text = (percent * 100).toStringAsFixed(0);
        } else if (column == 8) {
          cell.columnWidth = 15;
          text = (percent * 10).toStringAsFixed(1);
        } else if (column == 9) {
          backColor = null;
          cell.columnWidth = 25;
        }

        cell.setText(text);
        if (backColor != null) {
          cell.cellStyle.backColorRgb = backColor;
        }
        column++;
      }
      row++;
    }

    final fileBytes = workbook.saveAsStream();

    workbook.dispose();

    await saveExcelFile(filename, fileBytes);
  }

  Future<void> saveExcelFile(String filename, List<int> byteList) async {
    final output = await getApplicationSupportDirectory();
    var filePath = "${output.path}/$filename.xlsx";
    print(filePath);
    final file = File(filePath);
    await file.writeAsBytes(byteList, flush: true);
    await OpenFile.open(filePath);
  }

  void _buildTitle(Worksheet worksheet, {bool report = false}) {
    final attendanceController = Get.find<AttendanceController>();
    final classroom = attendanceController.classroomData;
    final instructor = attendanceController.teachersData
        .firstWhere(
            (teacher) => teacher.authUid == classroom.teachers[0]['authUid'])
        .name;

    //University
    Range cell = worksheet.getRangeByIndex(1, 1, 1, 12)..merge();
    cell.setText('International Islamic University Chittagong');
    cell.cellStyle.hAlign = HAlignType.center;
    cell.cellStyle.fontSize = 14;
    cell.cellStyle.bold = true;
    cell.rowHeight = 18;

    //department
    cell = worksheet.getRangeByIndex(2, 1, 2, 12)..merge();
    cell.setText(
      classroom.department == ''
          ? 'Department not set. Change in the classroom settings'
          : 'Department of ${classroom.department}',
    );
    cell.cellStyle.hAlign = HAlignType.center;
    cell.cellStyle.fontSize = 10;
    cell.rowHeight = 15;

    //for
    cell = worksheet.getRangeByIndex(3, 1, 3, 12)..merge();
    cell.setText(report ? 'Attendance Report' : 'Attendance for Students');
    cell.cellStyle.hAlign = HAlignType.center;
    cell.cellStyle.vAlign = VAlignType.top;
    cell.cellStyle.fontSize = 12;
    cell.cellStyle.bold = true;
    cell.rowHeight = 28;

    //Course Info
    cell = worksheet.getRangeByIndex(4, 1, 4, 3)..merge();
    cell.setText('Course Code: ${classroom.courseCode}');
    cell.cellStyle.vAlign = VAlignType.top;
    cell.cellStyle.bold = true;
    cell.rowHeight = 18;

    cell = worksheet.getRangeByIndex(4, 4, 4, 12)..merge();
    cell.setText('Course Title: ${classroom.courseTitle}');
    cell.cellStyle.vAlign = VAlignType.top;
    cell.cellStyle.bold = true;
    cell.rowHeight = 18;

    cell = worksheet.getRangeByIndex(5, 1, 5, 3)..merge();
    cell.setText('Session: ${classroom.session}');
    cell.cellStyle.bold = true;
    cell.cellStyle.vAlign = VAlignType.top;
    cell.rowHeight = 30;

    cell = worksheet.getRangeByIndex(5, 4, 5, 6)..merge();
    cell.setText('Section: ${classroom.section}');
    cell.cellStyle.bold = true;
    cell.cellStyle.vAlign = VAlignType.top;
    cell.rowHeight = 30;

    cell = worksheet.getRangeByIndex(5, 7, 5, 12)..merge();
    cell.setText('Instructor: $instructor');
    cell.cellStyle.bold = true;
    cell.cellStyle.vAlign = VAlignType.top;
    cell.rowHeight = 8;
    cell.rowHeight = 30;
  }
}

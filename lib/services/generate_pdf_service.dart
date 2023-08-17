import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../controller/attendance_controller.dart';
import '../models/attendance_model.dart';
import '../models/classroom_model.dart';

class GeneratePdfService {
  final ClassroomModel classroomData;
  final List<AttendanceModel> attendances;

  GeneratePdfService({
    required this.classroomData,
    required this.attendances,
  });

  Future<Uint8List> generateReport({required String department}) async {
    List<List<AttendanceModel>> attendancesChunks = [];
    for (int i = 0; i < attendances.length; i += 9) {
      final sublist = attendances.reversed
          .toList()
          .sublist(i, i + 9 > attendances.length ? attendances.length : i + 9);
      attendancesChunks.add(sublist);
    }

    final pdf = pw.Document();
    for (int i = 0; i < attendancesChunks.length; i++) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
              marginTop: 40, marginLeft: 18, marginRight: 18, marginBottom: 5),
          build: (pw.Context context) => [
            _buildTitle(
              'International Islamic University Chittagong',
              department == ''
                  ? 'Department not set. Change in the classroom settings'
                  : 'Department of $department',
              'Attendance for Students',
            ),
            pw.SizedBox(height: 5),
            _buildCourseInfo(classroomData),
            pw.SizedBox(height: 8),
            _buildAttendanceDetails(classroomData, attendancesChunks[i]),
          ],
        ),
      );
    }

    // final report
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
            marginTop: 40, marginLeft: 18, marginRight: 18, marginBottom: 5),
        build: (pw.Context context) => [
          _buildTitle(
            'International Islamic University Chittagong',
            department == ''
                ? 'Department not set. Change in the classroom settings'
                : 'Department of $department',
            'Attendance Report',
          ),
          pw.SizedBox(height: 5),
          _buildCourseInfo(classroomData),
          pw.SizedBox(height: 8),
          _buildAttendanceReport(classroomData, attendances),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> savePdfFile(String filename, Uint8List byteList) async {
    final output = await getApplicationSupportDirectory();
    var filePath = "${output.path}/$filename.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    print(filePath);
    await OpenFile.open(filePath);
  }

  static pw.Widget _buildTitle(
      String institution, String department, String title) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            institution,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            department,
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCourseInfo(ClassroomModel classroom) {
    final courseTitle = classroom.courseTitle;
    final courseCode = classroom.courseCode;
    final session = classroom.session;
    final section = classroom.section;

    final attendanceController = Get.find<AttendanceController>();
    final instructor = attendanceController.teachersData.firstWhere(
        (teacher) => teacher.authUid == classroom.teachers[0]['authUid']).name;

    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8),
                child: customText(
                    text: 'Course Code: $courseCode', bold: true, fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 6,
              child: customText(
                  text: 'Course Title: $courseTitle', bold: true, fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8),
                child: customText(
                    text: 'Session: $session', bold: true, fontSize: 10),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: customText(
                  text: 'Section: $section', bold: true, fontSize: 10),
            ),
            pw.Expanded(
              flex: 4,
              child: customText(
                  text: 'Instructor: $instructor', bold: true, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAttendanceDetails(
      ClassroomModel classroom, List<AttendanceModel> attendances) {
    var headers = [
      'SL',
      'ID No.',
      'Name',
    ];
    for (var attendance in attendances) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
      headers.add(DateFormat('d/M/yy').format(dateTime));
    }

    List<List<String>> data = [];

    final attendanceController = Get.find<AttendanceController>();

    final totalStudents = attendanceController.cRsData.toList() +
        attendanceController.studentsData.toList();
    totalStudents.sort((a, b) => a.userId.compareTo(b.userId));

    final lengthForLoop = totalStudents.length > 45 ? totalStudents.length : 45;

    for (int i = 0; i < lengthForLoop; i++) {
      List<String> perRow = ['${i + 1}'];
      int j;
      if (i < totalStudents.length) {
        perRow.add(totalStudents[i].userId);
        perRow.add(totalStudents[i].name);
        for (j = 0; j < attendances.length; j++) {
          final studentsStatus =
              attendances[j].studentsData[totalStudents[i].authUid];
          if (studentsStatus == 'Absent' || studentsStatus == null) {
            perRow.add('------');
          } else if (studentsStatus.contains('Leave')) {
            perRow.add('P (L)');
          } else {
            perRow.add('P');
          }
        }
        for (j = j; j < 9; j++) {
          perRow.add('');
        }
      }
      data.add(perRow);
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(width: 0.3),
        outside: const pw.BorderSide(width: 0.3),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(7),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(2),
        7: const pw.FlexColumnWidth(2),
        8: const pw.FlexColumnWidth(2),
        9: const pw.FlexColumnWidth(2),
        10: const pw.FlexColumnWidth(2),
        11: const pw.FlexColumnWidth(2),
      },
      headers: headers,
      headerCount: 1,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      headerAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
      },
      data: data,
      cellStyle: const pw.TextStyle(
        fontSize: 8,
      ),
      cellPadding: const pw.EdgeInsets.symmetric(
        vertical: 2.5,
        horizontal: 3,
      ),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
      },
      cellDecoration: (colNum, data, rowNum) {
        return data == '------'
            ? const pw.BoxDecoration(color: PdfColors.red100)
            : const pw.BoxDecoration();
      },
    );
  }

  static pw.Widget _buildAttendanceReport(
      ClassroomModel classroom, List<AttendanceModel> attendances) {
    var headers = [
      'SL',
      'ID No.',
      'Name',
      'Presents',
      'Leaves',
      'Absents',
      'Percentage(%)',
      'Marks',
      'Comments',
    ];

    List<List<String>> data = [];

    final attendanceController = Get.find<AttendanceController>();

    final totalStudents = attendanceController.cRsData.toList() +
        attendanceController.studentsData.toList();
    totalStudents.sort((a, b) => a.userId.compareTo(b.userId));

    List<int> studentsAbsents = List.filled(totalStudents.length, 0);
    List<int> studentsPresents = List.filled(totalStudents.length, 0);
    List<int> studentsLeaves = List.filled(totalStudents.length, 0);

    List<int> nonCollegiateRow = [];
    List<int> disCollegiateRow = [];
    final lengthForLoop = totalStudents.length > 45 ? totalStudents.length : 45;

    for (int i = 0; i < lengthForLoop; i++) {
      List<String> perRow = ['${i + 1}'];
      if (i < totalStudents.length) {
        perRow.add(totalStudents[i].userId);
        perRow.add(totalStudents[i].name);
        for (final attendance in attendances) {
          final studentStatus =
              attendance.studentsData[totalStudents[i].authUid];
          if (studentStatus == 'Absent' || studentStatus == null) {
            studentsAbsents[i]++;
          } else if (studentStatus.contains('Leave')) {
            studentsLeaves[i]++;
          } else {
            studentsPresents[i]++;
          }
        }
        double percentage = 1 - (studentsAbsents[i] / attendances.length);
        int roundedPercentage = (percentage * 100).round();

        if (roundedPercentage < 60) {
          disCollegiateRow.add(i + 1);
        } else if (roundedPercentage < 70) {
          nonCollegiateRow.add(i + 1);
        }

        perRow.add(studentsPresents[i].toString());
        perRow.add(studentsLeaves[i].toString());
        perRow.add(studentsAbsents[i].toString());
        perRow.add(roundedPercentage.toString());
        perRow.add((roundedPercentage / 10).toString());
        perRow.add('');
      }
      data.add(perRow);
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(width: 0.3),
        outside: const pw.BorderSide(width: 0.3),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(7),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(3.3),
        7: const pw.FlexColumnWidth(2),
        8: const pw.FlexColumnWidth(6),
      },
      headers: headers,
      headerCount: 1,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      headerAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
      },
      data: data,
      cellStyle: const pw.TextStyle(
        fontSize: 8,
      ),
      cellPadding: const pw.EdgeInsets.symmetric(
        vertical: 2.5,
        horizontal: 3,
      ),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
      },
      cellDecoration: (colNum, data, rowNum) {
        if (disCollegiateRow.contains(rowNum) && colNum != 8) {
          return const pw.BoxDecoration(color: PdfColors.red100);
        }
        if (nonCollegiateRow.contains(rowNum) && colNum != 8) {
          return const pw.BoxDecoration(color: PdfColors.yellow100);
        }
        return const pw.BoxDecoration();
      },
    );
  }

  static pw.Widget customText({
    required String text,
    bool bold = false,
    double fontSize = 12,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: fontSize,
        color: textColor,
      ),
    );
  }
}

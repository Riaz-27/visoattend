import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/attendance_model.dart';
import '../models/classroom_model.dart';

class ReportGenerateService {
  final ClassroomModel classroomData;
  final List<AttendanceModel> attendances;

  ReportGenerateService({
    required this.classroomData,
    required this.attendances,
  });

  Future<Uint8List> generateReport() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
            marginTop: 40, marginLeft: 15, marginRight: 15, marginBottom: 15),
        build: (pw.Context context) => [
          _buildTitle(
            'International Islamic University Chittagong',
            'Department of Computer Science and Engineering',
          ),
          _buildCourseInfo(classroomData),
          _buildAttendanceDetails(classroomData, attendances),
        ],
      ),
    );
    return pdf.save();
  }

  Future<void> savePdfFile(String filename, Uint8List byteList) async {
    final output = await getApplicationDocumentsDirectory();
    var filePath = "${output.path}/$filename.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    print(filePath);
    await OpenFile.open(filePath);
  }

  static pw.Widget _buildTitle(String institution, String department) {
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
            'Attendance for Students',
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
    final instructor = classroom.teachers[0]['name'];

    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: customText(
                  text: 'Course Code: $courseCode', bold: true, fontSize: 10),
            ),
            pw.Expanded(
              flex: 6,
              child: customText(
                  text: 'Course Title: $courseTitle', bold: true, fontSize: 10),
            ),
          ],
        ),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: customText(
                  text: 'Session: $session', bold: true, fontSize: 10),
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

    final totalStudents = classroom.cRs + classroom.students;
    totalStudents.sort((a, b) => a['userId'].compareTo(b['userId']));

    for (int i = 0; i < 45; i++) {
      List<String> perRow = ['${i+1}'];
      if (i < totalStudents.length) {
        perRow.add(totalStudents[i]['userId']);
        perRow.add(totalStudents[i]['name']);
        for (int j = 0; j < attendances.length; j++) {
          final studentsStatus =
              attendances[j].studentsData[totalStudents[i]['authUid']];
          if (studentsStatus == 'Absent' || studentsStatus == null) {
            perRow.add('----');
          } else {
            perRow.add('P');
          }
        }
      }
      data.add(perRow);
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(width: 0.3),
        outside: const pw.BorderSide(width: 0.3),
      ),
      headers: headers,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      headerAlignment: pw.Alignment.center,
      data: data,
      cellStyle: const pw.TextStyle(
        fontSize: 8,
      ),
      cellPadding: const pw.EdgeInsets.symmetric(
        vertical: 2.5,
        horizontal: 5,
      ),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
      }
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

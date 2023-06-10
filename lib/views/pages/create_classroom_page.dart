import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateClassroomPage extends StatefulWidget {
  const CreateClassroomPage({super.key});

  @override
  _CreateClassroomPageState createState() => _CreateClassroomPageState();
}

class _CreateClassroomPageState extends State<CreateClassroomPage> {
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  final List<TimeOfDay> _weekTimes = List.generate(7, (index) => TimeOfDay.now());
  final List<String> _weekDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<bool> _selectedWeeks = List.generate(7, (index) => false);

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseTitleController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _weekTimes[index],
    );

    if (picked != null && picked != _weekTimes[index]) {
      setState(() {
        _weekTimes[index] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classroom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _courseCodeController,
              decoration: const InputDecoration(
                hintText: 'Course Code',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _courseTitleController,
              decoration: const InputDecoration(
                hintText: 'Course Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _sectionController,
              decoration: const InputDecoration(
                hintText: 'Section',
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Set Week Times',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  final weekName = _weekDays[index];
                  final selectedTime = DateFormat.jm().format(
                    DateTime(2023, 1, 6 + index, _weekTimes[index].hour, _weekTimes[index].minute),
                  );

                  return Row(
                    children: [
                      Checkbox(
                        value: _selectedWeeks[index],
                        onChanged: (value) {
                          setState(() {
                            _selectedWeeks[index] = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(weekName),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          readOnly: !_selectedWeeks[index],
                          onTap: _selectedWeeks[index] ? () => _selectTime(index) : null,
                          controller: TextEditingController(text: selectedTime),
                          decoration: const InputDecoration(
                            hintText: 'Select Time',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: _selectedWeeks[index] ? () => _selectTime(index) : null,
                        child: const Icon(Icons.access_time),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle confirm button press
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

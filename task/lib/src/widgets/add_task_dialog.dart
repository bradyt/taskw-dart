import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({Key? key}) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late TextEditingController controller;
  DateTime? due;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Add task'),
      content: ListBody(
        children: [
          TextField(
            autofocus: true,
            maxLines: null,
            controller: controller,
            style: GoogleFonts.firaMono(),
          ),
          const Divider(
            color: Color(0x00000000),
          ),
          Wrap(
            children: [
              GestureDetector(
                onLongPress: () {
                  due = null;
                  setState(() {});
                },
                child: ActionChip(
                  label: Text(
                    'due:${(due != null) ? due!.toLocal().toIso8601String() : ''}',
                    style: GoogleFonts.firaMono(),
                  ),
                  onPressed: () async {
                    var initialDate = due?.toUtc() ?? DateTime.now();
                    var date = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1990), // >= 1980-01-01T00:00:00.000Z
                      lastDate:
                          DateTime(2037, 12, 31), // < 2038-01-19T03:14:08.000Z
                    );
                    if (date != null) {
                      var time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(initialDate),
                      );
                      if (time != null) {
                        var dateTime = date.add(
                          Duration(
                            hours: time.hour,
                            minutes: time.minute,
                          ),
                        );
                        dateTime = dateTime.add(
                          Duration(
                            hours: time.hour - dateTime.hour,
                          ),
                        );
                        due = dateTime.toUtc();
                      }
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              validateTaskDescription(controller.text);
              StorageWidget.of(context).mergeTask(
                taskParser(controller.text).rebuild((b) => b..due = due),
              );
              Navigator.of(context).pop();
            } on FormatException catch (e, trace) {
              showExceptionDialog(
                context: context,
                e: e,
                trace: trace,
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

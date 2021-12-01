import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
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

  Future submit() async {
    try {
      var task = taskParser(controller.text).rebuild((b) => b..due = due);
      StorageWidget.of(context).mergeTask(task);
      controller.text = '';
      due = null;
      setState(() {});
    } on FormatException catch (e, trace) {
      showExceptionDialog(
        context: context,
        e: e,
        trace: trace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        2,
        2,
        2,
        2 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'task add ',
                    style: GoogleFonts.firaMono(),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      controller: controller,
                      style: GoogleFonts.firaMono(),
                      onSubmitted: (_) {
                        if (controller.text.isNotEmpty) {
                          submit();
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_return),
                    onPressed: submit,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
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
                              var initialDate =
                                  due?.toLocal() ?? DateTime.now();
                              var date = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(
                                    1990), // >= 1980-01-01T00:00:00.000Z
                                lastDate: DateTime(
                                    2037, 12, 31), // < 2038-01-19T03:14:08.000Z
                              );
                              if (date != null) {
                                var time = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      TimeOfDay.fromDateTime(initialDate),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

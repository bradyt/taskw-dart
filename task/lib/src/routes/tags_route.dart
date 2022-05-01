import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class TagsRoute extends StatefulWidget {
  const TagsRoute({required this.value, required this.callback, super.key});

  final ListBuilder<String>? value;
  final void Function(ListBuilder<String>?) callback;

  @override
  TagsRouteState createState() => TagsRouteState();
}

class TagsRouteState extends State<TagsRoute> {
  Map<String, TagMetadata>? _pendingTags;
  ListBuilder<String>? draftTags;

  void _addTag(String tag) {
    if (draftTags == null) {
      draftTags = ListBuilder([tag]);
    } else {
      draftTags!.add(tag);
    }
    widget.callback(draftTags);
    setState(() {});
  }

  void _removeTag(String tag) {
    draftTags!.remove(tag);
    widget.callback((draftTags!.isEmpty) ? null : draftTags);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    draftTags = widget.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  Future<void> _initialize() async {
    _pendingTags = StorageWidget.of(context).pendingTags;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tags'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (draftTags != null)
                  for (var tag in draftTags!.build())
                    FilterChip(
                      onSelected: (_) => _removeTag(tag),
                      label: Text(
                        '+$tag ${_pendingTags?[tag]?.frequency ?? 0}',
                        style: GoogleFonts.firaMono(),
                      ),
                    ),
                const Divider(),
                if (_pendingTags != null)
                  for (var tag in _pendingTags!.entries.where((tag) =>
                      !(draftTags?.build().contains(tag.key) ?? false)))
                    FilterChip(
                      onSelected: (_) => _addTag(tag.key),
                      label: Text(
                        '${tag.key} ${tag.value.frequency}',
                        style: GoogleFonts.firaMono(),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Add tag'),
              content: TextField(
                autofocus: true,
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      validateTaskTags(controller.text);
                      _addTag(controller.text);
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
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

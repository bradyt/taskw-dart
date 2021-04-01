import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taskc/json.dart';

class AnnotationsRoute extends StatefulWidget {
  const AnnotationsRoute({required this.value, required this.callback});

  final ListBuilder<Annotation>? value;
  final void Function(ListBuilder<Annotation>?) callback;

  @override
  AnnotationsRouteState createState() => AnnotationsRouteState();
}

class AnnotationsRouteState extends State<AnnotationsRoute> {
  ListBuilder<Annotation>? draftAnnotations;

  void _addAnnotation(Annotation annotation) {
    if (draftAnnotations == null) {
      draftAnnotations = ListBuilder([annotation]);
    } else {
      draftAnnotations!.add(annotation);
    }
    widget.callback(draftAnnotations);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    draftAnnotations = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('annotations'),
      ),
      body: ListView.separated(
        itemCount: draftAnnotations?.length ?? 0,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (_, index) {
          var entry = draftAnnotations![index].entry.toLocal().toString();
          var description = draftAnnotations![index].description;
          return Card(
            color: Color(0x00000000),
            elevation: 0,
            child: ListTile(
              title: SelectableLinkify(
                onOpen: (link) => launch(link.url),
                text: '$entry -- $description',
                style: GoogleFonts.firaMono(),
                options: LinkifyOptions(humanize: false),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: Text('Add annotation'),
              content: TextField(
                autofocus: true,
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    var now = DateTime.now().toUtc();
                    _addAnnotation(Annotation(
                      (b) => b
                        ..entry = now
                        ..description = controller.text,
                    ));
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

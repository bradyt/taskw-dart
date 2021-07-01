// ignore_for_file: prefer_expression_function_bodies

import 'package:taskw/json.dart';

extension TaskCopyWith on Task {
  Task copyWith({
    int? Function()? id,
    String Function()? status,
    String Function()? uuid,
    DateTime Function()? entry,
    String Function()? description,
    DateTime? Function()? start,
    DateTime? Function()? end,
    DateTime? Function()? due,
    DateTime? Function()? until,
    DateTime? Function()? wait,
    DateTime? Function()? modified,
    DateTime? Function()? scheduled,
    String? Function()? recur,
    String? Function()? mask,
    int? Function()? imask,
    String? Function()? parent,
    String? Function()? project,
    String? Function()? priority,
    String? Function()? depends,
    List<String>? Function()? tags,
    List<Annotation>? Function()? annotations,
    Map? Function()? udas,
  }) {
    return Task(
      id: id == null ? this.id : id(),
      status: status == null ? this.status : status(),
      uuid: uuid == null ? this.uuid : uuid(),
      entry: entry == null ? this.entry : entry(),
      description: description == null ? this.description : description(),
      start: start == null ? this.start : start(),
      end: end == null ? this.end : end(),
      due: due == null ? this.due : due(),
      until: until == null ? this.until : until(),
      wait: wait == null ? this.wait : wait(),
      modified: modified == null ? this.modified : modified(),
      scheduled: scheduled == null ? this.scheduled : scheduled(),
      recur: recur == null ? this.recur : recur(),
      mask: mask == null ? this.mask : mask(),
      imask: imask == null ? this.imask : imask(),
      parent: parent == null ? this.parent : parent(),
      project: project == null ? this.project : project(),
      priority: priority == null ? this.priority : priority(),
      depends: depends == null ? this.depends : depends(),
      tags: tags == null ? this.tags : tags(),
      annotations: annotations == null ? this.annotations : annotations(),
      udas: udas == null ? this.udas : udas(),
    );
  }
}

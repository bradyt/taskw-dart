import 'dart:io';

import 'package:flutter/material.dart';

import 'package:taskc/json.dart';
import 'package:taskc/storage.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class StorageWidget extends StatefulWidget {
  const StorageWidget({required this.profile, required this.child});

  final Directory profile;
  final Widget child;

  @override
  _StorageWidgetState createState() => _StorageWidgetState();

  static _InheritedStorage of(BuildContext context) {
    return InheritedModel.inheritFrom<_InheritedStorage>(context)!;
  }
}

class _StorageWidgetState extends State<StorageWidget> {
  late Storage storage;
  late bool pendingFilter;
  late String selectedSort;
  late Set<String> selectedTags;
  late List<Task> tasks;
  late Map<String, int> globalTags;
  bool sortHeaderVisible = false;

  @override
  void initState() {
    super.initState();
    storage = Storage(widget.profile);
    _profileSet();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      storage = Storage(widget.profile);
      _profileSet();
    }
  }

  void _profileSet() {
    pendingFilter = storage.getPendingFilter();
    selectedSort = storage.getSelectedSort();
    selectedTags = storage.getSelectedTags();
    _refreshTasks();
    globalTags = storage.tags();
  }

  void _refreshTasks() {
    if (pendingFilter) {
      tasks = storage
          .pendingData()
          .where((task) => task.status == 'pending')
          .toList();
    } else {
      tasks = storage.allData();
    }

    tasks = tasks.where((task) {
      var tags = task.tags?.toSet() ?? {};
      return selectedTags.every((tag) => (tag.startsWith('+'))
          ? tags.contains(tag.substring(1))
          : !tags.contains(tag.substring(1)));
    }).toList();

    var sortColumn = selectedSort.substring(0, selectedSort.length - 1);
    var ascending = selectedSort.endsWith('+');
    tasks.sort((a, b) {
      int result;
      if (sortColumn == 'id') {
        result = a.id!.compareTo(b.id!);
      } else {
        result = compareTasks(sortColumn)(a, b);
      }
      return ascending ? result : -result;
    });
  }

  void togglePendingFilter() {
    storage.togglePendingFilter();
    pendingFilter = storage.getPendingFilter();
    _refreshTasks();
    setState(() {});
  }

  void selectSort(String sort) {
    storage.setSelectedSort(sort);
    selectedSort = storage.getSelectedSort();
    _refreshTasks();
    setState(() {});
  }

  void toggleTagFilter(String tag) {
    if (selectedTags.contains('+$tag')) {
      selectedTags
        ..remove('+$tag')
        ..add('-$tag');
    } else if (selectedTags.contains('-$tag')) {
      selectedTags.remove('-$tag');
    } else {
      selectedTags.add('+$tag');
    }
    storage.toggleTagFilter(tag);
    selectedTags = storage.getSelectedTags();
    _refreshTasks();
    setState(() {});
  }

  Task getTask(String uuid) {
    return storage.getTask(uuid);
  }

  void mergeTask(Task task) {
    storage.mergeTask(task);
    _refreshTasks();
    setState(() {});
  }

  Future<void> synchronize(BuildContext context) async {
    try {
      var header = await storage.synchronize();
      _refreshTasks();
      globalTags = storage.tags();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${header['code']}: ${header['status']}'),
      ));
      // ignore: avoid_catches_without_on_clauses
    } catch (e, trace) {
      showExceptionDialog(
        context: context,
        e: e,
        trace: trace,
      );
    }
  }

  void toggleSortHeader() {
    sortHeaderVisible = !sortHeaderVisible;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStorage(
      tasks: tasks,
      globalTags: globalTags,
      pendingFilter: pendingFilter,
      selectedSort: selectedSort,
      getTask: getTask,
      mergeTask: mergeTask,
      synchronize: synchronize,
      togglePendingFilter: togglePendingFilter,
      selectSort: selectSort,
      toggleTagFilter: toggleTagFilter,
      selectedTags: selectedTags,
      sortHeaderVisible: sortHeaderVisible,
      toggleSortHeader: toggleSortHeader,
      child: widget.child,
    );
  }
}

class _InheritedStorage extends InheritedModel<String> {
  const _InheritedStorage({
    required this.tasks,
    required this.globalTags,
    required this.pendingFilter,
    required this.selectedSort,
    required this.selectedTags,
    required this.getTask,
    required this.mergeTask,
    required this.synchronize,
    required this.togglePendingFilter,
    required this.toggleTagFilter,
    required this.selectSort,
    required this.sortHeaderVisible,
    required this.toggleSortHeader,
    required Widget child,
  }) : super(child: child);

  final List<Task> tasks;
  final Map<String, int> globalTags;
  final bool pendingFilter;
  final String selectedSort;
  final Set<String> selectedTags;
  final Task Function(String) getTask;
  final void Function(Task) mergeTask;
  final void Function(BuildContext) synchronize;
  final void Function() togglePendingFilter;
  final void Function(String) selectSort;
  final void Function(String) toggleTagFilter;
  final bool sortHeaderVisible;
  final Function() toggleSortHeader;

  @override
  bool updateShouldNotify(_InheritedStorage oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
      _InheritedStorage oldWidget, Set<String> dependencies) {
    return true;
  }
}

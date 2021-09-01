import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';

import 'package:taskc/json.dart';
import 'package:taskc/storage.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class TagMetadata {
  TagMetadata({
    required this.lastModified,
    required this.frequency,
    required this.selected,
  });

  final DateTime lastModified;
  final int frequency;
  final bool selected;
}

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
  late bool tagUnion;
  late String selectedSort;
  late Set<String> selectedTags;
  late List<Task> queriedTasks;
  late Map<String, TagMetadata> globalTags;
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
    pendingFilter = Query(storage.tabs.tab()).getPendingFilter();
    tagUnion = Query(storage.tabs.tab()).tagUnion();
    selectedSort = Query(storage.tabs.tab()).getSelectedSort();
    selectedTags = Query(storage.tabs.tab()).getSelectedTags();
    _refreshTasks();
    globalTags = tags();
  }

  void _refreshTasks() {
    if (pendingFilter) {
      queriedTasks = storage.home
          .pendingData()
          .where((task) => task.status == 'pending')
          .toList();
    } else {
      queriedTasks = storage.home.allData();
    }

    queriedTasks = queriedTasks.where((task) {
      var tags = task.tags?.toSet() ?? {};
      if (tagUnion) {
        if (selectedTags.isEmpty) {
          return true;
        }
        return selectedTags.any((tag) => (tag.startsWith('+'))
            ? tags.contains(tag.substring(1))
            : !tags.contains(tag.substring(1)));
      } else {
        return selectedTags.every((tag) => (tag.startsWith('+'))
            ? tags.contains(tag.substring(1))
            : !tags.contains(tag.substring(1)));
      }
    }).toList();

    var sortColumn = selectedSort.substring(0, selectedSort.length - 1);
    var ascending = selectedSort.endsWith('+');
    queriedTasks.sort((a, b) {
      int result;
      if (sortColumn == 'id') {
        result = a.id!.compareTo(b.id!);
      } else {
        result = compareTasks(sortColumn)(a, b);
      }
      return ascending ? result : -result;
    });
    globalTags = tags();
  }

  Map<String, TagMetadata> tags() {
    var frequency = <String, int>{};
    for (var task in storage.home.pendingData()) {
      for (var tag in task.tags?.asList() ?? []) {
        if (frequency.containsKey(tag)) {
          frequency[tag] = (frequency[tag] ?? 0) + 1;
        } else {
          frequency[tag] = 1;
        }
      }
    }
    var modified = <String, DateTime>{};
    for (var task in storage.home.allData()) {
      var _modified = task.modified ?? DateTime.now().toUtc();
      for (var tag in task.tags?.asList() ?? []) {
        if (modified.containsKey(tag)) {
          modified[tag] = DateTime.fromMicrosecondsSinceEpoch(
            max(
              _modified.microsecondsSinceEpoch,
              modified[tag]?.microsecondsSinceEpoch ??
                  DateTime.now().toUtc().microsecondsSinceEpoch,
            ),
            isUtc: true,
          );
        } else {
          modified[tag] = _modified;
        }
      }
    }
    var setOfTags = storage.home
        .allData()
        .map((task) => task.tags)
        .expand((tags) => tags ?? BuiltList())
        .toSet();
    return SplayTreeMap.of({
      if (setOfTags.isNotEmpty)
        for (var tag in setOfTags)
          tag: TagMetadata(
            frequency: frequency[tag] ?? 0,
            lastModified: modified[tag]!,
            selected: selectedTags
                .map(
                  (filter) => filter.substring(1),
                )
                .contains(tag),
          ),
    });
  }

  void togglePendingFilter() {
    Query(storage.tabs.tab()).togglePendingFilter();
    pendingFilter = Query(storage.tabs.tab()).getPendingFilter();
    _refreshTasks();
    setState(() {});
  }

  void toggleTagUnion() {
    Query(storage.tabs.tab()).toggleTagUnion();
    tagUnion = Query(storage.tabs.tab()).tagUnion();
    _refreshTasks();
    setState(() {});
  }

  void selectSort(String sort) {
    Query(storage.tabs.tab()).setSelectedSort(sort);
    selectedSort = Query(storage.tabs.tab()).getSelectedSort();
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
    Query(storage.tabs.tab()).toggleTagFilter(tag);
    selectedTags = Query(storage.tabs.tab()).getSelectedTags();
    _refreshTasks();
    setState(() {});
  }

  Task getTask(String uuid) {
    return storage.home.getTask(uuid);
  }

  void mergeTask(Task task) {
    storage.home.mergeTask(task);
    _refreshTasks();
    setState(() {});
  }

  Future<void> synchronize(BuildContext context) async {
    try {
      var header = await storage.home.synchronize();
      _refreshTasks();
      globalTags = tags();
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

  void setInitialTabIndex(int index) {
    storage.tabs.setInitialTabIndex(index);
    pendingFilter = Query(storage.tabs.tab()).getPendingFilter();
    selectedSort = Query(storage.tabs.tab()).getSelectedSort();
    selectedTags = Query(storage.tabs.tab()).getSelectedTags();
    _refreshTasks();
    setState(() {});
  }

  void addTab() {
    storage.tabs.addTab();
    setState(() {});
  }

  List<String> tabUuids() {
    return storage.tabs.tabUuids();
  }

  int initialTabIndex() {
    return storage.tabs.initialTabIndex();
  }

  void removeTab(int index) {
    storage.tabs.removeTab(index);
    pendingFilter = Query(storage.tabs.tab()).getPendingFilter();
    selectedSort = Query(storage.tabs.tab()).getSelectedSort();
    selectedTags = Query(storage.tabs.tab()).getSelectedTags();
    _refreshTasks();
    setState(() {});
  }

  void renameTab({
    required String tab,
    required String name,
  }) {
    storage.tabs.renameTab(tab: tab, name: name);
    setState(() {});
  }

  String? tabAlias(String tabUuid) {
    return storage.tabs.alias(tabUuid);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStorage(
      tasks: queriedTasks,
      globalTags: globalTags,
      pendingFilter: pendingFilter,
      tagUnion: tagUnion,
      selectedSort: selectedSort,
      getTask: getTask,
      mergeTask: mergeTask,
      synchronize: synchronize,
      togglePendingFilter: togglePendingFilter,
      toggleTagUnion: toggleTagUnion,
      selectSort: selectSort,
      toggleTagFilter: toggleTagFilter,
      selectedTags: selectedTags,
      sortHeaderVisible: sortHeaderVisible,
      toggleSortHeader: toggleSortHeader,
      setInitialTabIndex: setInitialTabIndex,
      addTab: addTab,
      tabUuids: tabUuids,
      initialTabIndex: initialTabIndex,
      removeTab: removeTab,
      renameTab: renameTab,
      tabAlias: tabAlias,
      child: widget.child,
    );
  }
}

class _InheritedStorage extends InheritedModel<String> {
  const _InheritedStorage({
    required this.tasks,
    required this.globalTags,
    required this.pendingFilter,
    required this.tagUnion,
    required this.selectedSort,
    required this.selectedTags,
    required this.getTask,
    required this.mergeTask,
    required this.synchronize,
    required this.togglePendingFilter,
    required this.toggleTagUnion,
    required this.toggleTagFilter,
    required this.selectSort,
    required this.sortHeaderVisible,
    required this.toggleSortHeader,
    required this.setInitialTabIndex,
    required this.addTab,
    required this.tabUuids,
    required this.initialTabIndex,
    required this.removeTab,
    required this.renameTab,
    required this.tabAlias,
    required Widget child,
  }) : super(child: child);

  final List<Task> tasks;
  final Map<String, TagMetadata> globalTags;
  final bool pendingFilter;
  final bool tagUnion;
  final String selectedSort;
  final Set<String> selectedTags;
  final Task Function(String) getTask;
  final void Function(Task) mergeTask;
  final void Function(BuildContext) synchronize;
  final void Function() togglePendingFilter;
  final void Function() toggleTagUnion;
  final void Function(String) selectSort;
  final void Function(String) toggleTagFilter;
  final bool sortHeaderVisible;
  final Function() toggleSortHeader;
  final void Function(int) setInitialTabIndex;
  final void Function() addTab;
  final List<String> Function() tabUuids;
  final int Function() initialTabIndex;
  final void Function(int) removeTab;
  final String? Function(String) tabAlias;
  final void Function({required String tab, required String name}) renameTab;

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

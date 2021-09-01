// ignore_for_file: prefer_expression_function_bodies

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';

import 'package:taskc/home.dart';

class Storage {
  const Storage(this.profile);

  final Directory profile;

  File get _selectedSort => File('${profile.path}/selectedSort');
  File get _pendingFilter => File('${profile.path}/pendingFilter');
  File get _selectedTags => File('${profile.path}/selectedTags');
  Home get home => Home(profile);

  void setSelectedSort(String selectedSort) {
    if (!_selectedSort.existsSync()) {
      _selectedSort.createSync(recursive: true);
    }
    _selectedSort.writeAsStringSync(selectedSort);
  }

  String getSelectedSort() {
    if (!_selectedSort.existsSync()) {
      _selectedSort
        ..createSync(recursive: true)
        ..writeAsStringSync('urgency+');
    }
    return _selectedSort.readAsStringSync();
  }

  void togglePendingFilter() {
    _pendingFilter.writeAsStringSync(
      json.encode(!getPendingFilter()),
    );
  }

  bool getPendingFilter() {
    if (!_pendingFilter.existsSync()) {
      _pendingFilter
        ..createSync(recursive: true)
        ..writeAsStringSync('true');
    }
    return json.decode(_pendingFilter.readAsStringSync());
  }

  void toggleTagFilter(String tag) {
    var _tags = getSelectedTags();
    if (_tags.contains('+$tag')) {
      _tags
        ..remove('+$tag')
        ..add('-$tag');
    } else if (_tags.contains('-$tag')) {
      _tags.remove('-$tag');
    } else {
      _tags.add('+$tag');
    }
    _selectedTags.writeAsStringSync(json.encode(_tags.toList()));
  }

  Set<String> getSelectedTags() {
    if (!_selectedTags.existsSync()) {
      _selectedTags
        ..createSync(recursive: true)
        ..writeAsStringSync(json.encode([]));
    }
    return (json.decode(_selectedTags.readAsStringSync()) as List)
        .cast<String>()
        .toSet();
  }

  Map<String, int> tags() {
    var listOfLists = Home(profile).pendingData().map((task) => task.tags);
    var listOfTags = listOfLists.expand((tags) => tags ?? BuiltList());
    var setOfTags = listOfTags.toSet();
    return SplayTreeMap.of({
      if (setOfTags.isNotEmpty)
        for (var tag in setOfTags) tag: 0,
    });
  }
}

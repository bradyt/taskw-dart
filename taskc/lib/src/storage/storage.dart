import 'dart:collection';
import 'dart:io';

import 'package:built_collection/built_collection.dart';

import 'package:taskw/taskw.dart';

import 'package:taskc/home.dart';

class Storage {
  const Storage(this.profile);

  final Directory profile;

  Home get home => Home(profile);
  Query get query => Query(profile);

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

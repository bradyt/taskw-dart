import 'dart:convert';
import 'dart:io';

class Query {
  const Query(this._queryStorage);

  final Directory _queryStorage;

  File get _selectedSort => File('${_queryStorage.path}/selectedSort');
  File get _pendingFilter => File('${_queryStorage.path}/pendingFilter');
  File get _tagUnion => File('${_queryStorage.path}/tagUnion');
  File get _selectedTags => File('${_queryStorage.path}/selectedTags');

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

  void toggleTagUnion() {
    _tagUnion.writeAsStringSync(
      json.encode(!tagUnion()),
    );
  }

  bool tagUnion() {
    if (!_tagUnion.existsSync()) {
      _tagUnion
        ..createSync(recursive: true)
        ..writeAsStringSync('false');
    }
    return json.decode(_tagUnion.readAsStringSync());
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
}

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

    var pendingTags = storageWidget.pendingTags;

    var selectedTagsMap = {
      for (var tag in storageWidget.selectedTags) tag.substring(1): tag,
    };

    var keys = (pendingTags.keys.toSet()..addAll(selectedTagsMap.keys)).toList()
      ..sort();

    var tags = {
      for (var tag in keys)
        tag: TagFilterMetadata(
          display:
              '${selectedTagsMap[tag] ?? tag} ${pendingTags[tag]?.frequency ?? 0}',
          selected: selectedTagsMap.containsKey(tag),
        ),
    };

    var tagFilters = TagFilters(
      tagUnion: storageWidget.tagUnion,
      toggleTagUnion: storageWidget.toggleTagUnion,
      tags: tags,
      toggleTagFilter: storageWidget.toggleTagFilter,
    );

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            primary: false,
            key: const PageStorageKey('tags-filter'),
            children: [
              Card(
                child: ListTile(
                  title: Text(
                    'filter:${storageWidget.pendingFilter ? 'status:pending' : ''}',
                    style: GoogleFonts.firaMono(),
                  ),
                  onTap: storageWidget.togglePendingFilter,
                ),
              ),
              const Divider(),
              ProjectsColumn(
                storageWidget.projects,
                storageWidget.projectFilter,
                storageWidget.toggleProjectFilter,
              ),
              const Divider(),
              TagFiltersWrap(tagFilters),
            ],
          ),
        ),
      ),
    );
  }
}

class TagFilterMetadata {
  const TagFilterMetadata({
    required this.display,
    required this.selected,
  });

  final String display;
  final bool selected;
}

class TagFilters {
  const TagFilters({
    required this.tagUnion,
    required this.toggleTagUnion,
    required this.tags,
    required this.toggleTagFilter,
  });

  final bool tagUnion;
  final void Function() toggleTagUnion;
  final Map<String, TagFilterMetadata> tags;
  final void Function(String) toggleTagFilter;
}

class TagFiltersWrap extends StatelessWidget {
  const TagFiltersWrap(this.filters, {Key? key}) : super(key: key);

  final TagFilters filters;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        FilterChip(
            onSelected: (_) => filters.toggleTagUnion(),
            label: Text(filters.tagUnion ? 'OR' : 'AND',
                style: GoogleFonts.firaMono())),
        for (var entry in filters.tags.entries)
          FilterChip(
            onSelected: (_) => filters.toggleTagFilter(entry.key),
            label: Text(
              entry.value.display,
              style: GoogleFonts.firaMono(
                fontWeight: entry.value.selected ? FontWeight.w700 : null,
              ),
            ),
          ),
      ],
    );
  }
}

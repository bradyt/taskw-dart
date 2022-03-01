import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class Filters {
  const Filters({
    required this.pendingFilter,
    required this.togglePendingFilter,
    required this.tagFilters,
    required this.projects,
    required this.projectFilter,
    required this.toggleProjectFilter,
  });

  final bool pendingFilter;
  final void Function() togglePendingFilter;
  final TagFilters tagFilters;
  final dynamic projects;
  final String projectFilter;
  final void Function(String) toggleProjectFilter;
}

class TaskListRoute extends StatelessWidget {
  const TaskListRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var profilesWidget = ProfilesWidget.of(context);
    var storageWidget = StorageWidget.of(context);

    var profilesMap = profilesWidget.profilesMap;
    var currentProfile = profilesWidget.currentProfile;

    var tabUuid = storageWidget.tabUuids()[storageWidget.initialTabIndex()];
    var title = profilesMap[currentProfile] ?? currentProfile;
    var subtitle = storageWidget.tabAlias(tabUuid) ?? tabUuid;

    var taskData = storageWidget.tasks;
    var pendingFilter = storageWidget.pendingFilter;

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

    var filters = Filters(
      pendingFilter: pendingFilter,
      togglePendingFilter: storageWidget.togglePendingFilter,
      projects: storageWidget.projects,
      projectFilter: storageWidget.projectFilter,
      toggleProjectFilter: storageWidget.toggleProjectFilter,
      tagFilters: tagFilters,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.firaMono()),
            Text(subtitle, style: GoogleFonts.firaMono()),
          ],
        ),
        actions: [
          IconButton(
            icon: (storageWidget.searchVisible)
                ? const Icon(Icons.cancel)
                : const Icon(Icons.search),
            onPressed: storageWidget.toggleSearch,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => storageWidget.synchronize(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: storageWidget.toggleSortHeader,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawer: const Drawer(
        child: SafeArea(
          child: MainDrawer(),
        ),
      ),
      body: Column(
        children: [
          if (storageWidget.searchVisible)
            Card(
              child: TextField(
                autofocus: true,
                style: GoogleFonts.firaMono(),
                onChanged: (value) {
                  storageWidget.search(value);
                },
                controller: storageWidget.searchController,
              ),
            ),
          if (storageWidget.sortHeaderVisible)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var sort in [
                      'id',
                      'entry',
                      'modified',
                      'start',
                      'due',
                      'priority',
                      'project',
                      'tags',
                      'urgency',
                    ])
                      ChoiceChip(
                        label: (storageWidget.selectedSort.startsWith(sort))
                            ? Text(
                                storageWidget.selectedSort,
                                style: GoogleFonts.firaMono(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Text(sort, style: GoogleFonts.firaMono()),
                        selected: false,
                        onSelected: (_) {
                          if (storageWidget.selectedSort == '$sort+') {
                            storageWidget.selectSort('$sort-');
                          } else {
                            storageWidget.selectSort('$sort+');
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Scrollbar(
              child: TaskListView(
                taskData: taskData,
                pendingFilter: pendingFilter,
              ),
            ),
          ),
        ],
      ),
      endDrawer: FilterDrawer(filters),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => const AddTaskBottomSheet(),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        ),
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

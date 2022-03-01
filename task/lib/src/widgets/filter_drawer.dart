import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:task/task.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var storageWidget = StorageWidget.of(context);

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
              ),
              const Divider(),
              Wrap(
                spacing: 4,
                children: [
                  FilterChip(
                    onSelected: (_) => storageWidget.toggleTagUnion(),
                    label: Text(
                      storageWidget.tagUnion ? 'OR' : 'AND',
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
                  // ignore: unnecessary_null_comparison
                  if (storageWidget.globalTags != null)
                    for (var tag in storageWidget.globalTags.entries.where(
                        (entry) =>
                            entry.value.frequency > 0 || entry.value.selected))
                      FilterChip(
                        onSelected: (_) =>
                            storageWidget.toggleTagFilter(tag.key),
                        label: Text(
                          '${storageWidget.selectedTags.firstWhere(
                            (selectedTag) =>
                                selectedTag.substring(1) == tag.key,
                            orElse: () => tag.key,
                          )} ${tag.value.frequency}',
                          style: GoogleFonts.firaMono(
                            fontWeight: storageWidget.selectedTags.any(
                                    (selectedTag) =>
                                        selectedTag.substring(1) == tag.key)
                                ? FontWeight.w700
                                : null,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

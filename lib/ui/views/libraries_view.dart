import 'package:flutter/material.dart';

import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/models/region.dart';

import 'package:url_launcher/url_launcher.dart';

part '../controllers/libraries_controller.dart';

class LibrariesView extends StatefulWidget {
  final Future<List<Library>> libraries;

  const LibrariesView({super.key, required this.libraries});

  @override
  State<LibrariesView> createState() => _LibrariesViewState();
}

class _LibrariesViewState extends LibrariesController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.libraryDirectory),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width
                : (MediaQuery.of(context).size.width / 3) * 2,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<List<Library>>(
                  future: widget.libraries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.noLibrariesFound,
                        ),
                      );
                    } else {
                      final libraries = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: regionsList.length,
                        itemBuilder: (context, index) {
                          final item = regionsList[index];

                          return Card(
                            color: Colors.grey[100],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Text(
                                  item,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: libraries
                                    .where((lib) => lib.region == item)
                                    .map((library) {
                                      return ListTile(
                                        title: Text(library.name),
                                        subtitle: Text(
                                          '${library.city}, ${library.state}',
                                        ),
                                        trailing: library.url.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.link),
                                                color: Colors.blue,
                                                onPressed: () =>
                                                    openLink(library.url),
                                              )
                                            : null,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(library.name),
                                                content: buildDialogFields(
                                                  library,
                                                  context,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.close,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

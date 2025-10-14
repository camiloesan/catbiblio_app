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
      body: CustomScrollView(
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
                    child: Text(AppLocalizations.of(context)!.noLibrariesFound),
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
                        child: ExpansionTile(
                          title: Text(
                            item,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: libraries.where((lib) => lib.region == item).map((
                            library,
                          ) {
                            return ListTile(
                              title: Text(library.name),
                              subtitle: Text(
                                '${library.city}, ${library.state}',
                              ),
                              trailing: library.url.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.link),
                                      color: Colors.blue,
                                      onPressed: () => openLink(library.url),
                                    )
                                  : null,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(library.name),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (library.area.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: Chip(
                                                  label: Text(library.area),
                                                ),
                                              ),
                                            ),
                                          if (library.address.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.address}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(library.address),
                                                ],
                                              ),
                                            ),
                                          if (library.postalCode.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.postalCode}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(library.postalCode),
                                                ],
                                              ),
                                            ),
                                          if (library.city.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.city}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(library.city),
                                                ],
                                              ),
                                            ),
                                          if (library.state.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.state}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(library.state),
                                                ],
                                              ),
                                            ),
                                          if (library.country.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.country}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(library.country),
                                                ],
                                              ),
                                            ),
                                          if (library.email.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.email}: ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final Uri emailLaunchUri =
                                                          Uri(
                                                            scheme: 'mailto',
                                                            path: library.email,
                                                          );
                                                      await launchUrl(
                                                        emailLaunchUri,
                                                      );
                                                    },
                                                    child: Text(
                                                      library.email,
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (library.url.isNotEmpty)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Chip(
                                                  label: GestureDetector(
                                                    onTap: () =>
                                                        openLink(library.url),
                                                    child: Text(
                                                      library.url,
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            AppLocalizations.of(context)!.close,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
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
    );
  }
}

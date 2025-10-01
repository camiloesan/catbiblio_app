import 'package:flutter/material.dart';

import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/library.dart';

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
      body: FutureBuilder<List<Library>>(
        future: widget.libraries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No libraries found.'));
          } else {
            final libraries = snapshot.data!;
            return ListView.builder(
              itemCount: libraries.length,
              itemBuilder: (context, index) {
                final library = libraries[index];
                return ListTile(
                  title: Text(library.name),
                  subtitle: Text(
                    '${library.address} C.P ${library.postalCode}, ${library.city}, ${library.state}, ${library.country}',
                  ),
                  onTap: () {
                    if (library.url.isNotEmpty) {
                      // Open library URL
                      openLink(library.url);
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

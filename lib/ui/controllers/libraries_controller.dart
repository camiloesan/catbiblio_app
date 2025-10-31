part of '../views/libraries_view.dart';

abstract class LibrariesController extends State<LibrariesView> {
  late List<Library> libraries;
  final List<String> regionsList = regions.values.toList();
  final int screenSizeLimit = 800;

  /// Opens a URL in the default external application.
  /// If the URL cannot be opened, shows a SnackBar with an error message.
  ///
  /// Parameters:
  /// - [url]: The URL to open as a string.
  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    }
  }

  /// Builds the content of the library details dialog
  /// showing only the fields that are not empty.
  ///
  /// Returns a Column widget containing the library details.
  Column buildDialogFields(Library library, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (library.area.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Chip(label: Text(library.area)),
            ),
          ),
        if (library.address.isNotEmpty)
          LibraryField(
            fieldName: AppLocalizations.of(context)!.address,
            value: library.address,
          ),
        if (library.postalCode.isNotEmpty)
          LibraryField(
            fieldName: AppLocalizations.of(context)!.postalCode,
            value: library.postalCode,
          ),
        if (library.city.isNotEmpty)
          LibraryField(
            fieldName: AppLocalizations.of(context)!.city,
            value: library.city,
          ),
        if (library.state.isNotEmpty)
          LibraryField(
            fieldName: AppLocalizations.of(context)!.state,
            value: library.state,
          ),
        if (library.country.isNotEmpty)
          LibraryField(
            fieldName: AppLocalizations.of(context)!.country,
            value: library.country,
          ),
        if (library.email.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.email}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: library.email,
                    );
                    await launchUrl(emailLaunchUri);
                  },
                  child: Text(
                    library.email,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
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
              margin: const EdgeInsets.only(top: 8.0),
              child: Chip(
                label: GestureDetector(
                  onTap: () => openLink(library.url),
                  child: Text(
                    library.url,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget to display a field in the library details dialog
/// with the field name in bold followed by its value.
///
/// For example: "Address: 123 Main St"
///
/// This widget is used in the buildLibraryDialog method of LibrariesController.
class LibraryField extends StatelessWidget {
  final String fieldName;
  final String value;

  const LibraryField({super.key, required this.fieldName, required this.value});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        children: [
          Text(
            '$fieldName: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

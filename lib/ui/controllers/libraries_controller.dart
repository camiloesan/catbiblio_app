part of '../views/libraries_view.dart';

abstract class LibrariesController extends State<LibrariesView> {
  late List<Library> libraries;
  final List<String> regionsList = regions.values.toList();

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
}

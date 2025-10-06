import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/services/rest/biblios_details.dart';
import 'package:flutter/material.dart';

part '../controllers/marc_controller.dart';

class MarcView extends StatefulWidget {
  final String biblioNumber;

  const MarcView({super.key, required this.biblioNumber});

  @override
  State<MarcView> createState() => _MarcViewState();
}

class _MarcViewState extends MarcController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.marcView} - ${widget.biblioNumber}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text(AppLocalizations.of(context)!.errorLoadingMarc))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      marcData ?? AppLocalizations.of(context)!.noMarcDataAvailable,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
    );
  }
}

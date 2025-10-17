import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/services/biblios_details.dart';
import 'package:catbiblio_app/ui/views/home_view.dart';
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
        title: Text(
          '${AppLocalizations.of(context)!.marcView} - ${widget.biblioNumber}',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text(AppLocalizations.of(context)!.errorLoadingMarc))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height,
                    maxWidth: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width
                        : (MediaQuery.of(context).size.width / 3) * 2,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 3.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InteractiveViewer(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          marcData ??
                              AppLocalizations.of(context)!.noMarcDataAvailable,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
